{
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  stalwart,
  zip,
}:
buildNpmPackage (finalAttrs: {
  pname = "stalwart-webui";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "webui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ms0RRwlfj8zqQuQLHoFxDs2H7OTECIheZfGB8W38cTk=";
  };

  npmDepsHash = "sha256-XusIkv2lSwO/FXy+QsLAtcrSwN28SUa07/kj39Mr+u0=";

  nativeBuildInputs = [ zip ];

  installPhase = ''
    runHook preInstall
    cd dist
    zip -r "$out" .
    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Web administration module for the Stalwart server";
    homepage = "https://github.com/stalwartlabs/webui";
    changelog = "https://github.com/stalwartlabs/webui/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    inherit (stalwart.meta) license maintainers;
  };
})
