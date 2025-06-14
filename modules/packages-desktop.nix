{ inputs, lib, pkgs, ... }:

let
  selfPkgs = inputs.self.packages.${pkgs.system};
in
{
  services.udev.packages = [ pkgs.edl ];

  programs = {
    thunderbird.enable = true;
    firefox = {
      enable = true;
      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
    ssh = {
      enableAskPassword = true;
      askPassword = lib.getExe pkgs.kdePackages.ksshaskpass;
    };
    wireshark = {
      enable = true;
      usbmon.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    edl
    gimp3-with-plugins
    hunspellDicts.de_DE
    hunspellDicts.en_US
    hunspellDicts.pl_PL
    hyphenDicts.de_DE
    hyphenDicts.en_US
    kdePackages.sddm-kcm
    libreoffice-qt6-fresh
    qbittorrent
    signal-desktop
    vlc
    yt-dlp

    selfPkgs.dumpyara
    selfPkgs.itgmania-zmod
    selfPkgs.odin4
    selfPkgs.outfox-alpha5
    selfPkgs.ttf-ms-win11
  ];
}
