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
    ./wireguard.nix
    ../desktop.nix
    ../../modules/secureboot.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  sops = {
    age.keyFile = lib.mkForce null;
    defaultSopsFile = "${inputs.self}/secrets/secrets-iroha.yaml";
  };

  networking = {
    hostName = "iroha";
    firewall.allowedTCPPorts = [ 3389 ];
  };

  boot = {
    consoleLogLevel = 0;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkDefault true;
      timeout = 0;
    };
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
      aisleriot
      gnome-mahjongg
      ungoogled-chromium
    ];
    gnome.excludePackages = with pkgs; [
      epiphany
      geary
      gnome-music
      gnome-tour
    ];
  };

  systemd.services.gnome-remote-desktop = {
    wantedBy = [ "graphical.target" ];
  };

  programs = {
    dconf.enable = true;
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

  nix-config = {
    enablePlasma = false;
    david = false;
  };
}
