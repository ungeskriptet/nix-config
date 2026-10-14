{ config, ... }:
let
  domain = config.networking.domain;
  fqdn = "fritz.${domain}";
  serviceName = config.systemd.services.fritzbox-cert-importer.name;
in
{
  sops.secrets."fritzbox-cert-importer/env".owner = "root";

  security.acme.certs.${fqdn} = {
    keyType = "RSA2048";
    postRun = ''
      systemctl --no-block try-reload-or-restart ${serviceName}
      systemctl --no-block start ${serviceName}
    '';
  };

  services.fritzbox-cert-importer = {
    enable = true;
    fullPemFile = config.security.acme.certs."fritz.${domain}".directory + "/full.pem";
    environmentFile = config.sops.secrets."fritzbox-cert-importer/env".path;
    environment = {
      FRITZ_USERNAME = "david";
      FRITZ_URL = "https://${fqdn}";
    };
  };
}
