{ config, lib, pkgs, inputs, ... }:

let
  lanIP = config.homelab.lanIP;
  routerIP = config.homelab.routerIP;
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+HHP+nC6vrDwqEbTgiNhFnaqD3WEBgZMq7FUPWV0Ls main@bitwarden"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOyckAtDOO5eRG9xYOzRWLNnGtBCq/Om/sLPEFLBtT8 david@key4"
  ];
in
{
  sops = {
    defaultSopsFile = "${inputs.self}/secrets/secrets.yaml";
    age.keyFile = "/root/.config/sops/age/keys.txt";
    secrets."users/david".neededForUsers = true;
    secrets."users/david".owner = "root";
  };

  boot.kernelParams = [ "video=HDMI-A-1:1280x720M@60" ];

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
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
    unzip
    zip
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

  users = {
    mutableUsers = false;
    users.david = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."users/david".path;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = pubKeys;
    };
    users.root.openssh.authorizedKeys.keys = pubKeys;
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 8*1024;
    randomEncryption.enable = true;
  }];
  zramSwap.enable = true;

  imports = [
    ./acme.nix
    ./adguardhome.nix
    ./caddy.nix
    ./esphome.nix
    ./home-assistant.nix
    ./mollysocket.nix
    ./networking.nix
    ./nextcloud.nix
    ./ntfy-sh.nix
    ./postgresql.nix
    ./samfirm-js.nix
    ./samsung-update-bot.nix
    ./soju.nix
    ./stalwart-mail.nix
    ./vars.nix
    ./vaultwarden.nix
    ./wireguard.nix
    ./yuribot.nix
  ];

  system.stateVersion = "25.05";
  system.nixos.tags = let
    cfg = config.boot.loader.raspberryPi;
  in [
    "raspberry-pi-${cfg.variant}"
    cfg.bootloader
    config.boot.kernelPackages.kernel.version
  ];
}
