{
  config,
  ...
}:
let
  fqdn = "esp.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets."esphome/env".owner = "root";

  systemd.services = {
    esphome = {
      serviceConfig.EnvironmentFile = config.sops.secrets."esphome/env".path;
    };

    caddy = {
      wants = [ config.systemd.services.esphome.name ];
      serviceConfig.SupplementaryGroups = [ "esphome" ];
    };
  };

  services = {
    caddy.hosts.${fqdn} = {
      reverseProxies."unix//run/esphome/esphome.sock" = { };
      lanOnly.enable = true;
    };

    esphome = {
      enable = true;
      enableUnixSocket = true;
    };
  };
}
