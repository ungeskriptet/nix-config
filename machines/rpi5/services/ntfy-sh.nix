{ config, ... }:
let
  fqdn = "ntfy.${domain}";
  domain = config.networking.domain;
in
{
  networking.hosts = {
    "::1" = [ fqdn ];
    "127.0.0.1" = [ fqdn ];
  };

  sops.secrets."ntfy-sh/env".owner = "root";

  systemd.services = {
    ntfy-sh = {
      serviceConfig.RuntimeDirectory = "ntfy-sh";
    };
    caddy = {
      serviceConfig.SupplementaryGroups = [ "ntfy-sh" ];
    };
  };

  services = {
    caddy.virtualHosts = {
      "https://${fqdn}" = {
        extraConfig = ''
          tls ${config.acme.tlsCert} ${config.acme.tlsKey}
          reverse_proxy unix/${config.services.ntfy-sh.settings.listen-unix}
        '';
      };
    };

    ntfy-sh = {
      enable = true;
      environmentFile = config.sops.secrets."ntfy-sh/env".path;
      settings = {
        auth-access = [ "*:up*:wo" ];
        auth-default-access = "deny-all";
        auth-users = [ "david:$2a$10$coWTT.DAq.QB716gGOJMBOGradrMsCG.VDITW4m/0pXcPusoBXHlO:admin" ];
        base-url = "https://${fqdn}";
        behind-proxy = true;
        enable-login = true;
        enable-signup = false;
        keepalive-interval = "70s";
        listen-http = "";
        listen-unix-mode = 432; # 0660 in octal
        listen-unix = "/run/ntfy-sh/ntfy.sock";
        visitor-request-limit-exempt-hosts = domain;
        web-push-email-address = "webpush${domain}";
        web-push-file = "/var/lib/ntfy-sh/webpush.db";
        web-push-public-key = "BG9_p4FaZ4jpXnmPgH_CqNGxqRYAPYy6xm1hmBYk31g3MLd-nzYDNq5x8KQm8rIGKU5in1I2Z2xu_z9NMMDnffI";
      };
    };

    homer.settings.services = [
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
  };
}
