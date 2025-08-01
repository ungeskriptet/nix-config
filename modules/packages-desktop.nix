{ inputs, lib, pkgs, ... }:

let
  samsung-grab = inputs.samsung-grab.packages.${pkgs.system}.samsung-grab;
  selfPkgs = inputs.self.packages.${pkgs.system};
in
{
  services.udev.packages = with pkgs; [
    android-udev-rules
    edl
    heimdall.udev
  ];

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
      package = pkgs.wireshark;
      usbmon.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    edl
    gimp3-with-plugins
    heimdall
    hunspellDicts.de_DE
    hunspellDicts.en_US
    hunspellDicts.pl_PL
    hyphenDicts.de_DE
    hyphenDicts.en_US
    kdePackages.sddm-kcm
    libreoffice-qt6-fresh
    meld
    prismlauncher
    qbittorrent
    scrcpy
    signal-desktop
    vlc
    yt-dlp

    samsung-grab
    selfPkgs.dumpyara
    selfPkgs.extract-dtb
    selfPkgs.ida-pro
    selfPkgs.itgmania-zmod
    selfPkgs.odin4
    selfPkgs.outfox-alpha5
    selfPkgs.ttf-ms-win11
  ];
}
