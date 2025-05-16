{ config, lib, options, ... }:

{
  options.homelab.baseDomain = lib.mkOption {
    type = lib.types.str;
  };

  config.homelab.baseDomain = "david-w.eu";
}
