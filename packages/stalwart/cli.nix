{
  rustPlatform,
  fetchFromGitHub,
  stalwart,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "stalwart-cli";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yvz1Q9kxe4Ieyrpl4laqfPu/vpKkFt7hJpe0BcbZ1bY=";
  };

  cargoHash = "sha256-q3ortZijUN1pxXOCuaJtLq98xiVGJOp71K9AELLAjk4=";

  doCheck = false;

  meta = {
    inherit (stalwart.meta) license homepage maintainers;
    description = "Stalwart mail & collaboration server CLI";
    mainProgram = "stalwart-cli";
    changelog = "https://github.com/stalwartlabs/cli/blob/${finalAttrs.version}/CHANGELOG.md";
  };
})
