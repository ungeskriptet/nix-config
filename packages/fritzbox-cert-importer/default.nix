{ stdenvNoCC, python3 }:
stdenvNoCC.mkDerivation {
  name = "fritzbox-cert-importer";

  dontUnpack = true;

  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall

    install -Dm555 ${./fritzbox-cert-importer.py} "$out"/bin/fritzbox-cert-importer

    runHook postInstall
  '';

  meta.mainProgram = "fritzbox-cert-importer";
}
