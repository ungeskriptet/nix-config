{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../desktop.nix
  ];

  sops = {
    age.keyFile = lib.mkForce null;
    defaultSopsFile = "${inputs.self}/secrets/secrets-iroha.yaml";
  };

  networking = {
    hostName = "iroha";
    firewall.allowedTCPPorts = [ 3389 ];
    interfaces.enp3s0.wakeOnLan.enable = true;
    supportVpn.interfaceAddress = "192.168.3.8";
  };

  environment = {
    systemPackages = with pkgs; [
      aisleriot
      kdePackages.kmahjongg
      ungoogled-chromium
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
    hashedPassword = "$y$j9T$haZdAnllzjdBEq9pcL3/O1$WKuawTQ2zBm3msc/iZOt7mHcd45adNqu/0iZpommmf/";
    userDescription = "Oma & Opa";
    userName = "omao";
  };

  home-manager.users.omao =
    { ... }:
    {
      imports = [ ../../home/omao.nix ];
      gnome.monitorID = "LEO-0x00000001";
    };
}
