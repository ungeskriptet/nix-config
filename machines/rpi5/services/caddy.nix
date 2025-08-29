{
  config,
  ...
}:
let
  domain = config.networking.domain;
  primRouterFqdn = "fritz.${domain}";
  primRouterIP = config.networking.gatewayIP;
  secRouterFqdn = "7590.${domain}";
  secRouterIP = config.networking.secGatewayIP;
in
{
  networking.firewall = {
    allowedTCPPorts = [ 443 ];
  };

  sops.secrets."caddy/basicauth".owner = "caddy";

  systemd.services.caddy = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
  };

  services.caddy = {
    enable = true;
    globalConfig = ''
      auto_https off
    '';
    virtualHosts = {
      "https://*.${domain}".extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
        redir * https://${domain}/ permanent
      '';
      "https://${domain}".extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
        root * /var/lib/caddy/www/
        file_server

        redir /files /files/ permanent
        file_server /files/* browse

        redir /private /private/ permanent
        handle_path /private/* {
          basic_auth {
            import ${config.sops.secrets."caddy/basicauth".path}
          }
          root * /var/lib/caddy/private
          file_server browse
        }
      '';
      "https://${primRouterFqdn}".extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
        @lan not remote_ip private_ranges
        respond @lan "Hi! sorry not allowed :(" 403
        reverse_proxy https://${primRouterIP}:443 {
          transport http {
            tls
            tls_insecure_skip_verify
          }
        }
      '';
      "https://${secRouterFqdn}".extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
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
