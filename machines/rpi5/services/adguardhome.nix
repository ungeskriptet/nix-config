{
  config,
  lib,
  ...
}:
let
  fqdn = "adguard.${domain}";
  domain = config.networking.domain;
  myVpn = config.networking.myVpn;
  supportVpn = config.networking.supportVpn;
  netflixVpn = config.networking.netflixVpn;
  mkDnsRewrites =
    entry:
    lib.mkMerge (
      map (
        {
          domains,
          a ? "",
          aaaa ? "",
        }:
        lib.mkMerge (
          map
            (
              answer:
              lib.mkIf (answer != "") (
                map (domain: {
                  inherit answer domain;
                  enabled = true;
                }) domains
              )
            )
            [
              a
              aaaa
            ]
        )
      ) entry
    );
in
{
  options.networking = {
    adGuardIpv4 = lib.mkOption {
      type = lib.types.str;
      default = "192.168.64.4";
    };
    adGuardIpv6 = lib.mkOption {
      type = lib.types.str;
      default = "fd64::4";
    };
  };
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

    networking.hosts = {
      "::1" = [ fqdn ];
      "127.0.0.1" = [ fqdn ];
    };

    security.acme.defaults.reloadServices = [ "adguardhome.service" ];

    systemd.services.adguardhome = {
      serviceConfig.SupplementaryGroups = [ "acme" ];
    };

    services = {
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
          filtering = {
            rewrites = mkDnsRewrites [
              {
                domains = [
                  "*.${domain}"
                  domain
                  config.networking.hostName
                  config.networking.fqdn
                ];
                a = config.networking.lanIPv4;
                aaaa = config.networking.lanIPv6;
              }
              {
                domains = [ "misaka.${domain}" ];
                a = "192.168.64.3";
                aaaa = "fd64::3";
              }
              {
                domains = [ "satone.${domain}" ];
                a = "193.122.3.88";
                aaaa = "2603:c020:8008:4864:0:6247:e5e6:8a6a";
              }
            ];
          };
          dns = {
            bind_hosts = [
              "127.0.0.1"
              "::1"
              config.networking.adGuardIpv4
              config.networking.adGuardIpv6
            ]
            ++ lib.optionals myVpn.enable [
              myVpn.ipv4.address
              myVpn.ipv6.address
            ]
            ++ lib.optionals supportVpn.enable [
              supportVpn.ipv4.address
            ]
            ++ lib.optionals netflixVpn.enable [
              netflixVpn.ipv4.address
              netflixVpn.ipv6.address
            ];
            upstream_dns = [
              "[//]${config.networking.gatewayIP}"
              "[/${config.networking.lanDomain}/]${config.networking.gatewayIP}"
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

      caddy.virtualHosts."https://${fqdn}".extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
        @lan not remote_ip private_ranges
        respond @lan "Hi! sorry not allowed :(" 403
        reverse_proxy https://${fqdn}:8084
      '';
    };
  };
}
