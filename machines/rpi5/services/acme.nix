{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

let
  baseDomain = vars.baseDomain;
in
{
  sops.secrets."pdns/apikey".owner = "acme";

  networking.hosts."::1" = [ baseDomain ];
  networking.hosts."127.0.0.1" = [ baseDomain ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@${baseDomain}";
    defaults.dnsResolver = "9.9.9.9:53";
    certs.${baseDomain} = {
      extraDomainNames = [ "*.${baseDomain}" ];
      dnsProvider = "pdns";
      environmentFile = "${pkgs.writeText "env" ''
        PDNS_SERVER_NAME=ns1.famfo.xyz
        PDNS_API_URL=https://beta.servfail.network/
        PDNS_API_KEY_FILE=${config.sops.secrets."pdns/apikey".path}
      ''}";
    };
  };
}
