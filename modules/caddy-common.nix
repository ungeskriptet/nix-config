{ lib, config, ... }:
let
  cfg = config.services.caddy;
  domain = config.networking.domain;
in
{
  config = lib.mkIf cfg.enable {
    services = {
      caddy = {
        globalConfig = ''
          auto_https disable_certs
        '';
      };
    };

    security.acme.certs.${domain}.reloadServices = [ "caddy.service" ];

    networking = {
      firewall = {
        allowedTCPPorts = [
          80
          443
        ];
        allowedUDPPorts = [ 443 ];
      };
    };
  };
}
