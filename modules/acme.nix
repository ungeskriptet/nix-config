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
    tlsKey = lib.mkOption {
      type = lib.types.str;
      description = "Default TLS key";
    };
    tlsCert = lib.mkOption {
      type = lib.types.str;
      description = "Default TLS certificate";
    };
    tsigKey = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the TSIG key";
    };
  };
  config = lib.mkIf cfg.enable {
    acme = {
      tlsCert = "${config.security.acme.certs."${domain}".directory}/fullchain.pem";
      tlsKey = "${config.security.acme.certs."${domain}".directory}/key.pem";
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@${domain}";
      defaults.dnsResolver = "9.9.9.9:53";
      certs.${domain} = {
        extraDomainNames = [ "*.${domain}" ];
        dnsProvider = "rfc2136";
        credentialFiles = {
          RFC2136_TSIG_SECRET_FILE = cfg.tsigKey;
        };
        environmentFile = "${pkgs.writeText "env" ''
          RFC2136_NAMESERVER=ns1.david-w.eu.
          RFC2136_TSIG_ALGORITHM=hmac-sha256.
          RFC2136_TSIG_KEY=rpi5
        ''}";
      };
    };
  };
}
