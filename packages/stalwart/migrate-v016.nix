{
  stdenvNoCC,
  makeWrapper,
  python3Packages,
  stalwart,
}:
stdenvNoCC.mkDerivation {
  inherit (stalwart) src version;
  pname = "stalwart-migrate-v016";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp resources/scripts/migrate_v016.py $out/bin/migrate_v016-unwrapped
    makeWrapper ${python3Packages.python.interpreter} "$out/bin/migrate_v016" \
      --add-flags "$out/bin/migrate_v016-unwrapped" \
      --prefix PYTHONPATH : "${
        with python3Packages;
        makePythonPath [
          requests
          urllib3
        ]
      }"

    runHook postInstall
  '';

  meta = {
    inherit (stalwart.meta) license homepage;
    description = "Helper script to migrate Stalwart to v0.16.x";
    mainProgram = "migrate_v016";
  };
}
