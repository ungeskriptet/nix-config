{ lib, ... }:
{
  networking = {
    useDHCP = lib.mkForce false;
    useNetworkd = true;
  };

  services.avahi.enable = lib.mkForce false;

  systemd.network = {
    enable = true;
    networks."10-wan" = {
      matchConfig.Path = "pci-0000:00:06.0";
      linkConfig.RequiredForOnline = true;
      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;
      DHCP = "yes";
      dns = [
        "9.9.9.10"
        "2620:fe::10"
        "149.112.112.10"
        "2620:fe::fe:10"
      ];
      networkConfig = {
        IPv6AcceptRA = true;
        IPv6PrivacyExtensions = false;
      };
      ipv6AcceptRAConfig = {
        UseDNS = false;
        Token = "prefixstable";
      };
    };
  };
}
