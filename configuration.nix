{ config, lib, pkgs, inputs, ... }:

let
  linux_rpi5 = pkgs.linux_rpi4.override {
    rpiVersion = 5;
    argsOverride.defconfig = "bcm2712_defconfig";
  };
in
{
  sops = {
    defaultSopsFile = "${inputs.self}/secrets/secrets.yaml";
    age.keyFile = "/root/.config/sops/age/keys.txt";
  };

  boot = {
    kernelPackages = lib.mkDefault (pkgs.linuxPackagesFor linux_rpi5);
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = "rpi5";
    nameservers = [ "127.0.0.1" ];
    tempAddresses = "disabled";
    dhcpcd = {
      enable = true;
      extraConfig = ''
        slaac private
      '';
    };
    firewall.enable = true;
  };

  environment.systemPackages = with pkgs; [
    dig
    file
    git
    htop
    inetutils
    ripgrep
    sops
    tmux
  ];

  programs.vim.enable = true;
  programs.vim.defaultEditor = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "de";

  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  security.sudo.wheelNeedsPassword = false;
  security.sudo.extraConfig = "Defaults env_keep += EDITOR";

  sops.secrets."users/david".owner = "root";

  users = {
    mutableUsers = false;
    users."david" = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."users/david".path;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzOD/JwODH9SQJAuXK5vCquEpRNmlrxlhvjEbY4EwaZ u0_a179@localhost"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+HHP+nC6vrDwqEbTgiNhFnaqD3WEBgZMq7FUPWV0Ls main@bitwarden"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJ3MjkH9crZPcA8TG/DkYiwjwGTdIcopRJF1nQaOMAo david@rpi5"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOyckAtDOO5eRG9xYOzRWLNnGtBCq/Om/sLPEFLBtT8 david@key4"
      ];
    };
  };

  imports = [
    ./acme.nix
    ./adguardhome.nix
    ./caddy.nix
    ./esphome.nix
    ./home-assistant.nix
    ./mollysocket.nix
    ./nextcloud.nix
    ./ntfy-sh.nix
    ./postgresql.nix
    ./soju.nix
    ./samsung-update-bot.nix
    ./stalwart-mail.nix
    ./vaultwarden.nix
    ./vars.nix
    ./yuribot.nix
  ];

  system.stateVersion = "25.05";
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
}
