{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.hm-config;
in
{
  imports = [
    ./plasma
    ./accounts/desktop.nix
  ];

  nix-config = {
    firefox = {
      preset = "david";
      language = "en-US";
    };
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
        "${signal-desktop}/share/applications/signal.desktop"
        "${bitwarden-desktop}/share/applications/bitwarden.desktop"
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
    packages = with pkgs; [ opencloud-desktop ];
  };
}
