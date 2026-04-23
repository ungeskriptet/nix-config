{
  lib,
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

  MX = [
    (mx.mx 1 "mail.${domain}.")
  ];

  TXT = [
    "v=spf1 mx ra=postmaster -all"
  ];

  DMARC = [
    {
      p = "reject";
      rua = [ "mailto:postmaster@${domain}" ];
      ruf = [ "mailto:postmaster@${domain}" ];
    }
  ];

  DKIM = [
    {
      selector = "202505e";
      h = [ "sha256" ];
      k = "ed25519";
      p = "1jpeoD1Yr2MfCAIBMV/vs8jYySpBDORwZQzB6HVDt9Y=";
    }
    {
      selector = "202505r";
      h = [ "sha256" ];
      k = "rsa";
      p = lib.concatStringsSep "" [
        "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy5saN0vqgNUFknj24pr+TriB0t"
        "LpVFPBCxofhuhKJrrI9bufafdyvNGdYKmvj1Me4TRetl0ssbry78y4hF4bLWdFBtxajLN2"
        "l7HIPAZVCfWMtmvIaMfivXnHMfq0VYQAz7QqEntD28DRyrwzZ/LCwqqQrNJdJP+JjcMn4w"
        "hv0FabfNK2gxP466QO/YrQExkH7yNGpitpxlusaRx8+K1lbVTfy1uFBKk7sNVUt7+942GS"
        "rPo13I7ConqyRJpsrYV8BiB/EePzm6e4WT9rdvgYFODS3sjOtmiYR2jjmhr1Me42m3dSZJ"
        "ZLWcC2G7/FImyG859ymWuDk6qdUYNsi/wB0QIDAQAB"
      ];
    }
  ];

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
      value = "mailto:certificate@david-w.eu";
    }
  ];

  SRV = [
    {
      service = "caldavs";
      proto = "tcp";
      priority = 0;
      weight = 1;
      port = 443;
      target = "mail.${domain}.";
    }
    {
      service = "carddavs";
      proto = "tcp";
      priority = 0;
      weight = 1;
      port = 443;
      target = "mail.${domain}.";
    }
    {
      service = "imaps";
      proto = "tcp";
      priority = 0;
      weight = 1;
      port = 993;
      target = "mail.${domain}.";
    }
    {
      service = "jmap";
      proto = "tcp";
      priority = 0;
      weight = 1;
      port = 443;
      target = "mail.${domain}.";
    }
    {
      service = "submissions";
      proto = "tcp";
      priority = 0;
      weight = 1;
      port = 465;
      target = "mail.${domain}.";
    }
  ];

  subdomains = {
    "*" = { inherit A AAAA; };

    _discord = {
      TXT = [ "dh=af7fa0fe13e9372fbb35fe58ac41091232b2e929" ];
    };

    _mta-sts = {
      TXT = [ "v=STSv1; id=2711684835720415692" ];
    };

    mail = {
      inherit A AAAA;
      TXT = [
        "v=spf1 a ra=postmaster -all"
      ];
    };

    rpi5 = {
      inherit AAAA;
      A = [ (a lanIpv4) ];
    };

    satone = {
      A = [ (a "193.122.3.88") ];
      AAAA = [ (a "2603:c020:8008:4864:0:6247:e5e6:8a6a") ];
    };
  };
}
