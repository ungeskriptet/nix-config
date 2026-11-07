{
  lib,
  stdenvNoCC,
  makeWrapper,
  shellcheck-minimal,
  curl,
  jq,
}:
let
  src = ./servfail-update.sh;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "servfail-update";

  dontUnpack = true;
  doCheck = true;

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ shellcheck-minimal ];

  checkPhase = ''
    runHook preCheck

    shellcheck ${src}

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm555 ${src} "$out"/bin/servfail-update
    wrapProgram "$out"/bin/servfail-update \
      --prefix PATH : ${
        lib.makeBinPath [
          curl
          jq
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "DNS zone updater for Project SERVFAIL";
    maintainers = with lib.maintainers; [ ungeskriptet ];
    license = lib.licenses.gpl3Only;
    mainProgram = "servfail-update";
  };
})
