{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.nix-config.gnome;
in
{
  imports = [ ./users.nix ];

  options.nix-config.gnome = {
    enable = lib.mkEnableOption "custom GNOME configs";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      consoleLogLevel = 0;
      kernelParams = [
        "quiet"
        "udev.log_level=3"
      ];
      loader.timeout = 0;
      initrd.verbose = false;
      plymouth.enable = true;
    };

    services = {
      displayManager = {
        autoLogin = {
          enable = true;
          user = config.users.userName;
        };
        gdm.enable = true;
      };
      desktopManager.gnome.enable = true;
      usbmuxd.enable = true;
    };

    environment = {
      systemPackages = with pkgs; [
        file-roller
        ptyxis
      ];
      gnome.excludePackages = with pkgs; [
        decibels
        epiphany
        geary
        gnome-console
        gnome-music
        gnome-tour
      ];
    };

    systemd.services.gnome-remote-desktop = {
      wantedBy = [ "graphical.target" ];
    };

    programs = {
      dconf.enable = true;
      firefox.enable = true;
      thunderbird.enable = true;
    };
  };
}
