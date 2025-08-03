{
  config,
  lib,
  pkgs,
  vars,
  ...
}:

let
  domain = "home.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
  ssh = lib.getExe pkgs.openssh;
in
{
  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];
  networking.firewall.allowedUDPPorts = [ 5353 ];

  systemd.services.home-assistant = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
    requires = [ "postgresql.target" ];
    after = [ "postgresql.target" ];
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
      "androidtv"
      "androidtv_remote"
      "bthome"
      "cast"
      "default_config"
      "esphome"
      "fritz"
      "google_translate"
      "isal"
      "met"
      "nfandroidtv"
      "oralb"
      "ping"
      "radio_browser"
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
        ssl_key = tlsKey;
        ssl_certificate = tlsCert;
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
}
