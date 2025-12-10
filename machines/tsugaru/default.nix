# Acer Aspire V3-771
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
    defaultSopsFile = "${inputs.self}/secrets/secrets-tsugaru.yaml";
  };

  networking = {
    hostName = "tsugaru";
    firewall.allowedTCPPorts = [ 3389 ];
  };

  boot = {
    consoleLogLevel = 0;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
    ];
    initrd.verbose = false;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = lib.mkDefault true;
    loader.timeout = 0;
    plymouth.enable = true;
  };

  services = {
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = config.users.userName;
      gdm.enable = true;
    };
    desktopManager.gnome.enable = true;
  };

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-music
    gnome-tour
  ];

  systemd.services.gnome-remote-desktop = {
    wantedBy = [ "graphical.target" ];
  };

  programs = {
    dconf.enable = true;
  };

  i18n = {
    defaultLocale = lib.mkForce "pl_PL.UTF-8";
    extraLocaleSettings = lib.mkForce (
      lib.genAttrs [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_NAME"
        "LC_MEASUREMENT"
        "LC_NUMERIC"
        "LC_MONETARY"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"
      ] (var: "pl_PL.UTF-8")
    );
  };

  users = {
    hashedPassword = "$y$j9T$zVs7BkMuIfSOpUDWx5WYS/$8Mqb4/741mi/cpECCoIN883LNL6zs6eiGt/N9o5wydA";
    userName = "kamil";
    userDescription = "Kamil";
  };

  home-manager.users.kamil = lib.mkForce ../../home/kamil;

  nix-config.enablePlasma = false;
  nix-config.david = false;
}
