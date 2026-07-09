{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.firefox;
in
{
  imports = [
    ./policies.nix
    ./userchrome.nix
  ];
  options.programs.firefox = {
    defaultProfile = lib.mkOption {
      type = lib.types.str;
      description = "Default Firefox profile";
    };
  };
  config = {
    programs = {
      firefox = {
        enable = true;
        languagePacks = [ "en-US" ];
        defaultProfile = "nix";
        profiles.${cfg.defaultProfile} = {
          search = import ./search { inherit lib pkgs; };
          settings = import ./settings.nix;
        };
      };
    };
  };
}
