{ config, ... }:
let
  fqdn = "bitwarden.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets."vaultwarden/env".owner = config.users.users.root.name;

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
      ADMIN_TOKEN = "$argon2id$v=19$m=65540,t=3,p=4$T5iNvSBw7kGwnNS7MUKnTQ67cypg0TKWtdHoggIt9RA$xxW8Ngb/wtbNs/Q49AABMlvuoQdaxkMBw8An2YSKaC0";
      DATABASE_URL = "postgresql:///vaultwarden?host=/run/postgresql";
      DOMAIN = "https://${fqdn}";
      ENABLE_WEBSOCKET = true;
      HTTP_REQUEST_BLOCK_NON_GLOBAL_IPS = false;
      IP_HEADER = "X-Forwarded-For";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8082;
      ROCKET_TLS = ''{certs="${config.acme.tlsCert}",key="${config.acme.tlsKey}"}'';
      SIGNUPS_ALLOWED = false;
      SMTP_FROM = "vaultwarden@${domain}";
      SMTP_HOST = domain;
      SMTP_PORT = 465;
      SMTP_SECURITY = "force_tls";
      SMTP_USERNAME = "vaultwarden";
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
