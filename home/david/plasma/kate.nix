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
in
{
  config = lib.mkIf cfg.enable {
    programs.plasma = {
      configFile = {
        katerc = {
          General."Show Menu Bar" = true;
          lspclient.AllowedServerCommandLines = lib.concatStringsSep "," [
            "${pyrefly} lsp"
            rust-analyzer
          ];
        };
      };
    };

    home.file.".config/kate/lspclient/settings.json" = {
      force = true;
      text = builtins.toJSON {
        servers = {
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
