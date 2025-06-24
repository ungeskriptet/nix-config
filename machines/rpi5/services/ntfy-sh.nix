{ config, vars, ... }:

let
  domain = "ntfy.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
in
{
  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  systemd.services.ntfy-sh = {
    serviceConfig.RuntimeDirectory = "ntfy-sh";
  };

  systemd.services.caddy = {
    serviceConfig.SupplementaryGroups = [ "ntfy-sh" ];
  };

  services.caddy.virtualHosts = {
    "https://${domain}" = {
      extraConfig = ''
        tls ${tlsCert} ${tlsKey}
        reverse_proxy unix/${config.services.ntfy-sh.settings.listen-unix}
      '';
    };
  };

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://${domain}";
      listen-unix = "/run/ntfy-sh/ntfy.sock";
      listen-unix-mode = 432; # 0660 in octal
      listen-http = "";
      behind-proxy = true;
      auth-file = "/var/lib/ntfy-sh/auth.db";
      auth-default-access = "deny-all";
      enable-signup = false;
      enable-login = true;
      keepalive-interval = "70s";
      visitor-request-limit-exempt-hosts = baseDomain;
    };
  };
}
