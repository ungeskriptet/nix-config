{
  pkgs,
  config,
  inputs,
  ...
}:
let
  fqdn = "traccar.${domain}";
  domain = config.networking.domain;
in
{
  disabledModules = [ "services/monitoring/traccar.nix" ];
  imports = [ ../../../modules/traccar.nix ];

  systemd.services = {
    traccar = {
      after = [ "postgresql.target" ];
      requires = [ "postgresql.target" ];
    };
  };

  services = {
    traccar = {
      enable = true;
      package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.traccar;
      environment = {
        CONFIG_USE_ENVIRONMENT_VARIABLES = "true";
        DATABASE_URL = "jdbc:postgresql://localhost/traccar?socketFactory=org.newsclub.net.unix.AFUNIXSocketFactory$FactoryArg&socketFactoryArg=/run/postgresql/.s.PGSQL.5432";
      };
      settings = {
        database = {
          driver = "org.postgresql.Driver";
          user = "traccar";
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
