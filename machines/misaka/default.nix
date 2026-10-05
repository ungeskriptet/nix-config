{
  lib,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./services
    ../common.nix
  ];

  sops = {
    secrets."dns/tsig".owner = "root";
  };

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
    tailscale-nsupdate = {
      enable = true;
      fqdn = "vpn.${config.networking.fqdn}";
      nameServer = "ns1.${config.networking.domain}";
      tsigKeyFile = config.sops.secrets."dns/tsig".path;
    };
  };

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
