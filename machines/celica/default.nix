{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    firewall.allowedTCPPorts = [ 3389 ];
    interfaces.enp5s0.wakeOnLan.enable = true;
    supportVpn.interfaceAddress = "192.168.3.9";
  };

  environment = {
    systemPackages = with pkgs; [
      aisleriot
      kdePackages.kmahjongg
    ];
  };

  nix-config = {
    deviceType = "desktop";
    gnome.enable = true;
    secureboot.enable = true;
    hardware = {
      enable = true;
      platform = "intel";
    };
  };

  services = {
    flatpak.enable = true;
    gnome.gnome-software.enable = true;
  };

  i18n = {
    defaultLocale = lib.mkForce "de_DE.UTF-8";
    extraLocaleSettings = lib.mkForce { };
  };

  users = {
    hashedPassword = "$y$j9T$qoNyapIdJxd6IOHVwwLOG/$elHEnRBramMw8.c6.WJeYKc/C/NDUHhqUbrD3WFNpH2";
    userDescription = "Martin";
    userName = "martin";
  };

  home-manager.users.${config.users.userName} =
    { ... }:
    {
      imports = [
        ../../home/gnome.nix
        ../../home/common.nix
      ];
      gnome.monitorID = "SAM-H9XZA06953";
      nix-config = {
        firefox = {
          preset = "default";
          language = "de";
        };
        thunderbird = {
          preset = "default";
          language = "de";
        };
      };
      home = {
        username = config.users.userName;
        homeDirectory = "/home/${config.users.userName}";
      };
    };
}
