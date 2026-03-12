{ pkgs, ... }:
{
  xdg.autostart = {
    enable = true;
    entries =
      let
        opencloud = pkgs.runCommand "opencloud.desktop" { } ''
          substitute \
            ${pkgs.opencloud-desktop}/share/applications/opencloud.desktop $out \
            --replace-fail " --showsettings" ""
        '';
      in
      [
        opencloud
      ];
  };
}
