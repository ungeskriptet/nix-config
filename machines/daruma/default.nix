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
    ../modules/secureboot.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  sops.defaultSopsFile = "${inputs.self}/secrets/secrets-daruma.yaml";

  networking.hostName = "daruma";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = lib.mkDefault true;

  programs.pixeldrain-cli.enable = lib.mkForce false;

  i18n.defaultLocale = lib.mkForce "de_DE.UTF-8";

  users.userName = "grazyna";
  users.userDescription = "Grazyna";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = config.users.userName;

  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplipWithPlugin ];
  };
}
