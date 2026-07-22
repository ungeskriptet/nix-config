{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.nix-config.firefox;
in
{
  imports = [
    ./policies.nix
    ./userchrome.nix
    ./settings.nix
  ];
  options.nix-config.firefox = {
    preset = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "default"
          "david"
        ]
      );
      description = "Preset to use for the Firefox configuration";
      default = null;
    };
    language = lib.mkOption {
      type = lib.types.str;
      description = "Firefox Language";
    };
    defaultProfile = lib.mkOption {
      type = lib.types.str;
      description = "Default Firefox profile";
      readOnly = true;
    };
  };
  config = lib.mkIf (cfg.preset != null) (
    lib.mkMerge [
      {
        nix-config.firefox.defaultProfile = "nix";
        programs = {
          firefox = {
            enable = true;
            languagePacks = [ cfg.language ];
          };
        };
      }
      (lib.mkIf (cfg.preset == "david") {
        programs.firefox = {
          profiles.${cfg.defaultProfile} = {
            search = import ./search { inherit lib pkgs; };
          };
        };
      })
    ]
  );
}
