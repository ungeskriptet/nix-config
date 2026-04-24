# ASRock B550M Pro4 AMD Desktop
{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./home-assistant/ssh.nix
    ../desktop.nix
    ../../modules/minecraft-server.nix
    ../../modules/secureboot.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  sops.defaultSopsFile = ../../secrets/secrets-ryuzu.yaml;

  networking = {
    hostName = "ryuzu";
    interfaces.enp5s0.wakeOnLan.enable = true;
  };

  security = {
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (action.id == "com.bitwarden.Bitwarden.unlock" && subject.isInGroup("wheel")) {
              return polkit.Result.YES;
          }
      });
    '';
    sudo.wheelNeedsPassword = false;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkDefault true;
    };
  };

  users.hashedPassword = "$y$j9T$sMN/eKYxYfh97dxUFDtzf.$sD76l.o1RyplUGb./VV.m3/qgEOrHIh5MkhLoeDpXUB";

  nix-config = {
    david = true;
    enablePlasma = true;
    vr = true;
  };

  home-manager.users.david.config.hm-config.trusted = true;
}
