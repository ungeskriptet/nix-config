{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.knot-nsupdate;
  updateScript = pkgs.writeText "knot-nsupdate-script" cfg.updateScript;
in
{
  options.services.knot-nsupdate = {
    keyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Path to the TSIG key.";
      default = null;
    };
    updateScript = lib.mkOption {
      type = lib.types.lines;
      description = "Update script for nsupdate.";
    };
  };
  config = lib.mkIf (cfg.keyFile != null) {
    systemd.services.knot-nsupdate = {
      description = "Deploy nsupdate script to Knot";
      after = [ "knot.service" ];
      wants = [ "knot.service" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ updateScript ];
      path = with pkgs; [
        diffutils
        dnsutils
      ];
      script = ''
        if ! cmp -s "${updateScript}" "$STATE_DIRECTORY"/update-script; then
          nsupdate -k "$CREDENTIALS_DIRECTORY"/keyfile ${updateScript}
          ln -sf "${updateScript}" "$STATE_DIRECTORY"/update-script
          echo "DNS zone updated"
        else
          echo "Skipping DNS zone update"
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = [ "keyfile:${cfg.keyFile}" ];
        StateDirectory = "knot-nsupdate";
        DynamicUser = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = 10;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };
  };
}
