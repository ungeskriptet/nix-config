{ config, lib, vars, ... }:
let
  lanIP = vars.rpi5.lanIP;
  lanIPv6 = vars.rpi5.lanIPv6;
  routerIP = vars.routerIP;
in
{
  networking = {
    hostName = "rpi5";
    useDHCP = false;
    useNetworkd = true;
    firewall.enable = true;
  };

  services.resolved = {
    extraConfig = "DNSStubListener=no";
  };

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "end0";
      linkConfig.RequiredForOnline = "routable";
      DHCP = "no";
      address = [ "${lanIP}/24" "${lanIPv6}/64" ];
      gateway = [ routerIP ];
      dns = lib.optionals config.services.adguardhome.enable [
        "::1"
	"127.0.0.1"
      ] ++ [
        "2001:678:e68:f000::"
        "5.1.66.255"
      ];
      networkConfig = {
        IPv6AcceptRA = true;
      };
      ipv6AcceptRAConfig = {
        Token = "prefixstable";
        UseDNS = false;
      };
    };
  };
}
