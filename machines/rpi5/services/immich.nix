{
  config,
  ...
}:
let
  fqdn = "photos.${domain}";
  domain = config.networking.domain;
  port = toString config.services.immich.port;
in
{
  sops = {
    templates."immich.json" = {
      owner = config.users.users.immich.name;
      content = ''
        {
          "newVersionCheck": {
            "enabled": false
          },
          "server": {
            "externalDomain": "https://${fqdn}"
          },
          "notifications": {
            "smtp": {
              "enabled": true,
              "from": "immich@${domain}",
              "replyTo": "immich@${domain}",
              "transport": {
                "ignoreCert": false,
                "host": "mail.${domain}",
                "port": 465,
                "username": "immich@${domain}",
                "password": "${config.sops.placeholder."immich/smtppass"}"
              }
            }
          },
        }
      '';
    };
    secrets."immich/smtppass" = { };
  };

  services = {
    caddy.hosts.${fqdn} = {
      reverseProxies."http://${fqdn}:${port}" = { };
    };

    immich = {
      enable = true;
      port = 8093;
      host = "::1";
      environment = {
        "IMMICH_CONFIG_FILE" = config.sops.templates."immich.json".path;
      };
      machine-learning.environment = {
        "MPLCONFIGDIR" = "${config.services.immich.mediaLocation}/matplotlib";
        "HF_HOME" = "${config.services.immich.mediaLocation}/huggingface";
      };
    };
  };
}
