{ lib, config, ... }:
let
  cfg = config.nixpkgs;
in
{
  options.nixpkgs.allowPackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "List of packages to allow.";
  };
  config = lib.mkIf (cfg.allowPackages != [ ]) {
    nixpkgs = {
      config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) cfg.allowPackages;
    };
  };
}
