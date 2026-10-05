{
  config,
  lib,
  ...
}:
let
  cfg = config.nix-config;
in
{
  options.nix-config = {
    fingerprint = lib.mkEnableOption "fingerprint authenticaion";
  };

  config = lib.mkIf cfg.fingerprint {
    services = {
      fprintd.enable = true;
    };
    security = {
      sudo.wheelNeedsPassword = lib.mkForce true;
      pam.services =
        lib.genAttrs [ "kde-fingerprint" "polkit-1" "sudo" ] (service: {
          rules.auth.fprintd.settings = {
            max-tries = -1;
            timeout = -1;
          };
        })
        // {
          login.fprintAuth = false;
        };
    };
  };
}
