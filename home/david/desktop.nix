{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ./firefox
    ./accounts/desktop.nix
    ../common-allusers.nix
  ];

  sops = {
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
        "${opencloud-desktop}/share/applications/opencloud.desktop"
      ];
    };
  };

  home = {
    file = {
      ".itgmania/Save/LocalProfiles/00000000/GrooveStats.ini" = {
        source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."GrooveStats.ini".path;
        force = true;
      };
    };
    packages = with pkgs; [ opencloud-desktop ];
  };
}
