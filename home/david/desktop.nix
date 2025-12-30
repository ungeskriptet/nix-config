{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ./firefox
    ./plasma
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
      entries =
        with pkgs;
        let
          opencloud = runCommand "opencloud.desktop" { } ''
            substitute \
              ${opencloud-desktop}/share/applications/opencloud.desktop $out \
              --replace-fail " --showsettings" ""
          '';
        in
        [
          "${signal-desktop}/share/applications/signal.desktop"
          opencloud
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
