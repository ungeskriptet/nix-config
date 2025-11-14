{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nix-config;
  selfPkgs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  services.udev.packages = lib.optionals cfg.david (
    with pkgs;
    [
      edl
      heimdall.udev
    ]
  );

  programs = {
    thunderbird.enable = true;
    ssh = lib.mkIf cfg.enablePlasma {
      enableAskPassword = true;
      askPassword = lib.getExe pkgs.kdePackages.ksshaskpass;
    };
    wireshark = lib.mkIf cfg.david {
      enable = true;
      package = pkgs.wireshark;
      usbmon.enable = true;
    };
  };

  environment.systemPackages =
    with pkgs;
    [
      bitwarden-desktop
      firefox
      gimp3-with-plugins
      hunspell
      hunspellDicts.de_DE
      hunspellDicts.en_US
      hunspellDicts.pl_PL
      hyphenDicts.de_DE
      hyphenDicts.en_US
      kdePackages.sddm-kcm
      libreoffice-qt6-fresh
      scrcpy
      signal-desktop
      vlc
      xournalpp
      yt-dlp

      selfPkgs.ttf-ms-win11
    ]
    ++ lib.optionals cfg.david [
      edl
      extract-dtb
      heimdall
      meld
      nixd
      prismlauncher
      qbittorrent

      selfPkgs.ida-pro
      selfPkgs.itgmania-zmod
      selfPkgs.odin4
      selfPkgs.outfox-alpha5
      selfPkgs.pmbootstrap-git
    ];
}
