{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  fqdn = "tg.${domain}";
  domain = config.networking.domain;
  yuribot = inputs.yuribot.packages.${pkgs.stdenv.hostPlatform.system}.yuribot;
in
{
  sops.secrets."yuribot/env".owner = "root";

  networking.hosts."::1" = [ fqdn ];
  networking.hosts."127.0.0.1" = [ fqdn ];

  users = {
    groups.yuribot = { };
    users.yuribot = {
      isSystemUser = true;
      group = "yuribot";
      home = "/var/lib/yuribot/";
      createHome = true;
    };
  };

  services.caddy.virtualHosts."https://${fqdn}".extraConfig = ''
    tls ${config.acme.tlsCert} ${config.acme.tlsKey}
    reverse_proxy http://${fqdn}:8088
  '';

  systemd.services.yuribot = {
    enable = true;
    description = "@ungeskriptetmemes Submission Bot";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.ffmpeg ];
    environment = {
      TG_ADMIN = "804152306";
      TG_ADMIN_CHANNEL = "-1002490639407";
      TG_CHANNEL = "-1002386461399";
      TG_BASE_WEBHOOK_URL = "https://${fqdn}";
      TG_HOST = "127.0.0.1";
      TG_PORT = "8088";
      TG_WEBHOOK_PATH = "/webhook";
    };
    serviceConfig = {
      Type = "simple";
      User = "yuribot";
      PrivateTmp = true;
      WorkingDirectory = "/tmp";
      EnvironmentFile = config.sops.secrets."yuribot/env".path;
      ExecStart = lib.getExe yuribot;
      Restart = "always";
      RestartSec = 60;
    };
  };
}
