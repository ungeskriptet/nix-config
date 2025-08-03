{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

let
  domain = "esp.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
in
{
  users = {
    groups.esphome = { };
    users.esphome = {
      isSystemUser = true;
      group = "esphome";
      home = "/var/lib/esphome";
      homeMode = "750";
      createHome = true;
    };
  };

  sops.secrets."esphome/env".owner = "esphome";

  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  systemd.services.caddy = {
    serviceConfig.SupplementaryGroups = "esphome";
  };

  systemd.services.esphome = {
    serviceConfig = {
      EnvironmentFile = config.sops.secrets."esphome/env".path;
      User = "esphome";
      Group = "esphome";
      DynamicUser = lib.mkForce false;
      PrivateTmp = lib.mkForce true;
      RemoveIPC = lib.mkForce true;
      RestrictSUIDSGID = lib.mkForce true;
    };
  };

  services.caddy.virtualHosts = {
    "https://${domain}" = {
      extraConfig = ''
        tls ${tlsCert} ${tlsKey}
        @lan not remote_ip private_ranges
        respond @lan "Hi! sorry not allowed :(" 403
        reverse_proxy unix//run/esphome/esphome.sock
      '';
    };
  };

  services.esphome = {
    enable = true;
    enableUnixSocket = true;
  };
}
