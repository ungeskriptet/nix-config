{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  zip,
  stalwart_0_16,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "webui";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "webui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kTLAxUI2kf4M6noucX/54fweepO0VlC1QDJZcGaXqJ8=";
  };

  npmDepsHash = "sha256-XusIkv2lSwO/FXy+QsLAtcrSwN28SUa07/kj39Mr+u0=";
  __structuredAttrs = true;

  env = {
    # https://github.com/stalwartlabs/webui/tree/main#environment-variables
    # https://github.com/stalwartlabs/webui/blob/main/.env.development
    VITE_API_BASE_URL = "";
    VITE_OAUTH_CLIENT_ID = "stalwart-webui";
  };

  nativeBuildInputs = [ zip ];
  preBuild = ''
    rm .env.development
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    npm run test
    runHook postCheck
  '';

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
    description = "Stalwart WebUI";
    longDescription = ''
      Stalwart WebUI is schema-driven single-page application for administering Stalwart.

      After authentication the panel fetches a JSON schema from the server and dynamically
      generates all forms, lists, navigation, and layouts from that schema. Nothing is hardcoded.
    '';
    homepage = "https://github.com/stalwartlabs/webui";
    changelog = "https://github.com/stalwartlabs/webui/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.OR [
      lib.licenses.agpl3Only
      {
        fullName = "Stalwart Enterprise License 2.0 (SELv2) Agreement";
        url = "https://github.com/stalwartlabs/webui/blob/main/LICENSES/LicenseRef-SEL.txt";
        free = false;
        redistributable = false;
      }
    ];
    inherit (stalwart_0_16.meta) maintainers;
  };
})
