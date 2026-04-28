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
    tsigKey = config.sops.secrets."acme/tsig-key".path;
    tsigKeyName = "misaka";
  };

  sops.secrets."acme/tsig-key".owner = "root";
}
