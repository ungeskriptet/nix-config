{ lib, config, ... }:
let
  domain = config.networking.domain;
  mkDnsRecords =
    {
      zone,
      ttl,
      root,
      subdomains,
    }:
    let
      zone' = if (lib.hasSuffix "." zone) then zone else zone + ".";
      changetype = "REPLACE";
      mapContent =
        content:
        if (builtins.isList content) then
          (map (content: { inherit content; }) content)
        else
          [ { inherit content; } ];
    in
    lib.mkMerge (
      [
        (lib.mapAttrsToList (type: content: {
          inherit type ttl changetype;
          name = zone';
          records = mapContent content;
        }) root)
      ]
      ++ (lib.mapAttrsToList (
        type: subdomains:
        lib.mapAttrsToList (subdomain: content: {
          inherit type ttl changetype;
          name = "${subdomain}.${zone'}";
          records = mapContent content;
        }) subdomains
      ) subdomains)
    );
in
{
  sops.secrets = {
    "servfail-update/token".owner = "root";
    "servfail-update/dyndns".owner = "root";
  };

  services.servfail-update = {
    enable = true;
    zone = domain;
    nameserver = "ahra.ns.servfail.ax";
    tokenFile = config.sops.secrets."servfail-update/token".path;
    dyndnsTokenFile = config.sops.secrets."servfail-update/dyndns".path;
    extraRRSets = mkDnsRecords {
      inherit (config.services.servfail-update) zone;
      ttl = 300;
      root = {
        CAA = [
          "0 iodef \"mailto:certificate@${domain}\""
          "0 issue \"letsencrypt.org\""
          "0 issuewild \"letsencrypt.org\""
        ];
      };
      subdomains = {
        TXT = {
          _discord = "\"dh=af7fa0fe13e9372fbb35fe58ac41091232b2e929\"";
        };
        A = {
          misaka = "192.168.64.3";
          rpi5 = "192.168.64.2";
          satone = "193.122.3.88";
        };
        AAAA = {
          misaka = "fd64::3";
          rpi5 = "fd64::2";
          satone = "2603:c020:8008:4864:0:6247:e5e6:8a6a";
        };
      };
    };
  };
}
