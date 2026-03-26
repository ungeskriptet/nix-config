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
    interfaces.enp2s0f1.wakeOnLan.enable = true;
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

  hardware.printers = {
    ensureDefaultPrinter = "HP_LaserJet_P1005";
    ensurePrinters = [
      {
        name = "HP_LaserJet_P1005";
        location = "Wohnzimmer";
        deviceUri = "dnssd://HP%20Drucker%20Wohnzimmer%20%40%20rpi5._ipp._tcp.local/cups?uuid=8a0d0afa-0f33-311b-6967-ba0bf52b6741";
        model = "everywhere";
        description = "HP LaserJet P1005";
      }
    ];
  };

  environment = {
    systemPackages = with pkgs; [ ptyxis ];
    gnome.excludePackages = with pkgs; [
      epiphany
      geary
      gnome-console
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
}
