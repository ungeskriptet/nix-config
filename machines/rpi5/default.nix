# Raspberry Pi 5
{
  inputs,
  pkgsPatched,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./kernel.nix
    ./networking.nix
    ./services
    ../common.nix
  ];

  sops.defaultSopsFile = "${inputs.self}/secrets/secrets-rpi5.yaml";

  networking.hostName = "rpi5";

  security.sudo.wheelNeedsPassword = false;

  nix = {
    nixPath = [ "nixpkgs=${pkgsPatched}" ];
    settings.max-jobs = 1;
  };
}
