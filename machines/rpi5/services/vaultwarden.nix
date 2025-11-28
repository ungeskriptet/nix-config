{ config, ... }:
let
  fqdn = "bitwarden.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets."vaultwarden/env".owner = "vaultwarden";

  networking.hosts."::1" = [ fqdn ];
  networking.hosts."127.0.0.1" = [ fqdn ];

  systemd.services.vaultwarden = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
    requires = [ "postgresql.target" ];
    after = [ "postgresql.target" ];
  };

  services.caddy.virtualHosts = {
    "https://${fqdn}" = {
      extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
        @lan {
          path /admin*
          not remote_ip private_ranges
        }
        respond @lan "Hi! sorry not allowed :(" 403
        reverse_proxy https://${fqdn}:8082
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
      DOMAIN = "https://${fqdn}";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8082;
      ROCKET_TLS = ''{certs="${config.acme.tlsCert}",key="${config.acme.tlsKey}"}'';
      SMTP_HOST = domain;
      SMTP_FROM = "vaultwarden@${domain}";
      SMTP_USERNAME = "vaultwarden";
      SMTP_SECURITY = "force_tls";
      SMTP_PORT = 465;
      ENABLE_WEBSOCKET = true;
      IP_HEADER = "X-Forwarded-For";
      HTTP_REQUEST_BLOCK_NON_GLOBAL_IPS = false;
    };
  };

  services.homer.settings.services = [
    {
      items = [
        {
          name = "Vaultwarden";
          subtitle = "Password manager";
          url = "https://${fqdn}";
          logo = "https://cdn.jsdelivr.net/gh/selfhst/icons@master/svg/vaultwarden-light.svg";
        }
      ];
    }
  ];
}
