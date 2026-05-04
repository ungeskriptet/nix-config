{ config, pkgs, ... }:
let
  fqdn = "cups.${domain}";
  domain = config.networking.domain;
in
{
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
      allowInterfaces = [ "end0" ];
      publish = {
        enable = true;
        userServices = true;
      };
    };

    printing = {
      enable = true;
      allowFrom = [ "all" ];
      defaultShared = true;
      drivers = with pkgs; [ hplipWithPlugin ];
      openFirewall = true;
      stateless = true;
      listenAddresses = [ "*:631" ];
      browsing = true;
    };

    caddy.hosts.${fqdn} = {
      reverseProxies."http://${fqdn}:631" = {
        hostHeader = "localhost";
      };
      lanOnly.enable = true;
    };
  };

  hardware.printers = {
    ensureDefaultPrinter = "HP_LaserJet_P1005";
    ensurePrinters = [
      {
        name = "HP_LaserJet_P1005";
        location = "Wohnzimmer";
        deviceUri = "usb://HP/LaserJet%20P1005?serial=BC1T7FZ";
        model = "drv:///hp/hpcups.drv/hp-laserjet_p1005.ppd";
        description = "HP Drucker Wohnzimmer";
      }
    ];
  };
}
