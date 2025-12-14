{
  config,
  lib,
  pkgs,
  ...
}:
let
  fqdn = "home.${domain}";
  domain = config.networking.domain;
  ssh = lib.getExe pkgs.openssh;
in
{
  networking = {
    hosts = {
      "::1" = [ fqdn ];
      "127.0.0.1" = [ fqdn ];
    };
    firewall.allowedUDPPorts = [ 5353 ];
  };

  systemd.services.home-assistant = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
    requires = [ "postgresql.target" ];
    after = [ "postgresql.target" ];
  };

  services = {
    caddy.virtualHosts = {
      "https://${fqdn}" = {
        extraConfig = ''
          tls ${config.acme.tlsCert} ${config.acme.tlsKey}
          reverse_proxy https://${fqdn}:8083
        '';
      };
    };

    postgresql = {
      ensureDatabases = [ "hass" ];
      ensureUsers = [
        {
          name = "hass";
          ensureDBOwnership = true;
        }
      ];
    };

    home-assistant = {
      enable = true;
      extraComponents = [
        "analytics"
        "androidtv"
        "androidtv_remote"
        "bthome"
        "cast"
        "default_config"
        "esphome"
        "fritz"
        "fritzbox"
        "google_translate"
        "isal"
        "kodi"
        "met"
        "mqtt"
        "nfandroidtv"
        "ping"
        "radio_browser"
        "traccar"
        "zha"
      ];
      extraPackages = ps: with ps; [ psycopg2 ];
      config = {
        default_config = { };
        automation = "!include automations.yaml";
        script = "!include scripts.yaml";
        shell_command = {
          poweroff_ryuzu = "${ssh} -i /var/lib/hass/ssh/id_ed25519 -o StrictHostKeyChecking=no david@ryuzu sudo poweroff";
        };
        http = {
          server_host = [
            "::1"
            "127.0.0.1"
          ];
          server_port = 8083;
          ssl_key = config.acme.tlsKey;
          ssl_certificate = config.acme.tlsCert;
          use_x_forwarded_for = true;
          trusted_proxies = [
            "::1"
            "127.0.0.1"
          ];
        };
        recorder.db_url = "postgresql://@/hass";
        wake_on_lan = { };
      };
    };

    homer.settings.services = [
      {
        items = [
          {
            name = "Home Assistant";
            subtitle = "Smart Home";
            url = "https://${fqdn}";
            logo = "https://cdn.jsdelivr.net/gh/selfhst/icons@master/svg/home-assistant.svg";
          }
        ];
      }
    ];
  };
}
