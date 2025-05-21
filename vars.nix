{ config, lib, options, ... }:

{
  options.homelab = {
    baseDomain = lib.mkOption { type = lib.types.str; };
    lanDomain = lib.mkOption { type = lib.types.str; };
    lanIP = lib.mkOption { type = lib.types.str; };
    routerIP = lib.mkOption { type = lib.types.str; };
  };

  config.homelab = {
    baseDomain = "david-w.eu";
    lanDomain = "fritz.box";
    lanIP = "192.168.64.2";
    routerIP = "192.168.64.1";
  };
}
