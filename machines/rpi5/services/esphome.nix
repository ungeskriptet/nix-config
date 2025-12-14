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

  networking.hosts = {
    "::1" = [ fqdn ];
    "127.0.0.1" = [ fqdn ];
  };

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
    caddy.virtualHosts = {
      "https://${fqdn}" = {
        extraConfig = ''
          tls ${config.acme.tlsCert} ${config.acme.tlsKey}
          @lan not remote_ip private_ranges
          respond @lan "Hi! sorry not allowed :(" 403
          reverse_proxy unix//run/esphome/esphome.sock
        '';
      };
    };

    esphome = {
      enable = true;
      enableUnixSocket = true;
    };

    homer.settings.services = [
      {
        items = [
          {
            name = "ESPHome";
            subtitle = "Manage ESPHome devices";
            url = "https://${fqdn}";
            logo = "https://cdn.jsdelivr.net/gh/selfhst/icons@master/svg/esphome.svg";
          }
        ];
      }
    ];
  };
}
