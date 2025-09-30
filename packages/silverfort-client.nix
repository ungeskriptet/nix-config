{
  lib,
  stdenvNoCC,
  requireFile,
  autoPatchelfHook,
  dpkg,
  makeBinaryWrapper,
  alsa-lib,
  cups,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  nss,
  systemd,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "silverfort-client";
  version = "3.7.5";

  src = requireFile rec {
    name = "${finalAttrs.pname}_${finalAttrs.version}_amd64.deb";
    message = "Please run 'nix store add-file ${name}'";
    hash = "sha256-eOkSVoucMiGH4sTnC8/3sWMyT9DpnGEYXX+1y2ULDBg=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeBinaryWrapper
  ];

  buildInputs = [
    alsa-lib
    cups.lib
    gtk3
    libdrm
    libgbm
    nss
  ];

  # Required to launch the application and proceed past the zygote_linux fork() process
  # Fixes `Zygote could not fork`
  runtimeDependencies = [ systemd ];

  installPhase = ''
    mkdir -p $out/{bin,opt}
    mv "opt/Silverfort Client" $out/opt/silverfort-client
    mv usr/share $out
    makeWrapper $out/opt/silverfort-client/silverfort-client $out/bin/silverfort-client \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]}
  '';

  meta.mainProgram = "silverfort-client";
})
