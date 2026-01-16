{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./services
    ../common.nix
    ../../modules/secureboot.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  sops.defaultSopsFile = "${inputs.self}/secrets/secrets-misaka.yaml";

  security.sudo.wheelNeedsPassword = false;

  users.hashedPassword = "$y$j9T$26VbxoITETjPIDywpNHi71$8oXX3z.uINvjK0zQnzWoY.OBzHB0fA6C07gCVQ66D19";
}
