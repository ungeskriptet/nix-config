{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.programs.silverfort;
  selfPkgs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.programs.silverfort = {
    enable = lib.mkEnableOption "Silverfort";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ selfPkgs.silverfort-client ];
  };
}
