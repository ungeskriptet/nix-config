# ASRock B550M Pro4 AMD Desktop

{ inputs, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../desktop.nix
  ];

  sops.defaultSopsFile = "${inputs.self}/secrets/secrets-ryuzu.yaml";

  networking.hostName = "ryuzu";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = lib.mkDefault true;

  security.sudo.wheelNeedsPassword = false;
}
