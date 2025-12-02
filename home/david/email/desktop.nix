{
  lib,
  pkgs,
  config,
  ...
}:
{
  accounts.email.accounts = {
    myEmail.thunderbird.enable = true;
    mainlining.thunderbird.enable = true;
  };

  programs.thunderbird = {
    enable = true;
    profiles."Default".isDefault = true;
  };
}
