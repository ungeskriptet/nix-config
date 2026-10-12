{ config, ... }:
{
  sops.secrets = {
    "servfail-update/token".owner = "root";
    "servfail-update/dyndns".owner = "root";
  };

  services.servfail-update = {
    enable = true;
    zone = config.networking.domain;
    nameserver = "ahra.ns.servfail.ax";
    tokenFile = config.sops.secrets."servfail-update/token".path;
    dyndnsTokenFile = config.sops.secrets."servfail-update/dyndns".path;
  };
}
