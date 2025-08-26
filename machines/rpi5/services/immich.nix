{
  config,
  vars,
  pkgs,
  inputs,
  ...
}:
let
  domain = "photos.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
  port = builtins.toString config.services.immich.port;
  immich = inputs.nixpkgs.legacyPackages.${pkgs.system}.immich;
in
{
  sops.templates."immich.json" = {
    owner = config.users.users.immich.name;
    content = ''
      {
        "newVersionCheck": {
          "enabled": false
        },
        "server": {
          "externalDomain": "https://${domain}"
        },
        "notifications": {
          "smtp": {
            "enabled": true,
            "from": "immich@${baseDomain}",
            "replyTo": "immich@${baseDomain}",
            "transport": {
              "ignoreCert": false,
              "host": "mail.${baseDomain}",
              "port": 465,
              "username": "immich@${baseDomain}",
              "password": "${config.sops.placeholder."immich/smtppass"}"
            }
          }
        },
      }
    '';
  };
  sops.secrets."immich/smtppass" = { };

  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  services.caddy.virtualHosts = {
    "https://${domain}".extraConfig = ''
      tls ${tlsCert} ${tlsKey}
      reverse_proxy http://${domain}:${port}
    '';
  };

  services.immich = {
    enable = true;
    port = 8093;
    host = "::1";
    package = immich;
    database = {
      enableVectorChord = true;
      enableVectors = false;
    };
    environment = {
      "IMMICH_CONFIG_FILE" = config.sops.templates."immich.json".path;
    };
    machine-learning.environment = {
      "MPLCONFIGDIR" = "${config.services.immich.mediaLocation}/matplotlib";
      "HF_HOME" = "${config.services.immich.mediaLocation}/huggingface";
    };
  };
}
