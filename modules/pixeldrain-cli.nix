{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.pixeldrain-cli;
  selfPkgs = inputs.self.packages.${pkgs.system};
in
{
  options.programs.pixeldrain-cli = {
    enable = lib.mkEnableOption "pixeldrain-cli";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (selfPkgs.pixeldrain-cli.override {
        apiKeyFile = config.sops.secrets."pixeldrain/apikey".path;
      })
    ];
    sops = {
      secrets."pixeldrain/apikey".owner = "root";
      secrets."pixeldrain/apikey".mode = "0444";
    };
  };
}
