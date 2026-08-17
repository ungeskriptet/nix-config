# Raspberry Pi 5
{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./services
    ../common.nix
  ];

  sops.defaultSopsFile = "${inputs.self}/secrets/secrets-rpi5.yaml";

  networking.hostName = "rpi5";

  security.sudo.wheelNeedsPassword = false;

  users.hashedPassword = "$y$j9T$j8duISvdoesAnqbKGzrDa.$pEPB4Dd3boH7.s7PRaLXPuse2K5OyrO2RHUe4vn2Qs.";

  boot = {
    binfmt.emulatedSystems = [ "x86_64-linux" ];
    kernelPackages = pkgs.linuxPackagesFor (
      inputs.nixos-raspberrypi-kernel.packages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_rpi5.kernel.overrideAttrs
        (prev: {
          passthru = prev.passthru // {
            buildDTBs = true;
            target = "Image";
          };
        })
    );
  };

  nix.settings.max-jobs = 1;

  nix-config.david = true;

  home-manager.users.david.config.hm-config.trusted = true;
}
