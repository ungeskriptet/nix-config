{
  config,
  pkgs,
  lib,
  ...
}:
let
  domain = config.networking.domain;
  cfg = config.acme;
in
{
  options.acme = {
    enable = lib.mkEnableOption "Let's Encrypt";
    nameServer = lib.mkOption {
      type = lib.types.str;
      description = "The nameserver to use for the DNS-01 challenge.";
      default = "ahra.ns.servfail.ax.";
    };
    tlsKey = lib.mkOption {
      type = lib.types.str;
      description = "Default TLS key.";
      readOnly = true;
    };
    tlsCert = lib.mkOption {
      type = lib.types.str;
      description = "Default TLS certificate.";
      readOnly = true;
    };
  };
  config = lib.mkIf cfg.enable {
    acme = {
      tlsCert = "${config.security.acme.certs."${domain}".directory}/fullchain.pem";
      tlsKey = "${config.security.acme.certs."${domain}".directory}/key.pem";
    };

    sops.secrets."servfail/token".owner = "root";

    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@${domain}";
      defaults.dnsResolver = "9.9.9.9:53";
      certs.${domain} = {
        extraDomainNames = [ "*.${domain}" ];
        dnsProvider = "pdns";
        credentialFiles = {
          PDNS_API_KEY_FILE = config.sops.secrets."servfail/token".path;
        };
        environmentFile = "${pkgs.writeText "env" ''
          PDNS_SERVER_NAME=${cfg.nameServer}
          PDNS_API_URL=https://beta.servfail.network/
        ''}";
      };
    };
  };
}
