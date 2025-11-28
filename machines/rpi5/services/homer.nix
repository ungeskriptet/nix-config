{ lib, config, ... }:
let
  fqdn = "dash.${domain}";
  domain = config.networking.domain;
  cfg = config.services.homer;
in
{
  services = {
    homer = {
      enable = true;
      virtualHost = {
        domain = "https://${fqdn}";
        caddy.enable = true;
      };
      settings = {
        header = false;
        footer = "";
      };
    };

    caddy.virtualHosts."https://${fqdn}".extraConfig = lib.mkBefore ''
      tls ${config.acme.tlsCert} ${config.acme.tlsKey}
    '';
  };
}
