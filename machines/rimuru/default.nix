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
    defaultSopsFile = "${inputs.self}/secrets/secrets-rimuru.yaml";
  };

  networking = {
    hostName = "rimuru";
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
    hashedPassword = "$y$j9T$9EZBwL3aSCu0rlAFngWtP1$R.F4i3PyIRg0sA9PqTYkxSms6TmQ.nQ3qhoHWGn/KY2";
    userDescription = "Grazyna";
    userName = "grazyna";
  };

  home-manager.users.grazyna =
    { ... }:
    {
      imports = [ ../../home/grazyna.nix ];
      gnome.monitorID = "CMN-0x00000000";
    };

  nix-config = {
    enablePlasma = false;
    david = false;
  };
}
