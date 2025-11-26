{ config, pkgs, ... }:
let
  fqdn = "bakacloud.${domain}";
  domain = config.networking.domain;
  background = pkgs.stdenv.mkDerivation {
    name = "oc-background";
    src = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/4v/wallhaven-4vz8km.jpg";
      hash = "sha256-nXsLggqbaHhtIf++UTrgmYtweV+VzJU7u1YwL9uPmMo=";
    };
    buildCommand = ''
      install -Dm444 $src $out/idp-login-background
    '';
  };
in
{
  systemd.services.opencloud = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
  };

  sops.secrets."opencloud/env".owner = config.users.users.root.name;

  services = {
    opencloud = {
      enable = true;
      port = 8096;
      address = "[::1]";
      url = "https://${fqdn}";
      environmentFile = config.sops.secrets."opencloud/env".path;
      environment = {
        IDP_DEFAULT_SIGNIN_PAGE_TEXT = "The cloud with the strongest encryption";
        IDP_LOGIN_BACKGROUND_URL = "https://${fqdn}/idp-login-background";
        NOTIFICATIONS_SMTP_AUTHENTICATION = "auto";
        NOTIFICATIONS_SMTP_HOST = "mail.${domain}";
        NOTIFICATIONS_SMTP_INSECURE = "false";
        NOTIFICATIONS_SMTP_PORT = "25";
        NOTIFICATIONS_SMTP_SENDER = "bakacloud <bakacloud@${domain}>";
        NOTIFICATIONS_SMTP_TRANSPORT_ENCRYPTION = "ssltls";
        NOTIFICATIONS_SMTP_USERNAME = "bakacloud@${domain}";
        OC_INSECURE = "false";
        OC_SHARING_PUBLIC_SHARE_MUST_HAVE_PASSWORD = "false";
        OC_SHARING_PUBLIC_WRITEABLE_SHARE_MUST_HAVE_PASSWORD = "false";
        START_ADDITIONAL_SERVICES = "notifications";
      };
      settings = {
        proxy = {
          http = {
            tls_cert = config.acme.tlsCert;
            tls_key = config.acme.tlsKey;
            tls = true;
          };
        };
      };
    };

    caddy.virtualHosts."https://${fqdn}".extraConfig = ''
      tls ${config.acme.tlsCert} ${config.acme.tlsKey}
      handle /idp-login-background {
        root /idp-login-background ${background}
        file_server
      }
      reverse_proxy https://${fqdn}:8096
    '';
  };

  networking.hosts = {
    "::1" = [ fqdn ];
    "127.0.0.1" = [ fqdn ];
  };
}
