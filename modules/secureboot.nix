{
  lib,
  ...
}:
{
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
}
