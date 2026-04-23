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
    };
    tlsKey = lib.mkOption {
      type = lib.types.str;
      description = "Default TLS key";
    };
    tlsCert = lib.mkOption {
      type = lib.types.str;
      description = "Default TLS certificate";
    };
    tsigAlgorithm = lib.mkOption {
      type = lib.types.str;
      description = "TSIG key algorithm.";
      default = "hmac-sha256.";
    };
    tsigKey = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the TSIG key";
    };
    tsigKeyName = lib.mkOption {
      type = lib.types.str;
      description = "TSIG key name.";
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
          RFC2136_NAMESERVER=${cfg.nameServer}
          RFC2136_TSIG_ALGORITHM=${cfg.tsigAlgorithm}
          RFC2136_TSIG_KEY=${cfg.tsigKeyName}
        ''}";
      };
    };
  };
}
