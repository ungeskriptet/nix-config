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
  services.servfail-update = {
    enable = true;
    zone = domain;
    nameserver = "ahra.ns.servfail.ax";
    clients = {
      ryuzu = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJDpAD1xX6wlyZfhisku9+EVjtXkzxXJAlhAXEQ8nD3 nsupdate@ryuzu"
      ];
    };
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
        CNAME = {
          "*" = domain + ".";
          stb = "biskupova.televiziastb.sk.";
        };
      };
    };
  };
}
