# HP EliteBook 840 G7
{
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services = {
    displayManager.autoLogin = {
      enable = true;
      user = config.users.userName;
    };
    udev.extraHwdb = ''
      evdev:input:b0011v0001p0001eAB83*
        KEYBOARD_KEY_68=playpause
    '';
  };

  users.hashedPassword = "$y$j9T$kHWkTrrHjPj4oK2P6KeaR.$6EFjpr.XBUR9coMEYixfw5LMzzNQ2mj8jiOesYLBU9A";

  nix-config = {
    deviceType = "desktop";
    fingerprint = true;
    secureboot.enable = true;
    david = {
      enable = true;
      profile = "personal";
    };
    hardware = {
      enable = true;
      platform = "oldintel";
    };
  };

  home-manager.users.david = {
    hm-config.trusted = true;
    programs.plasma = {
      configFile = {
        kcminputrc."Libinput/1739/52744/SYNA30B3:00 06CB:CE08" = {
          MiddleButtonEmulation = true;
          NaturalScroll = true;
        };
      };
    };
  };
}
