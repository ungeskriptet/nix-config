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

  users.hashedPassword = "$y$j9T$j8duISvdoesAnqbKGzrDa.$pEPB4Dd3boH7.s7PRaLXPuse2K5OyrO2RHUe4vn2Qs.";

  nix = {
    nixPath = [ "nixpkgs=${pkgsPatched}" ];
    settings.max-jobs = 1;
  };
}
