{ lib, config, ... }:
let
  wheelNeedsPassword = config.security.sudo.wheelNeedsPassword;
in
{
  config = {
    security = {
      sudo = {
        enable = false;
      };
      run0 = {
        enable = true;
        sudo-shim.enable = true;
      };
      polkit = {
        extraConfig = lib.mkIf (!wheelNeedsPassword) ''
          polkit.addRule(function(action, subject) {
            if (subject.isInGroup("wheel")) {
              return polkit.Result.YES;
            }
          });
        '';
      };
    };
  };
}
