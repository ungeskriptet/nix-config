{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.hm-config.david;
in
{
  options.hm-config.david.desktop = {
    enable = lib.mkEnableOption "desktop configs";
  };

  config = lib.mkIf cfg.desktop.enable {
    nix-config = {
      firefox = {
        preset = "david";
        language = "en-US";
      };
    };

    programs.firefox = {
      package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.firefox-patched;
    };

    sops = lib.mkIf (cfg.profile == "personal") {
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
          (lib.mkIf (cfg.profile == "personal") "${signal-desktop}/share/applications/signal.desktop")
        ];
      };
    };

    home = {
      file = {
        ".itgmania/Save/LocalProfiles/00000000/GrooveStats.ini" = lib.mkIf (cfg.profile == "personal") {
          source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."GrooveStats.ini".path;
          force = true;
        };
      };
    };
  };
}
