{
  config,
  lib,
  ...
}:
{
  networking = {
    gatewayIP = "192.168.64.1";
    hostName = "misaka";
    lanIPv4 = "192.168.64.3";
    lanIPv6 = "fd64::3";
    useDHCP = false;
    useNetworkd = true;
    firewall.enable = true;
    interfaces.eno1.wakeOnLan.enable = true;
  };

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "eno1";
      linkConfig.RequiredForOnline = "routable";
      DHCP = "no";
      address = [
        "${config.networking.lanIPv4}/24"
        "${config.networking.lanIPv6}/64"
      ];
      gateway = [ config.networking.gatewayIP ];
      domains = [ config.networking.lanDomain ];
      dns = [
        "192.168.64.2"
        "fd64::2"
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
}
