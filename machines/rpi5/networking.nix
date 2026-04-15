{
  config,
  lib,
  ...
}:
{
  options.networking = {
    globalIpv4 = lib.mkOption {
      description = "Global IPv4 address";
      default = "178.26.111.244";
    };
    globalIpv6 = lib.mkOption {
      description = "Global IPv6 address";
      default = "2a02:810d:4795:2d00:4b77:2ad8:ca3d:e6ea";
    };
  };
  config = {
    networking = {
      hostName = "rpi5";
      useDHCP = false;
      useNetworkd = true;
      firewall.enable = true;
      lanIPv4 = "192.168.64.2";
      lanIPv6 = "fd64::2";
      gatewayIP = "192.168.64.1";
    };

    services.resolved.settings.Resolve = {
      DNSStubListener = false;
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
          "${config.networking.globalIpv6}/64"
        ]
        ++ lib.optionals config.services.adguardhome.enable [
          config.networking.adGuardIpv4
          config.networking.adGuardIpv6
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
          IPv6PrivacyExtensions = false;
        };
        ipv6AcceptRAConfig = {
          Token = "prefixstable";
          UseDNS = false;
        };
      };
    };
  };
}
