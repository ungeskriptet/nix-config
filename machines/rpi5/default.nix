# Raspberry Pi 5
{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./services
  ];

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

  nix-config = {
    david = {
      enable = true;
      profile = "personal";
    };
    networking = {
      enable = true;
      interface = "end0";
      lanDomain = "fritz.box";
      gatewayIpv4 = "192.168.64.1";
      gatewayIpv6 = "fd64::464e:6dff:fef4:47b";
      ipv6InterfaceId = "::2";
      lanIpv6.address = "fd64::2";
      lanIpv4 = {
        address = "192.168.64.2";
        cidr = 24;
      };
    };
  };

  home-manager.users.david.config.hm-config.trusted = true;
}
