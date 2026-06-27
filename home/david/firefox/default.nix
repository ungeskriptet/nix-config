{
  lib,
  pkgs,
  ...
}:
{
  programs = {
    firefox = {
      enable = true;
      languagePacks = [
        "en-US"
        "de"
        "pl"
      ];
      profiles.nix = {
        search = import ./search { inherit lib pkgs; };
        settings = import ./settings.nix;
      };
      policies = import ./policies.nix;
    };
  };
}
