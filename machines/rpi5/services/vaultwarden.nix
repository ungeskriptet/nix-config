{ config, ... }:
let
  fqdn = "bitwarden.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets."vaultwarden/env".owner = config.users.users.root.name;

  security.acme.defaults.reloadServices = [ "vaultwarden.service" ];

  systemd.services.vaultwarden = {
    requires = [ "postgresql.target" ];
    after = [ "postgresql.target" ];
    environment = {
      ROCKET_TLS = ''{certs="%d/tlsCert",key="%d/tlsKey"}'';
    };
    serviceConfig = {
      LoadCredential = [
        "tlsCert:${config.acme.tlsCert}"
        "tlsKey:${config.acme.tlsKey}"
      ];
    };
  };

  services = {
    caddy.hosts.${fqdn} = {
      reverseProxies."https://${fqdn}:8082" = { };
      lanOnly = {
        enable = true;
        paths = [ "/admin*" ];
      };
    };

    postgresql = {
      ensureDatabases = [ "vaultwarden" ];
      ensureUsers = [
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
    };

    vaultwarden = {
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
        SIGNUPS_ALLOWED = false;
        SMTP_FROM = "vaultwarden@${domain}";
        SMTP_HOST = domain;
        SMTP_PORT = 465;
        SMTP_SECURITY = "force_tls";
        SMTP_USERNAME = "vaultwarden";
      };
    };
  };
}
