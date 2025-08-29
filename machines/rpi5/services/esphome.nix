{
  config,
  lib,
  ...
}:
let
  fqdn = "esp.${domain}";
  domain = config.networking.domain;
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

  networking.hosts."::1" = [ fqdn ];
  networking.hosts."127.0.0.1" = [ fqdn ];

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
    "https://${fqdn}" = {
      extraConfig = ''
        tls ${config.acme.tlsCert} ${config.acme.tlsKey}
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
