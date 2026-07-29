{ config, ... }:
let
  domain = config.networking.domain;
in
{
  networking.hosts = {
    "::1" = [ domain ];
    "127.0.0.1" = [ domain ];
  };

  acme = {
    enable = true;
    nameServer = "ns1.${domain}.";
    tsigAlgorithm = "hmac-sha512.";
    tsigKey = config.sops.secrets."acme/tsig-key".path;
    tsigKeyName = "localhost";
  };

  sops.secrets."acme/tsig-key".owner = "root";
}
