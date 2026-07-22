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
        trusted_proxies = [
          "127.0.0.1/32"
          "::1/128"
        ];
        prefixes = {
          v4 = "100.64.64.0/24";
          v6 = "fd7a:115c:a1e0:64::/64";
          allocation = "sequential";
        };
        derp = {
          server = {
            enabled = true;
            stun_listen_addr = "0.0.0.0:3478";
            verify_clients = true;
            region_id = 999;
            region_code = config.networking.hostName;
            region_name = domain;
          };
        };
        dns = {
          magic_dns = true;
          base_domain = "int.${domain}";
          override_local_dns = false;
        };
        oidc = {
          issuer = "https://auth.${domain}";
          client_id = "6ae8c236-d562-4f2e-8ce7-164bbf608d71";
          client_secret_path = "\${CREDENTIALS_DIRECTORY}/oidc_secret";
          pkce.enabled = true;
        };
      };
    };

    caddy = {
      hosts.${fqdn} = {
        reverseProxies."https://${fqdn}:8098" = {
          hostHeader = "{host}";
        };
      };
      extraConfig = ''
        http://${fqdn} {
            handle /generate_204 {
                respond 204
            }
            handle * {
                redir https://{host}{uri}
            }
        }
      '';
    };
  };

  networking = {
    firewall.allowedUDPPorts = [ 3478 ];
  };

  sops.secrets."headscale/oidc_secret".owner = "root";

  systemd.services.headscale = {
    after = [ "tinyauth.service" ];
    wants = [ "tinyauth.service" ];
    serviceConfig = {
      SupplementaryGroups = [ "acme" ];
      LoadCredential = [ "oidc_secret:${config.sops.secrets."headscale/oidc_secret".path}" ];
    };
  };

  security.acme.defaults.reloadServices = [ "headscale.service" ];
}
