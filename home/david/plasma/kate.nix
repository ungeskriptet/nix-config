{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.hm-config.plasma;
  pyrefly = lib.getExe pkgs.pyrefly;
  rust-analyzer = lib.getExe pkgs.rust-analyzer;
  nixd = lib.getExe pkgs.nixd;
in
{
  config = lib.mkIf cfg.enable {
    programs.plasma = {
      configFile = {
        katerc = {
          General."Show Menu Bar" = true;
          lspclient.AllowedServerCommandLines = lib.concatStringsSep "," [
            "${pyrefly} lsp"
            nixd
            rust-analyzer
          ];
        };
      };
    };

    home.file.".config/kate/lspclient/settings.json" = {
      force = true;
      text = builtins.toJSON {
        servers = {
          nix = {
            command = [ "nixd" ];
            highlightingModeRegex = "^Nix$";
          };
          python = {
            command = [
              "pyrefly"
              "lsp"
            ];
            highlightingModeRegex = "^Python$";
          };
        };
      };
    };

  };
}
