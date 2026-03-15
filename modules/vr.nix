{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.nix-config.vr = lib.mkEnableOption "VR";

  config = lib.mkIf config.nix-config.vr {
    services.wivrn = {
      enable = true;
      openFirewall = true;
      defaultRuntime = true;
      autoStart = false;
    };
    environment.systemPackages = with pkgs; [ wayvr ];
  };
}
