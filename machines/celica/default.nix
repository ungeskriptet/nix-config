{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./wireguard.nix
    ../desktop.nix
  ];

  sops = {
    age.keyFile = lib.mkForce null;
    defaultSopsFile = "${inputs.self}/secrets/secrets-celica.yaml";
  };

  networking = {
    hostName = "celica";
    firewall.allowedTCPPorts = [ 3389 ];
    interfaces.enp5s0.wakeOnLan.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      aisleriot
      kdePackages.kmahjongg
    ];
  };

  nix-config = {
    gnome.enable = true;
    secureboot.enable = true;
    hardware = {
      enable = true;
      platform = "intel";
    };
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
      sops.defaultSopsFile = ../../secrets/secrets-martin.yaml;
      home = {
        username = config.users.userName;
        homeDirectory = "/home/${config.users.userName}";
      };
    };
}
