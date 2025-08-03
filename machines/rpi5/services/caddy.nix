{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

let
  baseDomain = vars.baseDomain;

  primRouterDomain = "fritz.${baseDomain}";
  primRouterIP = vars.routerIP;

  secRouterDomain = "7590.${baseDomain}";
  secRouterIP = "192.168.64.15";

  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
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
      admin off
      auto_https off
    '';
    virtualHosts = {
      "https://*.${baseDomain}".extraConfig = ''
        tls ${tlsCert} ${tlsKey}
        redir * https://${baseDomain}/ permanent
      '';
      "https://${baseDomain}".extraConfig = ''
        tls ${tlsCert} ${tlsKey}
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
