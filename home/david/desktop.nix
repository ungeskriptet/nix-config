{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.hm-config;
in
{
  options.hm-config = {
    desktop = lib.mkEnableOption "desktop configs";
  };

  config = {
    nix-config = {
      firefox = {
        preset = "david";
        language = "en-US";
      };
    };

    programs.firefox = {
      package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.firefox-patched;
    };

    sops = lib.mkIf cfg.trusted {
      secrets."groovestats/apikey" = { };
      templates."GrooveStats.ini".content = ''
        [GrooveStats]
        ApiKey=${config.sops.placeholder."groovestats/apikey"}
        IsPadPlayer=1
      '';
    };

    xdg = {
      enable = true;
      autostart = {
        enable = true;
        entries = with pkgs; [
          (lib.mkIf cfg.trusted "${signal-desktop}/share/applications/signal.desktop")
        ];
      };
    };

    home = {
      file = {
        ".itgmania/Save/LocalProfiles/00000000/GrooveStats.ini" = lib.mkIf cfg.trusted {
          source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."GrooveStats.ini".path;
          force = true;
        };
      };
    };
  };
}
