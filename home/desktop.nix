{ pkgs, ... }:
{
  xdg = {
    enable = true;
    autostart = {
      enable = true;
      entries = with pkgs; [
        "${bitwarden-desktop}/share/applications/bitwarden.desktop"
      ];
    };
  };
}
