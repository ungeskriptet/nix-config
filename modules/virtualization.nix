{ config, lib, ... }:
let
  arch = config.nixpkgs.hostPlatform.system;
  cfg = config.nix-config;
in
{
  config = lib.mkIf (cfg.enableVirt && arch == "x86_64-linux") {
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
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
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (action.id == "org.libvirt.unix.manage" && subject.isInGroup("wheel")) {
              return polkit.Result.YES;
          }
      });
    '';
    networking.firewall.trustedInterfaces = [ "virbr0" ];
  };
}
