{
  inputs,
  lib,
  pkgs,
  ...
}:
let
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
    extract-dtb
    firefox
    gimp3-with-plugins
    heimdall
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
    hunspellDicts.pl_PL
    hyphenDicts.de_DE
    hyphenDicts.en_US
    kdePackages.sddm-kcm
    libreoffice-qt6-fresh
    meld
    nixd
    prismlauncher
    qbittorrent
    scrcpy
    signal-desktop
    vlc
    xournalpp
    yt-dlp

    selfPkgs.ida-pro
    selfPkgs.itgmania-zmod
    selfPkgs.odin4
    selfPkgs.outfox-alpha5
    selfPkgs.pmbootstrap-git
    selfPkgs.ttf-ms-win11
  ];
}
