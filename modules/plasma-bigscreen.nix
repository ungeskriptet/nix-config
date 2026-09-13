{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.desktopManager.plasma-bigscreen;
in
{
  options.services.desktopManager.plasma-bigscreen = {
    enable = lib.mkEnableOption "Plasma Bigscreen";
    hashedPassword = lib.mkOption {
      type = lib.types.str;
      description = ''
        Password hash for the HTPC user
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    boot = {
      loader.timeout = 0;
    };

    users = {
      mutableUsers = false;
      users.htpc = {
        isNormalUser = true;
        description = "HTPC";
        hashedPassword = cfg.hashedPassword;
      };
    };

    services = {
      desktopManager.plasma6.enable = true;
      displayManager = {
        plasma-login-manager.enable = true;
        sessionPackages = with pkgs; [ kdePackages.plasma-bigscreen ];
        defaultSession = "plasma-bigscreen-wayland";
        autoLogin = {
          user = config.users.users.htpc.name;
          enable = true;
        };
      };
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
      logind.settings.Login = {
        HandlePowerKey = "ignore";
        HandlePowerKeyLongPress = "ignore";
        HandleSuspendKey = "ignore";
        HandleSuspendKeyLongPress = "ignore";
      };
      udev.extraHwdb = ''
        evdev:name:PHILIPS MCE USB IR Receiver- Spinel plus Keyboard:*
          KEYBOARD_KEY_c0224=esc
      '';
    };

    xdg.portal.configPackages = with pkgs.kdePackages; [
      plasma-bigscreen
      plasma-nm # Required to fix `"org.kde.plasma.networkmanagement" is not installed`
    ];

    programs = {
      kdeconnect.enable = true;
    };

    environment = {
      systemPackages = with pkgs.kdePackages; [
        plasma-bigscreen
      ];
      plasma6.excludePackages = with pkgs.kdePackages; [
        # keep-sorted start
        discover
        elisa
        gwenview
        kate
        khelpcenter
        okular
        qrca
        # keep-sorted end
      ];
    };
  };
}
