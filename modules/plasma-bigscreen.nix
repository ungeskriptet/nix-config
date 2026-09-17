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
        sessionPackages = with pkgs; [ kdePackages.plasma-bigscreen ];
        defaultSession = "plasma-bigscreen-wayland";
        autoLogin = {
          user = config.users.users.htpc.name;
          enable = true;
        };
        plasma-login-manager = {
          enable = true;
          settings = {
            Autologin.Relogin = true;
          };
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
        evdev:name:ITE8708 CIR transceiver:*
          KEYBOARD_KEY_80340458=up
          KEYBOARD_KEY_80340459=down
          KEYBOARD_KEY_8034045a=left
          KEYBOARD_KEY_8034045b=right
          KEYBOARD_KEY_8034045c=enter
          KEYBOARD_KEY_8034045d=homepage
          KEYBOARD_KEY_80340483=back
      '';
    };

    xdg.portal.configPackages = with pkgs.kdePackages; [
      plasma-bigscreen
      plasma-workspace
    ];

    programs = {
      kdeconnect.enable = true;
    };

    environment = {
      systemPackages = with pkgs.kdePackages; [
        plasma-bigscreen
        plasma-nm # Required to fix `"org.kde.plasma.networkmanagement" is not installed`
      ];
      plasma6.excludePackages = with pkgs.kdePackages; [
        # keep-sorted start
        ark
        aurorae
        baloo-widgets
        discover
        dolphin
        dolphin-plugins
        elisa
        gwenview
        kate
        khelpcenter
        ktexteditor
        kwin-x11
        okular
        plasma-desktop
        print-manager
        qrca
        spectacle
        # keep-sorted end
      ];
    };
  };
}
