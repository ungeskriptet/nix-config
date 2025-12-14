{ config, ... }:
let
  domain = config.networking.domain;
  fqdn = "paperless.${domain}";
in
{
  networking.hosts."::1" = [ fqdn ];
  networking.hosts."127.0.0.1" = [ fqdn ];

  sops.secrets = {
    "paperless/env".owner = "root";
    "paperless/pass".owner = "root";
  };

  services = {
    caddy.virtualHosts = {
      "https://${fqdn}".extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
        reverse_proxy http://${fqdn}:8095
      '';
    };

    paperless = {
      enable = true;
      port = 8095;
      address = "::1";
      configureTika = true;
      database.createLocally = true;
      passwordFile = config.sops.secrets."paperless/pass".path;
      environmentFile = config.sops.secrets."paperless/env".path;
      settings = {
        PAPERLESS_URL = "https://${fqdn}";
        PAPERLESS_OCR_LANGUAGE = "deu+eng+pol";
        PAPERLESS_TRUSTED_PROXIES = "127.0.0.0/8, ::1/128";
        PAPERLESS_ADMIN_USER = "david";
        PAPERLESS_ADMIN_MAIL = "paperless-admin@${domain}";
        PAPERLESS_EMAIL_HOST = config.services.stalwart-mail.settings.server.hostname;
        PAPERLESS_EMAIL_PORT = 465;
        PAPERLESS_EMAIL_HOST_USER = "paperless@${domain}";
        PAPERLESS_EMAIL_USE_SSL = true;
      };
    };

    homer.settings.services = [
      {
        items = [
          {
            name = "Paperless-ngx";
            subtitle = "Document management system";
            url = "https://${fqdn}";
            logo = "https://cdn.jsdelivr.net/gh/selfhst/icons@master/svg/paperless-ngx.svg";
          }
        ];
      }
    ];
  };
}
