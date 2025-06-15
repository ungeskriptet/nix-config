{
  pkgs,
  lib,
  requireFile,
}:

with pkgs;

let
  pythonForIDA = python3.withPackages (ps: with ps; [ rpyc ]);
in
stdenv.mkDerivation rec {
  pname = "ida-pro";
  version = "9.1.0.250226";

  src = requireFile rec {
    name = "ida-pro_91_x64linux.run";
    message = "Please run 'nix store add-file ${name}'";
    hash = "sha256-j/CAIr46DvaTqePqAQENE1aybP3Lvn/daNAbPJcA+eI=";
  };

  patcher = requireFile rec {
    name = "ida-keygen.py";
    message = "Please run 'nix store add-file ${name}'";
    hash = "sha256-16J0eUT6OB2JHzNKeqHe7Zzv3QMwviEIJLkh2crnRQ0=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    autoPatchelfHook
    libsForQt5.wrapQtAppsHook
  ];

  dontUnpack = true;

  runtimeDependencies = with pkgs; [
    cairo
    dbus
    fontconfig
    freetype
    glib
    gtk3
    libdrm
    libGL
    libkrb5
    libsecret
    libsForQt5.qtbase
    libunwind
    libxkbcommon
    libsecret
    openssl.out
    stdenv.cc.cc
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXau
    xorg.libxcb
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    zlib
    curl.out
    pythonForIDA
  ];
  buildInputs = runtimeDependencies;

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib $out/opt $out/share/.local/share/applications

    IDADIR=$out/opt
    HOME=$out/share

    $(cat $NIX_CC/nix-support/dynamic-linker) $src \
      --mode unattended --prefix $IDADIR

    mv $out/share/.local/share/applications $out/share/applications
    rm -r $out/share/.local

    for lib in $IDADIR/libida*; do
      ln -s $lib $out/lib/$(basename $lib)
    done

    pushd $IDADIR
    python $patcher
    mv ida.hexlic idapro.hexlic
    popd

    patchelf --add-needed libpython3.12.so $out/lib/libida.so
    patchelf --add-needed libcrypto.so $out/lib/libida.so

    addAutoPatchelfSearchPath $IDADIR

    for bb in ida assistant; do
      wrapProgram $IDADIR/$bb \
        --prefix QT_PLUGIN_PATH : $IDADIR/plugins/platforms \
        --prefix PYTHONPATH : $out/opt/idalib/python \
        --prefix PATH : ${pythonForIDA}/bin
      ln -s $IDADIR/$bb $out/bin/$bb
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "The world's smartest and most feature-full disassembler";
    homepage = "https://hex-rays.com/ida-pro/";
    changelog = "https://hex-rays.com/products/ida/news/";
    mainProgram = "ida";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
