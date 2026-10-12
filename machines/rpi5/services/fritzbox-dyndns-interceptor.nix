{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 8075 ];

  sops.secrets."fritzbox-dyndns-interceptor/env".owner = "root";

  services.fritzbox-dyndns-interceptor = {
    enable = true;
    environmentFile = config.sops.secrets."fritzbox-dyndns-interceptor/env".path;
    environment = {
      DYNDNS_LISTEN_ADDR = "[::]:8075";
    };
  };
}
