{ config, ... }:
let
  fqdn = "ntfy.${domain}";
  domain = config.networking.domain;
in
{
  networking.hosts."::1" = [ fqdn ];
  networking.hosts."127.0.0.1" = [ fqdn ];

  sops.secrets."ntfy-sh/env".owner = "root";

  systemd.services.ntfy-sh = {
    serviceConfig.RuntimeDirectory = "ntfy-sh";
  };

  systemd.services.caddy = {
    serviceConfig.SupplementaryGroups = [ "ntfy-sh" ];
  };

  services.caddy.virtualHosts = {
    "https://${fqdn}" = {
      extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
        reverse_proxy unix/${config.services.ntfy-sh.settings.listen-unix}
      '';
    };
  };

  services.ntfy-sh = {
    enable = true;
    environmentFile = config.sops.secrets."ntfy-sh/env".path;
    settings = {
      base-url = "https://${fqdn}";
      listen-unix = "/run/ntfy-sh/ntfy.sock";
      listen-unix-mode = 432; # 0660 in octal
      listen-http = "";
      behind-proxy = true;
      auth-access = [ "*:up*:wo" ];
      auth-default-access = "deny-all";
      enable-signup = false;
      enable-login = true;
      keepalive-interval = "70s";
      visitor-request-limit-exempt-hosts = domain;
      web-push-file = "/var/lib/ntfy-sh/webpush.db";
      web-push-email-address = "webpush${domain}";
    };
  };

  services.homer.settings.services = [
    {
      items = [
        {
          name = "ntfy";
          subtitle = "Push notifications";
          url = "https://${fqdn}";
          logo = "https://cdn.jsdelivr.net/gh/selfhst/icons@master/svg/ntfy.svg";
        }
      ];
    }
  ];
}
