{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.nix-config.secureboot;
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
  options.nix-config.secureboot = {
    enable = lib.mkEnableOption "secure boot";
  };
  config = lib.mkIf cfg.enable {
    boot = {
      loader.systemd-boot.enable = lib.mkForce false;
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        autoEnrollKeys = {
          enable = true;
          allowBrickingMyMachine = true;
          includeMicrosoftKeys = false;
        };
        autoGenerateKeys.enable = true;
      };
    };
  };
}
