{ config, ... }:
{
  acme.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 443 ];
  };

  systemd.services.caddy = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
  };

  services = {
    caddy = {
      enable = true;
      globalConfig = ''
        auto_https off
      '';
    };
  };
}
