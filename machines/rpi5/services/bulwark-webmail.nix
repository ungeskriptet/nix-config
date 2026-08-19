{
  config,
  ...
}:
let
  fqdn = "webmail.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets."bulwark-webmail/env".owner = "root";

  services = {
    caddy.hosts.${fqdn} = {
      reverseProxies."http://${fqdn}:8094" = { };
    };

    bulwark-webmail = {
      enable = true;
      environmentFile = config.sops.secrets."bulwark-webmail/env".path;
      environment = {
        APP_NAME = "Bakamail";
        JMAP_SERVER_URL = "https://mail.${domain}";
        STALWART_FEATURES = "true";
        HOSTNAME = "localhost";
        PORT = "8094";
        SETTINGS_SYNC_ENABLED = "true";
      };
    };
  };
}
