{ config, pkgs, lib, vars, ... }:

let
  domain = "molly.${baseDomain}";
  pushServer = "https://ntfy.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
in
{
  users = {
    groups.mollysocket = { };
    users.mollysocket = {
      isSystemUser = true;
      group = "mollysocket";
    };
  };

  sops.secrets."mollysocket/env".owner = "mollysocket";

  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  services.caddy.virtualHosts = {
    "https://${domain}" = {
      extraConfig = ''
        tls ${tlsCert} ${tlsKey}
        reverse_proxy http://${domain}:8085
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
