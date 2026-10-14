{ lib, config, ... }:
let
  cfg = config.nix-config.networking;
  domain = config.networking.domain;
in
{
  networking = {
    firewall.allowedTCPPorts = [ 8075 ];
    hosts = {
      ${cfg.gatewayIpv6} = [ "fritz.${domain}" ];
      ${cfg.gatewayIpv4} = [ "fritz.${domain}" ];
    };
  };

  sops.secrets."fritzbox-dyndns-interceptor/env".owner = "root";

  services.fritzbox-dyndns-interceptor = {
    enable = true;
    environmentFile = config.sops.secrets."fritzbox-dyndns-interceptor/env".path;
    environment = {
      DYNDNS_LISTEN_ADDR = "[::]:8075";
      DYNDNS_ALLOWED_IPS = lib.concatStringsSep "," [
        cfg.gatewayIpv4
        cfg.gatewayIpv6
      ];
    };
  };
}
