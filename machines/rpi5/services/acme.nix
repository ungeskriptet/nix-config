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
    tsigKey = config.sops.secrets."bind/tsig/rpi5".path;
  };

  sops.secrets."bind/tsig/rpi5".owner = "root";
}
