{
  config,
  ...
}:
let
  fqdn = "webmail.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets = {
    "bulwark/session-secret".owner = "root";
  };

  systemd.services = {
    bulwark = {
      before = [ config.systemd.services.caddy.name ];
      serviceConfig = {
        LoadCredential = [ "session-secret:${config.sops.secrets."bulwark/session-secret".path}" ];
      };
    };
  };

  services = {
    caddy.hosts.${fqdn} = {
      reverseProxies."http://${fqdn}:8094" = { };
    };

    bulwark = {
      enable = true;
      hostname = "localhost";
      port = 8094;
      updateCheck.enabled = false;
      telemetry.enabled = false;
      settings = {
        jmapServerUrl = "https://mail.${domain}";
        sessionSecretFile = "/run/credentials/bulwark.service/session-secret";
        settingsSyncEnabled = true;
        stalwartFeaturesEnabled = true;
        branding.appName = "Bakamail";
      };
    };
  };
}
