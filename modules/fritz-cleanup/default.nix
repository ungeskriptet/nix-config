{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.fritz-cleanup;
in
{
  options.services.fritz-cleanup = {
    enable = lib.mkEnableOption "periodic FRITZ!Box LAN devices cleanup";
    timer = lib.mkOption {
      type = lib.types.str;
      default = "*:0/15";
      description = ''
        How often to run the systemd service.
        Must be a systemd calendar value.
      '';
    };
    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = ''
        Environment variables to pass to the cleanup script.
      '';
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Use this option to pass secrets to the cleanup script.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      timers.fritz-cleanup = {
        description = "Periodic FRITZ!Box cleanup";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnActiveSec = 0;
          OnCalendar = cfg.timer;
          Persistent = true;
        };
      };
      services.fritz-cleanup = {
        description = "Clean up FRITZ!Box LAN devices";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        environment = cfg.environment;
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.python3} ${./fritz-landevices-cleanup.py}";
          EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
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
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
        };
      };
    };
  };
}
