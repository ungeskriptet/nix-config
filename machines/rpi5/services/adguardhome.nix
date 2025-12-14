{
  config,
  lib,
  ...
}:
let
  fqdn = "adguard.${domain}";
  domain = config.networking.domain;
in
{
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
          rewrites = lib.concatLists (
            lib.map
              (
                ip:
                lib.map
                  (domain: {
                    domain = domain;
                    answer = ip;
                  })
                  [
                    "*.${domain}"
                    domain
                    config.networking.hostName
                    config.networking.fqdn
                  ]
              )
              [
                config.networking.lanIPv4
                config.networking.lanIPv6
              ]
          );
        };
        dns = {
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

    homer.settings.services = [
      {
        items = [
          {
            name = "AdGuard Home";
            subtitle = "Private DNS Server";
            url = "https://${fqdn}";
            logo = "https://cdn.jsdelivr.net/gh/selfhst/icons@master/svg/adguard-home.svg";
          }
        ];
      }
    ];
  };
}
