{
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./policies.nix ];
  programs = {
    firefox = {
      enable = true;
      languagePacks = [ "en-US" ];
      profiles.nix = {
        search = import ./search { inherit lib pkgs; };
        settings = import ./settings.nix;
      };
    };
  };
}
