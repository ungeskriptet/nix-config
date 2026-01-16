{ config, ... }:
let
  domain = config.networking.domain;
in
{
  networking.hosts = {
    "::1" = [ domain ];
    "127.0.0.1" = [ domain ];
  };

  acme.enable = true;
}
