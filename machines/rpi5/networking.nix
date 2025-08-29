{
  config,
  lib,
  ...
}:
{
  networking = {
    hostName = "rpi5";
    useDHCP = false;
    useNetworkd = true;
    firewall.enable = true;
    lanIPv4 = "192.168.64.2";
    lanIPv6 = "fd64::2";
    gatewayIP = "192.168.64.1";
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
      address = [
        "${config.networking.lanIPv4}/24"
        "${config.networking.lanIPv6}/64"
      ];
      gateway = [ config.networking.gatewayIP ];
      domains = [ config.networking.lanDomain ];
      dns =
        lib.optionals config.services.adguardhome.enable [
          "::1"
          "127.0.0.1"
        ]
        ++ [
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
