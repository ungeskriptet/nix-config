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
      };
    };

    caddy.virtualHosts."https://${fqdn}" = {
      extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
        reverse_proxy unix//run/tinyauth/tinyauth.sock
      '';
    };
  };

  systemd.services = {
    caddy = {
      wants = [ config.systemd.services.tinyauth.name ];
      serviceConfig.SupplementaryGroups = [ "tinyauth" ];
    };
  };

  networking.hosts = {
    "::1" = [ fqdn ];
    "127.0.0.1" = [ fqdn ];
  };
}
