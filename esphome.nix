{ config, pkgs, lib, ... }:

let
  domain = "nixesp.${baseDomain}";
  baseDomain = config.homelab.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
in
{
  users = {
    groups.esphome = { };
    users.esphome = {
      isSystemUser = true;
      group = "esphome";
    };
  };

  sops.secrets."esphome/env".owner = "esphome";

  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  systemd.services.caddy = {
    serviceConfig.SupplementaryGroups = "esphome";
  };

  systemd.services.esphome = {
    serviceConfig.EnvironmentFile = config.sops.secrets."esphome/env".path;
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
