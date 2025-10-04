{ pkgs, ... }:
{
  xdg = {
    enable = true;
    autostart = {
      enable = true;
      entries = with pkgs; [
        "${bitwarden}/share/applications/bitwarden.desktop"
      ];
    };
  };
}
