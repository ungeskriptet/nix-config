{ lib, config, ... }:
let
  domain = config.networking.domain;
in
lib.mkMerge (
  lib.mapAttrsToList
    (
      box:
      {
        url ? "https://${box}.${domain}",
        username ? "certimport",
        insecureTls ? false,
        serverName ? "",
      }:
      let
        serviceName = config.systemd.services."fritzbox-cert-importer-${box}".name;
      in
      {
        sops.secrets."fritzbox-cert-importer/${box}".owner = "root";

        security.acme.certs."${box}.${domain}" = {
          keyType = "RSA2048";
          postRun = ''
            systemctl --no-block try-reload-or-restart ${serviceName}
            systemctl --no-block start ${serviceName}
          '';
        };

        services.fritzbox-cert-importer = {
          enable = true;
          boxes = {
            ${box} = {
              inherit
                url
                username
                insecureTls
                serverName
                ;
              fullPemFile = config.security.acme.certs."${box}.${domain}".directory + "/full.pem";
              environmentFile = config.sops.secrets."fritzbox-cert-importer/${box}".path;
            };
          };
        };
      }
    )
    {
      bakabox = { };
      fritz = { };
      grandbox = { };
      omao = {
        url = "https://omao.${domain}:40555";
        username = "david";
      };
    }
)
