{ lib, config, ... }:
let
  cfg = config.services.caddy;
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

    security.acme.defaults.reloadServices = [ "caddy.service" ];

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
