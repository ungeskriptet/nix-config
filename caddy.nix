{ config, pkgs, lib, ... }:

let
  baseDomain = config.homelab.baseDomain;

  primRouterDomain = "fritz.${baseDomain}";
  primRouterIP = config.homelab.routerIP;

  secRouterDomain = "7590.${baseDomain}";
  secRouterIP = "192.168.64.15";

  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
in
{
  networking.firewall = {
    allowedTCPPorts = [ 443 ];
  };

  systemd.services.caddy = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
  };

  services.caddy = {
    enable = true;
    globalConfig = ''
      auto_https disable_certs
    '';
    virtualHosts = {
      "https://${baseDomain}".extraConfig = ''
        tls ${tlsCert} ${tlsKey}
        rewrite /files /files/
        root * /var/lib/caddy/www/
        file_server
        file_server /files/ browse
      '';
      "https://${primRouterDomain}".extraConfig = ''
        tls ${tlsCert} ${tlsKey}
        @lan not remote_ip private_ranges
        respond @lan "Hi! sorry not allowed :(" 403
        reverse_proxy https://${primRouterIP}:443 {
          transport http {
            tls
            tls_insecure_skip_verify
          }
        }
      '';
      "https://${secRouterDomain}".extraConfig = ''
        tls ${tlsCert} ${tlsKey}
        @lan not remote_ip private_ranges
        respond @lan "Hi! sorry not allowed :(" 403
        reverse_proxy https://${secRouterIP}:443 {
          transport http {
            tls
            tls_insecure_skip_verify
          }
        }
      '';
    };
  };
}
