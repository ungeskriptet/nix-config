{ config, pkgs, ... }:
let
  fqdn = "cups.${domain}";
  domain = config.networking.domain;
in
{
  networking.hosts = {
    "::1" = [ fqdn ];
    "127.0.0.1" = [ fqdn ];
  };

  services.avahi = {
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

  services.printing = {
    enable = true;
    allowFrom = [ "all" ];
    defaultShared = true;
    drivers = with pkgs; [ hplipWithPlugin ];
    openFirewall = true;
    stateless = true;
    listenAddresses = [ "*:631" ];
    browsing = true;
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

  services.caddy.virtualHosts."https://${fqdn}".extraConfig = ''
    tls ${config.acme.tlsCert} ${config.acme.tlsKey}
    @lan not remote_ip private_ranges
    respond @lan "Hi! sorry not allowed :(" 403
    reverse_proxy http://${fqdn}:631 {
      header_up host localhost
    }
  '';
}
