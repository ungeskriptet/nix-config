{
  config,
  pkgs,
  lib,
  ...
}:
let
  domain = config.networking.domain;
in
{
  options.acme = {
    tlsKey = lib.mkOption {
      type = lib.types.str;
      description = "Default TLS key";
      default = "${config.security.acme.certs."${domain}".directory}/key.pem";
    };
    tlsCert = lib.mkOption {
      type = lib.types.str;
      description = "Default TLS certificate";
      default = "${config.security.acme.certs."${domain}".directory}/fullchain.pem";
    };
  };
  config = {
    sops.secrets."pdns/apikey".owner = "acme";

    networking.hosts."::1" = [ domain ];
    networking.hosts."127.0.0.1" = [ domain ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@${domain}";
      defaults.dnsResolver = "9.9.9.9:53";
      certs.${domain} = {
        extraDomainNames = [ "*.${domain}" ];
        dnsProvider = "pdns";
        environmentFile = "${pkgs.writeText "env" ''
          PDNS_SERVER_NAME=ns1.famfo.xyz
          PDNS_API_URL=https://beta.servfail.network/
          PDNS_API_KEY_FILE=${config.sops.secrets."pdns/apikey".path}
        ''}";
      };
    };
  };
}
