{
  lib,
  config,
  ...
}:
let
  cfg = config.hm-config;
in
{
  accounts.email.accounts = lib.mkIf cfg.trusted {
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
