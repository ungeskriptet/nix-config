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
  ];

  sops.defaultSopsFile = "${inputs.self}/secrets/secrets-xiatian.yaml";

  networking.hostName = "xiatian";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = lib.mkDefault true;

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
}
