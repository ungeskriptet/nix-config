{ lib, config, ... }:
let
  domain = config.networking.domain;
  mkDnsRecord = domain: type: contents: ''
    update delete ${domain} ${type}
    ${lib.concatMapStringsSep "\n" (content: "update add ${domain} 3600 ${type} ${content}") contents}
  '';
  mkIpRecords =
    {
      domains,
      ipv6,
      ipv4,
    }@entry:
    lib.concatMapStringsSep "\n" (
      domain:
      lib.concatStringsSep "\n" [
        (lib.optionalString (entry ? ipv6) (mkDnsRecord domain "AAAA" [ ipv6 ]))
        (lib.optionalString (entry ? ipv4) (mkDnsRecord domain "A" [ ipv4 ]))
      ]
    ) domains;
in
{
  sops.secrets."knot-nsupdate/tsig-key".owner = "root";

  services.knot-nsupdate = {
    keyFile = config.sops.secrets."knot-nsupdate/tsig-key".path;
    updateScript = lib.concatStringsSep "\n" [
      ''
        server ns1.${domain}
        zone ${domain}
      ''
      (mkDnsRecord domain "NS" [ "ns1.${domain}" ])
      (mkDnsRecord domain "CAA" [
        "0 iodef \"mailto:certificate@${domain}\""
        "0 issue \"letsencrypt.org\""
        "0 issuewild \"letsencrypt.org\""
      ])
      (mkDnsRecord "_discord.${domain}" "TXT" [ "dh=af7fa0fe13e9372fbb35fe58ac41091232b2e929" ])
      (mkDnsRecord "misaka.${domain}" "AAAA" [ "fd64::3" ])
      (mkDnsRecord "misaka.${domain}" "A" [ "192.168.64.3" ])
      (mkDnsRecord "satone.${domain}" "AAAA" [ "2603:c020:8008:4864:0:6247:e5e6:8a6a" ])
      (mkDnsRecord "satone.${domain}" "A" [ "193.122.3.88" ])
      (mkDnsRecord "rpi5.${domain}" "AAAA" [ config.networking.lanIPv6 ])
      (mkDnsRecord "rpi5.${domain}" "A" [ config.networking.lanIPv4 ])
      (mkIpRecords {
        domains = [
          "ns1.${domain}"
          domain
          config.networking.fqdn
        ]
        ++ config.networking.hosts."::1";
        ipv6 = config.networking.globalIpv6;
        ipv4 = config.networking.globalIpv4;
      })
    ];
  };
}
