{ config, lib, pkgs, vars, ... }:

let
  domain = "adguard.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
  lanDomain = vars.lanDomain;
  lanIP = vars.rpi5.lanIP;
  lanIPv6 = vars.rpi5.lanIPv6;
  routerIP = vars.routerIP;
  hostName = config.networking.hostName;
in
{
  users = {
    groups.adguardhome = { };
    users.adguardhome = {
      isSystemUser = true;
      group = "adguardhome";
    };
  };

  sops.secrets."adguardhome/pass".owner = "adguardhome";

  networking.firewall = {
    allowedTCPPorts = [ 53 853 ];
    allowedUDPPorts = [ 53 853 ];
  };

  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  systemd.services.adguardhome = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
    after = [ "time-sync.target" ];
    wants = [ "time-sync.target" ];
    preStart = lib.mkAfter ''
      PASSWORD=$(cat ${config.sops.secrets."adguardhome/pass".path})
      ${lib.getExe pkgs.gnused} -i "s,PLACEHOLDER,$PASSWORD," "$STATE_DIRECTORY/AdGuardHome.yaml"
    '';
  };

  services.caddy.virtualHosts."https://${domain}".extraConfig = ''
    tls ${tlsCert} ${tlsKey}
    @lan not remote_ip private_ranges
    respond @lan "Hi! sorry not allowed :(" 403
    reverse_proxy https://${domain}:8084
  '';

  services.adguardhome = {
    enable = true;
    mutableSettings = true;
    host = "127.0.0.1";
    port = 8086;
    settings = {
      users = [
        {
          name = "david";
          password = "PLACEHOLDER";
        }
      ];
      filtering = {
        rewrites = lib.concatLists (
          lib.map (ip:
            lib.map (domain:
              { domain = domain; answer = ip; }
            ) [ "*.${baseDomain}" baseDomain hostName ])
          [ lanIP lanIPv6 ]
        );
      };
      dns = {
        upstream_dns = [
          "[//]${routerIP}"
          "[/${lanDomain}/]${routerIP}"
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
        server_name = "adguard.david-w.eu";
        certificate_path = tlsCert;
        private_key_path = tlsKey;
        force_https = true;
        port_dns_over_tls = 853;
        port_dns_over_quic = 853;
        port_dnscrypt = 0;
        port_https = 8084;
      };
    };
  };
}
