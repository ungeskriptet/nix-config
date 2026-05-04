{
  lib,
  config,
  ...
}:
let
  fqdn = "traccar.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets."traccar/env".owner = config.users.users.root.name;

  systemd.services = {
    traccar = {
      after = [ "postgresql.target" ];
      requires = [ "postgresql.target" ];
    };
    postgresql-setup = {
      serviceConfig.LoadCredential = [ "traccarenv:${config.sops.secrets."traccar/env".path}" ];
      script = lib.mkAfter ''
        source "$CREDENTIALS_DIRECTORY/traccarenv"
        psql -tAc "ALTER USER \"traccar\" WITH PASSWORD '$TRACCAR_DB_PASSWORD';"
      '';
    };
  };

  services = {
    traccar = {
      enable = true;
      environmentFile = config.sops.secrets."traccar/env".path;
      settings = {
        database = {
          driver = "org.postgresql.Driver";
          # Switch to Unix socket once traccar has been updated
          url = "jdbc:postgresql://localhost:5432/traccar";
          user = "traccar";
          password = "$TRACCAR_DB_PASSWORD";
        };
        web = {
          address = "[::1]";
          port = "8097";
          url = "https://${fqdn}";
        };
      };
    };

    postgresql = {
      enable = true;
      ensureDatabases = [ "traccar" ];
      ensureUsers = [
        {
          name = "traccar";
          ensureDBOwnership = true;
        }
      ];
    };

    caddy.hosts = {
      ${fqdn} = {
        reverseProxies."http://${fqdn}:8097" = { };
      };
      "osmand.${domain}" = {
        reverseProxies."http://${fqdn}:5055" = { };
      };
    };
  };
}
