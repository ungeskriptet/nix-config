# Acer Aspire E5-574G
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

  networking = {
    hostName = "daruma";
    firewall.allowedTCPPorts = [ 3389 ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkDefault true;
    };
  };

  i18n.defaultLocale = lib.mkForce "de_DE.UTF-8";

  users = {
    hashedPassword = "$y$j9T$9EZBwL3aSCu0rlAFngWtP1$R.F4i3PyIRg0sA9PqTYkxSms6TmQ.nQ3qhoHWGn/KY2";
    userDescription = "Grazyna";
    userName = "grazyna";
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = config.users.userName;
  };
}
