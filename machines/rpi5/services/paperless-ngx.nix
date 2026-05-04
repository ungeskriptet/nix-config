{
  config,
  pkgs,
  inputs,
  ...
}:
let
  domain = config.networking.domain;
  fqdn = "paperless.${domain}";
in
{
  sops.secrets = {
    "paperless/env".owner = "root";
    "paperless/pass".owner = "root";
  };

  services = {
    caddy.hosts.${fqdn} = {
      reverseProxies."http://${fqdn}:8095" = { };
    };

    paperless = {
      enable = true;
      package = inputs.nixpkgs-locked.legacyPackages.${pkgs.stdenv.hostPlatform.system}.paperless-ngx;
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
        PAPERLESS_EMAIL_HOST = "mail.${domain}";
        PAPERLESS_EMAIL_PORT = 465;
        PAPERLESS_EMAIL_HOST_USER = "paperless@${domain}";
        PAPERLESS_EMAIL_USE_SSL = true;
      };
    };
  };
}
