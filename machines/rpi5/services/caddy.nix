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
            david $2b$05$9l2gtUS.pMa6brsBOfUl7eGOwVtifl0dbcEpg4mcr6CsG2Fk4Aqxi
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

  services.homer.settings.services = [
    {
      items = [
        {
          name = "FRITZ!Box 6660 Cable";
          subtitle = "Primary internet gateway";
          url = "https://${primRouterFqdn}";
          logo = "https://cdn.jsdelivr.net/gh/selfhst/icons@master/svg/fritz.svg";
        }
      ];
    }
    {
      items = [
        {
          name = "FRITZ!Box 7590";
          subtitle = "Secondary router";
          url = "https://${secRouterFqdn}";
          logo = "https://cdn.jsdelivr.net/gh/selfhst/icons@master/svg/fritz.svg";
        }
      ];
    }
  ];
}
