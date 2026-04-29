{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./services
    ../common.nix
  ];

  sops.defaultSopsFile = "${inputs.self}/secrets/secrets-misaka.yaml";

  security.sudo.wheelNeedsPassword = false;

  users.hashedPassword = "$y$j9T$26VbxoITETjPIDywpNHi71$8oXX3z.uINvjK0zQnzWoY.OBzHB0fA6C07gCVQ66D19";

  nix-config = {
    david = true;
    secureboot.enable = true;
    hardware = {
      enable = true;
      platform = "intel";
    };
  };
}
