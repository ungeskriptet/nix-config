{
  config,
  lib,
  ...
}:
let
  cfg = config.nix-config.networking;
  fqdn = "adguard.${domain}";
  domain = config.networking.domain;
  mkDnsRewrites =
    {
      domains,
      localAAAA ? "::1",
      localA ? "127.0.0.1",
      privateAAAA ? cfg.lanIpv6.address,
      privateA ? cfg.lanIpv4.address,
    }:
    builtins.concatLists (
      map (
        domain:
        (lib.mapAttrsToList (_: v: v) (
          builtins.mapAttrs
            (
              n: v:
              "|${domain}^$dnsrewrite=${n},client=${
                if (v ? local && v.local) then "::1|127.0.0.1" else "~::1|~127.0.0.1"
              }"
            )
            {
              ${privateAAAA} = { };
              ${privateA} = { };
              ${localAAAA}.local = true;
              ${localA}.local = true;
            }
        ))
      ) domains
    );
in
{
  config = {
    networking.firewall = {
      allowedTCPPorts = [
        53
        853
      ];
      allowedUDPPorts = [
        53
        853
      ];
    };

    security.acme.defaults.reloadServices = [ "adguardhome.service" ];

    systemd.services.adguardhome = {
      serviceConfig.SupplementaryGroups = [ "acme" ];
    };

    services = {
      resolved.settings.Resolve = {
        DNSStubListener = false;
      };

      adguardhome = {
        enable = true;
        mutableSettings = true;
        host = "127.0.0.1";
        port = 8086;
        settings = {
          users = [
            {
              name = "david";
              password = "$2b$05$PenHlMoSFIXGYPIRJJkNDuk1eEHmi0cI5AgBIglXYj/LmS3zykJwy";
            }
          ];
          user_rules =
            mkDnsRewrites {
              domains = [
                config.networking.hostName
                config.networking.fqdn
              ]
              ++ config.networking.hosts."::1";
            }
            ++ map (ip: "|localhost^$dnsrewrite=${ip}") [
              "::1"
              "127.0.0.1"
            ];
          dns = {
            hostsfile_enabled = false;
            upstream_dns = [
              "[//]${cfg.gatewayIpv6} ${cfg.gatewayIpv4}"
              "[/${cfg.lanDomain}/]${cfg.gatewayIpv6} ${cfg.gatewayIpv4}"
              "tls://dot.ffmuc.net"
              "https://dns10.quad9.net/dns-query"
            ];
            bootstrap_dns = [
              "2001:678:e68:f000::"
              "2001:678:ed0:f000::"
              "5.1.66.255"
              "185.150.99.255"
              "9.9.9.10"
              "149.112.112.10"
              "2620:fe::10"
              "2620:fe::fe:10"
            ];
            trusted_proxies = [
              "127.0.0.1/32"
              "::1/128"
            ];
          };
          tls = {
            enabled = true;
            server_name = fqdn;
            certificate_path = config.acme.tlsCert;
            private_key_path = config.acme.tlsKey;
            force_https = true;
            port_dns_over_tls = 853;
            port_dns_over_quic = 853;
            port_dnscrypt = 0;
            port_https = 8084;
          };
        };
      };

      caddy.hosts.${fqdn} = {
        reverseProxies."https://${fqdn}:8084" = { };
        lanOnly.enable = true;
      };
    };
  };
}
