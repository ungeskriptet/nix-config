{
  lib,
  config,
  ...
}:
let
  cfg = config.hm-config.david;
  defaultCommands = {
    "714abe74_3f59_4d50_8ee6_4a61257c54ac" = {
      command = "loginctl unlock-session";
      name = "Unlock Screen";
    };
    "a1b6e3e2_2c9d_42ba_acc3_fb704a8a1892" = {
      command = "loginctl lock-session";
      name = "Lock Screen";
    };
  };
in
{
  config = lib.mkIf cfg.plasma.enable {
    services.kdeconnect = {
      devices = lib.genAttrs [ "david-crownlte" "david-e3q" ] (_: {
        commands = defaultCommands;
      });
    };
  };
}
