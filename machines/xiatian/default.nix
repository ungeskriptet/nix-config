# HP EliteBook 840 G7
{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [ etterna ];

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
    david = true;
    fingerprint = true;
    secureboot.enable = true;
    hardware = {
      enable = true;
      platform = "oldintel";
    };
  };

  home-manager.users.david.config.hm-config.trusted = true;
}
