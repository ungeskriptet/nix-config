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
    "56420291_48fb_488b_8b27_fc2cfd0a46a4" = {
      command = "poweroff";
      name = "Shut Down";
    };
    "7ebd1b53_32d1_4034_9175_7f517a5bbee4" = {
      command = "reboot";
      name = "Restart";
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
