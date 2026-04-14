{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  domain = config.networking.domain;
  lanIpv4 = config.networking.lanIPv4;
  lanIpv6 = config.networking.lanIPv6;
  globalIpv6 = config.networking.globalIpv6;
  util = inputs.dns.util.${pkgs.stdenv.hostPlatform.system};
  journalPath = "bind/journal";
in
{
  services = {
    bind = {
      enable = true;
      checkConfig = false;
      listenOn = [ lanIpv4 ];
      listenOnIpv6 = [
        globalIpv6
        lanIpv6
      ];
      extraConfig = ''
        include "/run/credentials/bind.service/tsig-rpi5";
      '';
      zones.${domain} = {
        master = true;
        file = util.writeZone domain (
          import (./dns-zones + "/default-zone.nix") {
            inherit lib config;
            inherit (inputs) dns;
          }
        );
        extraConfig = ''
          allow-update { key rpi5; };
          journal "/var/lib/${journalPath}/${domain}.jnl";
        '';
      };
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
    hosts = {
      ${lanIpv4} = [ "ns1.${domain}" ];
      ${lanIpv6} = [ "ns1.${domain}" ];
    };
  };

  systemd.services.bind.serviceConfig = {
    StateDirectory = journalPath;
    LoadCredential = [ "tsig-rpi5:${config.sops.secrets."bind/tsig/rpi5".path}" ];
  };

  sops.secrets."bind/tsig/rpi5".owner = "root";
}
