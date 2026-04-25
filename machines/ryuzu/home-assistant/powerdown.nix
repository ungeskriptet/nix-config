{
  lib,
  pkgs,
  config,
  ...
}:
let
  domain = config.networking.domain;
  curl = lib.getExe pkgs.curl;
  script =
    action:
    pkgs.writeShellScript "home-assistant-${action}" (
      lib.concatStringsSep " " [
        curl
        "-H @\"${config.sops.templates."home-assistant/headers".path}\""
        "-H 'Content-Type: application/json'"
        "-d '{\"entity_id\":\"script.ryuzu_powerdown\"}'"
        "https://home.${domain}/api/services/script/${action}"
      ]
    );
in
{
  sops = {
    secrets."home-assistant/token" = { };
    templates."home-assistant/headers" = {
      owner = "root";
      content = "Authorization: Bearer ${config.sops.placeholder."home-assistant/token"}";
    };
  };

  systemd.services."home-assistant-powerdown" = {
    description = "Trigger Home Assistant powerdown script";
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStopSec = 60;
      ExecStart = script "turn_off";
      ExecStop = script "turn_on";
    };
  };
}
