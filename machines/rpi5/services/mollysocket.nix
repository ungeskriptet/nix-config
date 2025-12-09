{
  config,
  ...
}:
let
  fqdn = "molly.${domain}";
  pushServer = config.services.ntfy-sh.settings.base-url;
  domain = config.networking.domain;
in
{
  users = {
    groups.mollysocket = { };
    users.mollysocket = {
      isSystemUser = true;
      group = "mollysocket";
    };
  };

  sops.secrets."mollysocket/env".owner = "root";

  networking.hosts."::1" = [ fqdn ];
  networking.hosts."127.0.0.1" = [ fqdn ];

  services.caddy.virtualHosts = {
    "https://${fqdn}" = {
      extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
        reverse_proxy http://${fqdn}:8085
      '';
    };
  };

  services.mollysocket = {
    enable = true;
    environmentFile = config.sops.secrets."mollysocket/env".path;
    settings = {
      host = "127.0.0.1";
      port = 8085;
      webserver = true;
      allowed_endpoints = [ pushServer ];
    };
  };
}
