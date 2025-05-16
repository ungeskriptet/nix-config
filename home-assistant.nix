{ config, ... }:

let
  domain = "nixhome.${baseDomain}";
  baseDomain = config.homelab.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
in
{
  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  systemd.services.home-assistant = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  services.caddy.virtualHosts = {
    "https://${domain}" = {
      extraConfig = ''
        tls ${tlsCert} ${tlsKey}
        reverse_proxy https://${domain}:8083
      '';
    };
  };

  services.postgresql = {
    ensureDatabases = [ "hass" ];
    ensureUsers = [
      {
        name = "hass";
        ensureDBOwnership = true;
      }
    ];
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      "isal"
      "esphome"
    ];
    extraPackages = ps: with ps; [ psycopg2 ];
    config = {
      default_config = {};
      http = {
        server_host = [ "::1" "127.0.0.1" ];
        server_port = 8083;
        ssl_key = tlsKey;
        ssl_certificate = tlsCert;
        use_x_forwarded_for = true;
        trusted_proxies = [ "::1" "127.0.0.1" ];
      };
      recorder.db_url = "postgresql://@/hass";
    };
  };
}
