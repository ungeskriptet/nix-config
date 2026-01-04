# HP EliteBook 840 G7
{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../desktop.nix
    ../../modules/secureboot.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkDefault true;
    };
  };

  networking.hostName = "xiatian";

  services = {
    fprintd.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = config.users.userName;
    };
    udev.extraHwdb = ''
      evdev:input:b0011v0001p0001eAB83*
        KEYBOARD_KEY_68=playpause
    '';
  };

  security.pam.services =
    lib.genAttrs [ "kde-fingerprint" "polkit-1" "sudo" ] (service: {
      rules.auth.fprintd.settings = {
        max-tries = 15;
        timeout = -1;
      };
    })
    // {
      login.fprintAuth = false;
    };

  users.hashedPassword = "$y$j9T$kHWkTrrHjPj4oK2P6KeaR.$6EFjpr.XBUR9coMEYixfw5LMzzNQ2mj8jiOesYLBU9A";
}
