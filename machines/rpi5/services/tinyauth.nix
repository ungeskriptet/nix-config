{ lib, config, ... }:
let
  domain = config.networking.domain;
  fqdn = "auth.${domain}";
in
{
  imports = [ ../../../modules/tinyauth.nix ];
  disabledModules = [ "services/security/tinyauth.nix" ];

  sops = {
    secrets = {
      "tinyauth/oidc/headscale" = { };
      "tinyauth/totp" = { };
    };
    templates."tinyauth/env" = {
      owner = "root";
      content = ''
        TINYAUTH_AUTH_USERS=${
          lib.concatStringsSep ":" [
            "david"
            "$2a$10$K0hrbA8O2NEL8SQXKE.STuEeAD/.CMT0t4C8.HHMj85zNiEEAk6OK"
            config.sops.placeholder."tinyauth/totp"
          ]
        }
        TINYAUTH_OIDC_CLIENTS_HEADSCALE_CLIENTSECRET=${config.sops.placeholder."tinyauth/oidc/headscale"}
      '';
    };
  };

  services = {
    tinyauth = {
      enable = true;
      enableUnixSocket = true;
      environmentFile = config.sops.templates."tinyauth/env".path;
      settings = {
        APPURL = "https://${fqdn}";
        AUTH_SECURECOOKIE = true;
        UI_TITLE = "BakaAuth";
        OIDC_CLIENTS_HEADSCALE_CLIENTID = "6ae8c236-d562-4f2e-8ce7-164bbf608d71";
        OIDC_CLIENTS_HEADSCALE_NAME = "Headscale";
        OIDC_CLIENTS_HEADSCALE_TRUSTEDREDIRECTURIS = "https://vpn.${domain}/oidc/callback";
      };
    };

    caddy.hosts."${fqdn}" = {
      reverseProxies."unix//run/tinyauth/tinyauth.sock" = {
        trustedProxies = [
          "fd64::3/128"
          "192.168.64.3/32"
        ];
      };
    };
  };

  systemd.services = {
    caddy = {
      wants = [ config.systemd.services.tinyauth.name ];
      serviceConfig.SupplementaryGroups = [ "tinyauth" ];
    };
  };
}
