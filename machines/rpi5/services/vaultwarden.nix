{ config, vars, ... }:

let
  domain = "bitwarden.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
in
{
  sops.secrets."vaultwarden/env".owner = "vaultwarden";

  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  systemd.services.vaultwarden = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
    requires = [ "postgresql.target" ];
    after = [ "postgresql.target" ];
  };

  services.caddy.virtualHosts = {
    "https://${domain}" = {
      extraConfig = ''
        tls ${tlsCert} ${tlsKey}
        @lan {
          path /admin*
          not remote_ip private_ranges
        }
        respond @lan "Hi! sorry not allowed :(" 403
        reverse_proxy https://${domain}:8082
      '';
    };
  };

  services.postgresql = {
    ensureDatabases = [ "vaultwarden" ];
    ensureUsers = [
      {
        name = "vaultwarden";
        ensureDBOwnership = true;
      }
    ];
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    environmentFile = config.sops.secrets."vaultwarden/env".path;
    config = {
      DATABASE_URL = "postgresql:///vaultwarden?host=/run/postgresql";
      DOMAIN = "https://${domain}";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8082;
      ROCKET_TLS = ''{certs="${tlsCert}",key="${tlsKey}"}'';
      SMTP_HOST = baseDomain;
      SMTP_FROM = "vaultwarden@${baseDomain}";
      SMTP_USERNAME = "vaultwarden";
      SMTP_SECURITY = "force_tls";
      SMTP_PORT = 465;
      ENABLE_WEBSOCKET = true;
      IP_HEADER = "X-Forwarded-For";
      HTTP_REQUEST_BLOCK_NON_GLOBAL_IPS = false;
    };
  };
}
