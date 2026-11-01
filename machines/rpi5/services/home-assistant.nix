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
  ryuzuCmd =
    cmd:
    lib.concatStringsSep " " [
      ssh
      "-i/var/lib/hass/ssh/id_ed25519"
      "-oStrictHostKeyChecking=no"
      "root@ryuzu.${domain}"
      cmd
    ];
in
{
  networking = {
    firewall.allowedUDPPorts = [ 5353 ];
  };

  security.acme.defaults.reloadServices = [ "home-assistant.service" ];

  systemd.services.home-assistant = {
    serviceConfig.LoadCredential = [
      "tlsCert:${config.acme.tlsCert}"
      "tlsKey:${config.acme.tlsKey}"
    ];
    requires = [ config.systemd.targets.postgresql.name ];
    after = [ config.systemd.targets.postgresql.name ];
    before = [ config.systemd.services.caddy.name ];
  };

  services = {
    caddy.hosts.${fqdn} = {
      reverseProxies."https://${fqdn}:8083" = { };
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
      package = pkgs.home-assistant.override {
        packageOverrides = _: super: {
          radios = super.radios.overridePythonAttrs {
            pythonRelaxDeps = [ "pycountry" ];
          };
        };
      };
      extraComponents = [
        "analytics"
        "androidtv"
        "androidtv_remote"
        "bthome"
        "cast"
        "default_config"
        "enigma2"
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
          poweroff_ryuzu = ryuzuCmd "poweroff";
          start_itgmania = ryuzuCmd "itgmania";
        };
        http = {
          server_port = 8083;
          ssl_key = "/run/credentials/home-assistant.service/tlsKey";
          ssl_certificate = "/run/credentials/home-assistant.service/tlsCert";
          use_x_forwarded_for = true;
          trusted_proxies = [
            "::1"
            "127.0.0.1"
          ];
        };
        wake_on_lan = { };
        homeassistant.time_zone = null;
        recorder.db_url = "postgresql://@/hass";
      };
    };
  };
}
