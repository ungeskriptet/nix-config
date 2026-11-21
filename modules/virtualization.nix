{ config, lib, ... }:
let
  arch = config.nixpkgs.hostPlatform.system;
  cfg = config.nix-config;
in
{
  options.nix-config.enableVirt = lib.mkEnableOption "virtualisation";
  config = lib.mkMerge [
    (lib.mkIf ((cfg.david.enable || cfg.enableVirt) && arch == "x86_64-linux") {
      boot.binfmt = {
        emulatedSystems = [ "aarch64-linux" ];
        preferStaticEmulators = true;
      };
    })
    (lib.mkIf (cfg.enableVirt && arch == "x86_64-linux") {
      programs.virt-manager.enable = true;
      virtualisation = {
        libvirtd.enable = true;
        spiceUSBRedirection.enable = true;
        podman = {
          enable = true;
          dockerCompat = true;
          autoPrune.enable = true;
        };
      };
      networking.firewall.trustedInterfaces = [ "virbr0" ];
    })
  ];
}
