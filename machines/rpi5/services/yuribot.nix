{
  config,
  lib,
  pkgs,
  vars,
  inputs,
  ...
}:

let
  domain = "tg.${baseDomain}";
  webhookPort = "8088";

  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
  stateDir = "/var/lib/yuribot/";
  yuribot = inputs.yuribot.packages.${pkgs.system}.yuribot;
in
{
  sops.secrets."yuribot/env".owner = "root";

  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  users = {
    groups.yuribot = { };
    users.yuribot = {
      isSystemUser = true;
      group = "yuribot";
      home = stateDir;
      createHome = true;
    };
  };

  services.caddy.virtualHosts."https://${domain}".extraConfig = ''
    tls ${tlsCert} ${tlsKey}
    reverse_proxy http://${domain}:${webhookPort}
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
      TG_BASE_WEBHOOK_URL = "https://${domain}";
      TG_HOST = "127.0.0.1";
      TG_PORT = webhookPort;
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
