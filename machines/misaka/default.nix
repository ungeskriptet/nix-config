{
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./services
  ];

  boot = {
    kernelModules = [ "hid-spinelplus" ];
    kernelPatches = [
      {
        name = "spinelplus";
        patch = ./patches/0001-HID-spinelplus-add-driver-for-Spinel-plus-remotes.patch;
        structuredExtraConfig = {
          HID_SPINELPLUS = lib.kernel.module;
        };
      }
    ];
  };

  services = {
    desktopManager.plasma-bigscreen = {
      enable = true;
      hashedPassword = "$y$j9T$eufLcVdOXLkn8dbB1IQJQ1$e5V3hclkdIjJCzeQNwCDgGzM3jCh7hqr7miZlfBRIG8";
    };
  };

  security.sudo.wheelNeedsPassword = false;

  users.hashedPassword = "$y$j9T$26VbxoITETjPIDywpNHi71$8oXX3z.uINvjK0zQnzWoY.OBzHB0fA6C07gCVQ66D19";

  networking.interfaces.eno1.wakeOnLan.enable = true;

  nix-config = {
    secureboot.enable = true;
    david = {
      enable = true;
      profile = "personal";
    };
    hardware = {
      enable = true;
      platform = "oldintel";
    };
    networking = {
      enable = true;
      interface = "eno1";
      lanDomain = "fritz.box";
      gatewayIpv4 = "192.168.64.1";
      gatewayIpv6 = "fd64::464e:6dff:fef4:47b";
      ipv6InterfaceId = "::3";
      lanIpv4 = {
        address = "192.168.64.3";
        cidr = 24;
      };
      dns = [
        # Use IPv6 DNS from router advertisemets
        "192.168.64.2"
      ];
    };
  };
}
