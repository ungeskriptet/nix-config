{ config, lib, ... }:

let
  arch = config.nixpkgs.hostPlatform.system;
in

lib.mkMerge [
  (lib.mkIf (arch == "aarch64-linux") {
    boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
  })
  (lib.mkIf (arch == "x86_64-linux") {
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    programs.virt-manager.enable = true;
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  })
]
