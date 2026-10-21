{
  lib,
  config,
  ...
}:
let
  cfg = config.hm-config.david;
in
{
  accounts.email.accounts = lib.mkIf (cfg.profile == "personal") {
    myEmail.thunderbird.enable = true;
    mainlining.thunderbird.enable = true;
  };

  nix-config = {
    thunderbird = {
      preset = "david";
      language = "en-US";
    };
  };
}
