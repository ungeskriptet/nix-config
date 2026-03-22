{ config, ... }:
let
  fqdn = "vpn.${domain}";
  domain = config.networking.domain;
in
{
  services = {
    headscale = {
      enable = true;
      settings = {
        server_url = "https://${fqdn}";
        listen_addr = "[::1]:8098";
        metrics_listen_addr = null;
        tls_cert_path = config.acme.tlsCert;
        tls_key_path = config.acme.tlsKey;
        prefixes = {
          v4 = "100.64.64.0/24";
          v6 = "fd7a:115c:a1e0:64::/64";
          allocation = "sequential";
        };
        derp = {
          server = {
            enabled = true;
            stun_listen_addr = "[::]:3478";
            verify_clients = true;
            region_id = 999;
            region_code = config.networking.hostName;
            region_name = domain;
          };
          urls = [ ];
        };
        dns = {
          magic_dns = true;
          base_domain = "int.${domain}";
          override_local_dns = true;
          nameservers.global = [
            config.networking.lanIPv4
            config.networking.lanIPv6
            "9.9.9.10"
            "2620:fe::10"
          ];
        };
      };
    };

    caddy.virtualHosts."https://${fqdn}".extraConfig = ''
      tls ${config.acme.tlsCert} ${config.acme.tlsKey}
      reverse_proxy https://${fqdn}:8098 {
        header_up Host {host}
      }
    '';
  };

  networking = {
    firewall.allowedUDPPorts = [ 3478 ];
    hosts = {
      "::1" = [ fqdn ];
      "127.0.0.1" = [ fqdn ];
    };
  };

  systemd.services.headscale = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
  };

  security.acme.defaults.reloadServices = [ "headscale.service" ];
}
