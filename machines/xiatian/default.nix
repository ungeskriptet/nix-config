# HP EliteBook 840 G7
{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../desktop.nix
    ../../modules/secureboot.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkDefault true;
    };
  };

  networking.hostName = "xiatian";

  systemd.services.hpkey = {
    description = "Map HP key to Play/Pause";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.kbd}/bin/setkeycodes 68 164"
      ];
    };
  };

  services.fprintd.enable = true;
  security.pam.services =
    lib.genAttrs [ "kde-fingerprint" "polkit-1" "sudo" ] (service: {
      rules.auth.fprintd.settings = {
        max-tries = 15;
        timeout = -1;
      };
    })
    // {
      login.fprintAuth = false;
    };

  users.hashedPassword = "$y$j9T$kHWkTrrHjPj4oK2P6KeaR.$6EFjpr.XBUR9coMEYixfw5LMzzNQ2mj8jiOesYLBU9A";
}
