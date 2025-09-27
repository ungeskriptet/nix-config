{
  stdenv,
  fetchzip,
  autoPatchelfHook,
  copyDesktopItems,
  makeWrapper,
  alsa-lib,
  libglvnd,
  libjack2,
  libpulseaudio,
  libssh2,
  libxkbcommon,
  mesa_glu,
  openldap,
  makeDesktopItem,
}:
stdenv.mkDerivation {
  pname = "outfox-alpha5";
  version = "0.5.0-pre043-a41";

  src = fetchzip {
    url = "https://drive.usercontent.google.com/download?id=1xQw9tvZbhnBpgWRfbJdMXgtfQnTlAl9A&confirm=t";
    hash = "sha256-RzsHQlG7JYNOegoolCLLRx0zIbxwT2F2tDiS3WmOTQ4=";
    extension = "tar.gz";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    libglvnd
    libjack2
    libpulseaudio
    libssh2
    libxkbcommon
    mesa_glu
    openldap
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "outfox-alpha5";
      desktopName = "Project OutFox (Alpha 5)";
      genericName = "Rhythm game engine";
      tryExec = "outfox-alpha5";
      exec = "outfox-alpha5";
      terminal = false;
      icon = "outfox-alpha5";
      type = "Application";
      categories = [
        "Game"
        "ArcadeGame"
      ];
    })
  ];

  patchPhase = ''
    find ./Appearance -type f -executable -exec chmod -x {} \;
  '';

  installPhase = ''
    runHook preInstallHooks

    mkdir -p $out/bin $out/share/OutFox $out/share/pixmaps

    cp -r ./. $out/share/OutFox

    ln -s "$out/share/OutFox/Appearance/Themes/default/Graphics/Common window icon.png" \
      $out/share/pixmaps/outfox-alpha5.png

    makeWrapper $out/share/OutFox/OutFox $out/bin/outfox-alpha5 \
      --chdir $out/share/OutFox

    runHook postInstallHooks
  '';

  meta = {
    description = "Rhythm game engine forked from StepMania";
    homepage = "https://projectoutfox.com";
    mainProgram = "OutFox-alpha";
  };
}
