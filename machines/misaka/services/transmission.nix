{ config, ... }:
let
  domain = config.networking.domain;
  fqdn = "torrent.${domain}";
  cfg = config.services.transmission;
in
{
  systemd.services = {
    caddy = {
      wants = [ config.systemd.services.transmission.name ];
      serviceConfig.SupplementaryGroups = [ "transmission" ];
    };
  };

  services = {
    transmission = {
      enable = true;
      settings = {
        rpc-enabled = true;
        rpc-bind-address = "unix:${cfg.home}/transmission.sock";
        rpc-socket-mode = "0770";
        rpc-host-whitelist-enabled = true;
        rpc-host-whitelist = fqdn;
        rpc-url = "/";
      };
    };

    caddy.hosts.${fqdn} = {
      reverseProxies."unix/${cfg.home}/transmission.sock" = { };
      basicAuth = {
        user = "david";
        hash = "$2b$05$tFLIJTnvtIVo1Brliz5K7.mZdzbS.xNygXbtzbJd79UNFHld3byT.";
      };
    };
  };
}
