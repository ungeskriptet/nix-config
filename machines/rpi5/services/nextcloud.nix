{
  config,
  lib,
  pkgs,
  ...
}:
let
  fqdn = "nextcloud.${domain}";
  domain = config.networking.domain;
  occ = lib.getExe config.services.nextcloud.occ;
in
{
  networking.hosts."::1" = [ fqdn ];
  networking.hosts."127.0.0.1" = [ fqdn ];

  systemd.services.nextcloud-setup = {
    requires = [ "postgresql.target" ];
    after = [ "postgresql.target" ];
    preStart = lib.mkBefore ''
      if [[ -e /var/lib/nextcloud/config/config.php ]]; then
          ${occ} maintenance:mode --no-interaction --quiet --off
      fi
    '';
    script = lib.mkAfter ''
      if [[ -e /var/lib/nextcloud/config/config.php ]]; then
          ${occ} maintenance:repair --include-expensive
      fi

      ${occ} app:enable twofactor_totp
      ${occ} app:disable survey_client
    '';
  };

  services.caddy.virtualHosts = {
    "https://${fqdn}" = {
      extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
        reverse_proxy http://${fqdn}:8081
      '';
    };
  };

  services.postgresql = {
    ensureDatabases = [
      "nextcloud"
    ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
  };

  services.nginx = {
    virtualHosts.${fqdn}.listen = [
      {
        addr = "127.0.0.1";
        port = 8081;
      }
    ];
  };

  sops.secrets = {
    "nextcloud/pass".owner = "nextcloud";
    "nextcloud/smtppass" = { };
  };

  sops.templates."nextcloud/secretconfig" = {
    content = builtins.toJSON {
      mail_smtppassword = config.sops.placeholder."nextcloud/smtppass";
    };
    owner = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = fqdn;
    maxUploadSize = "50G";
    appstoreEnable = true;
    extraAppsEnable = true;
    webfinger = true;
    configureRedis = true;
    https = true;
    extraApps = with pkgs.nextcloud32Packages.apps; {
      inherit
        calendar
        contacts
        dav_push
        mail
        notes
        phonetrack
        previewgenerator
        ;
    };
    caching.apcu = true;
    caching.redis = true;
    autoUpdateApps.enable = true;
    notify_push = {
      enable = true;
      nextcloudUrl = "http://${fqdn}:8081";
    };
    settings = {
      default_phone_region = "DE";
      maintenance_window_start = 1;
      trusted_proxies = [
        "::1"
        "127.0.0.1"
      ];
      trusted_fqdns = [
        "::1"
        "127.0.0.1"
        "localhost"
      ];
      mail_fqdn = "${domain}";
      mail_from_address = "nextcloud";
      mail_smtpmode = "smtp";
      mail_smtphost = "mail.${domain}";
      mail_smtpsecure = "ssl";
      mail_smtpauth = "true";
      mail_smtpport = 465;
      mail_smtpname = "nextcloud";
    };
    secretFile = config.sops.templates."nextcloud/secretconfig".path;
    config.adminuser = "david";
    config.adminpassFile = config.sops.secrets."nextcloud/pass".path;
    config.dbhost = "/run/postgresql";
    config.dbtype = "pgsql";
    phpOptions."opcache.interned_strings_buffer" = "16";
  };
}
