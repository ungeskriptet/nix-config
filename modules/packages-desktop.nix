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
  config = lib.mkIf (cfg.deviceType == "desktop") {
    services.udev.packages = lib.optionals cfg.david.enable (
      with pkgs;
      [
        heimdall.udev
      ]
    );

    programs = {
      gnupg.agent.enable = lib.mkIf cfg.david.enable true;
      ssh = lib.mkIf cfg.enablePlasma {
        enableAskPassword = true;
        askPassword = lib.getExe pkgs.kdePackages.ksshaskpass;
      };
      wireshark = lib.mkIf cfg.david.enable {
        enable = true;
        package = pkgs.wireshark;
        usbmon.enable = true;
      };
    };

    environment.systemPackages =
      with pkgs;
      [
        # keep-sorted start
        bitwarden-desktop
        gimp3-with-plugins
        hunspell
        hunspellDicts.de_DE
        hunspellDicts.en_US
        hunspellDicts.pl_PL
        hyphenDicts.de_DE
        hyphenDicts.en_US
        libreoffice-qt-stable
        scrcpy
        simple-scan
        vlc
        wl-clipboard
        yt-dlp
        # keep-sorted end

        selfPkgs.ttf-ms-win11
      ]
      ++ lib.optionals cfg.david.enable [
        # keep-sorted start
        llvmPackages.clang-tools
        meld
        remmina
        # keep-sorted end

        selfPkgs.kate
      ]
      ++ lib.optionals (cfg.david.profile == "personal") [
        # keep-sorted start
        extract-dtb
        git-repo
        heimdall
        prismlauncher
        qbittorrent
        signal-desktop
        telegram-desktop
        # keep-sorted end

        selfPkgs.magisk-install
        selfPkgs.odin4
        selfPkgs.sigscan
      ];
  };
}
