{
  config,
  dns,
}:
with dns.lib.combinators;
let
  domain = config.networking.domain;
  globalIpv4 = config.networking.globalIpv4;
  globalIpv6 = config.networking.globalIpv6;
  lanIpv4 = config.networking.lanIPv4;
  A = [
    (a globalIpv4)
  ];
  AAAA = [
    (a globalIpv6)
  ];
in
{
  inherit A AAAA;

  TTL = 3600;

  SOA = {
    nameServer = "ns1.${domain}.";
    adminEmail = "dns@${domain}";
    serial = 1;
  };

  NS = [ "ns1.${domain}." ];

  CAA = [
    {
      issuerCritical = false;
      tag = "issue";
      value = "letsencrypt.org";
    }
    {
      issuerCritical = false;
      tag = "issuewild";
      value = "letsencrypt.org";
    }
    {
      issuerCritical = false;
      tag = "iodef";
      value = "mailto:certificate@${domain}";
    }
  ];

  subdomains = {
    # keep-sorted start block=yes
    "*" = { inherit A AAAA; };
    _discord = {
      TXT = [ "dh=af7fa0fe13e9372fbb35fe58ac41091232b2e929" ];
    };
    mail = {
      inherit A AAAA;
    };
    misaka = {
      A = [ (a "192.168.64.3") ];
      AAAA = [ (a "fd64::3") ];
    };
    rpi5 = {
      inherit AAAA;
      A = [ (a lanIpv4) ];
    };
    satone = {
      A = [ (a "193.122.3.88") ];
      AAAA = [ (a "2603:c020:8008:4864:0:6247:e5e6:8a6a") ];
    };
    # keep-sorted end
  };
}
