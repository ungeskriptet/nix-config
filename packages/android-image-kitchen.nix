{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  lz4,
  rkflashtool,
  ubootTools,
}:
stdenv.mkDerivation {
  pname = "android-image-kitchen";
  version = "0-unstable-2025-01-02";

  src = fetchFromGitHub {
    owner = "SebaUbuntu";
    repo = "AIK-Linux-mirror";
    rev = "1c1411bd685bbc5fb4112484af2ad07cb6807f30";
    hash = "sha256-auwAXWzUAFS8USTTH9h5nPzmoGOZf53GkLA+KNGl8uc=";
  };

  nativeBuildInputs = [
  ];

  postPatch = ''
    # We already take care of chmod in installPhase
    SUBST='chmod 644 "$bin/magic" "$bin/androidbootimg.magic" "$bin/androidsign.magic" "$bin/boot_signer.jar" "$bin/avb/"* "$bin/chromeos/"*;'
    substituteInPlace {cleanup,repackimg,unpackimg}.sh \
      --replace-fail \
        'chmod -R 755 "$bin" "$aik"/*.sh;' "" \
      --replace-fail "$SUBST" ""
  '';

  installPhase =
    let
      arch =
        if stdenv.hostPlatform.isAarch32 then
          "ARM"
        else if stdenv.hostPlatform.isAarch64 then
          "aarch64"
        else if stdenv.hostPlatform.isi686 then
          "i686"
        else if stdenv.hostPlatform.isx86_64 then
          "x86_64"
        else
          throw "Unsupported architecture: ${stdenv.hostPlatform.system}";
      platform =
        if stdenv.hostPlatform.isDarwin then
          "macos"
        else if stdenv.hostPlatform.isLinux then
          "linux"
        else
          throw "Unsupported platform: ${stdenv.hostPlatform.system}";
    in
    ''
      runHook preInstall

      install -Dm 555 {cleanup,repackimg,unpackimg}.sh -t $out

      # Replace prebuilt binaries
      rm -rf bin/{linux,macos}

      cp -r bin $out
      mkdir -p $out/bin/${platform}/${arch}

      chmod -R u+rwX,go+rX $out

      ln -s ${lib.getExe' (callPackage ./blobtools.nix { }) "blobpack"} $out/bin/${platform}/${arch}
      ln -s ${lib.getExe' (callPackage ./blobtools.nix { }) "blobunpack"} $out/bin/${platform}/${arch}
      ln -s ${lib.getExe (callPackage ./dhtbsign.nix { })} $out/bin/${platform}/${arch}
      ln -s ${lib.getExe' ubootTools "dumpimage"} $out/bin/${platform}/${arch}
      ln -s ${lib.getExe (callPackage ./elftool.nix { })} $out/bin/${platform}/${arch}
      ln -s ${lib.getExe (callPackage ./futility.nix { })} $out/bin/${platform}/${arch}
      ln -s ${lib.getExe (callPackage ./loki-tool.nix { })} $out/bin/${platform}/${arch}
      ln -s ${lib.getExe' lz4 "lz4"} $out/bin/${platform}/${arch}
      ln -s ${lib.getExe (callPackage ./mboot.nix { })} $out/bin/${platform}/${arch}
      ln -s ${
        lib.getExe' (callPackage ./mkbootimg-osm0sis.nix { }) "mkbootimg"
      } $out/bin/${platform}/${arch}
      ln -s ${lib.getExe' ubootTools "mkimage"} $out/bin/${platform}/${arch}
      ln -s ${lib.getExe (callPackage ./mkmtkhdr.nix { })} $out/bin/${platform}/${arch}
      ln -s ${
        lib.getExe' (callPackage ./pxa-mkbootimg.nix { }) "pxa-mkbootimg"
      } $out/bin/${platform}/${arch}
      ln -s ${
        lib.getExe' (callPackage ./pxa-mkbootimg.nix { }) "pxa-unpackbootimg"
      } $out/bin/${platform}/${arch}
      ln -s ${lib.getExe' rkflashtool "rkcrc"} $out/bin/${platform}/${arch}
      ln -s ${lib.getExe (callPackage ./sony-dump { })} $out/bin/${platform}/${arch}
      ln -s ${
        lib.getExe' (callPackage ./mkbootimg-osm0sis.nix { }) "unpackbootimg"
      } $out/bin/${platform}/${arch}
      ln -s ${lib.getExe (callPackage ./unpackelf.nix { })} $out/bin/${platform}/${arch}

      runHook postInstall
    '';

  meta = {
    description = "Unpack & repack Android boot files";
    homepage = "https://github.com/SebaUbuntu/AIK-Linux-mirror";
    license = lib.licenses.free;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ ungeskriptet ];
  };
}
