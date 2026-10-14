{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.services.servfail-update;
  format = pkgs.formats.json { };
  extraRRSetsFile = format.generate "servfail-rrsets.json" cfg.extraRRSets;
in
{
  options.services.servfail-update = {
    enable = lib.mkEnableOption "servfail-update";
    package =
      lib.mkPackageOption inputs.self.packages.${pkgs.stdenv.hostPlatform.system} "servfail-update"
        { };
    zone = lib.mkOption {
      type = lib.types.str;
      description = ''
        The zone to update.
      '';
    };
    nameserver = lib.mkOption {
      type = lib.types.str;
      description = ''
        The nameserver to update the DNS zone on.
      '';
    };
    tokenFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        Path to a file containing the API token.
      '';
    };
    dyndnsTokenFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        Path to a file containg the dynamic DNS token.
        This token should point to your root domain.
      '';
    };
    extraRRSets = lib.mkOption {
      type = format.type;
      description = ''
        Additional RRsets to update.
      '';
      default = { };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.servfail-update = {
      description = "Project SERVFAIL DNS zone updater";
      after = [
        "network-online.target"
        config.systemd.services.adguardhome.name
      ];
      wants = [
        "network-online.target"
        config.systemd.services.adguardhome.name
      ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [
        config.environment.etc."hosts".source
        (lib.mkIf (cfg.extraRRSets != { }) extraRRSetsFile)
      ];
      serviceConfig = {
        Type = "oneshot";
        LoadCredential = [
          "dyndns:${cfg.dyndnsTokenFile}"
          "token:${cfg.tokenFile}"
        ];
        ExecStart = lib.concatStringsSep " " (
          [
            (lib.getExe cfg.package)
            "--zone"
            cfg.zone
            "--nameserver"
            cfg.nameserver
            "--token %d/token"
            "--dyndns %d/dyndns"
          ]
          ++ (lib.optionals (cfg.extraRRSets != { }) [
            "--rrsets"
            extraRRSetsFile
          ])
        );
        DynamicUser = true;
        TimeoutSec = "5m";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "60s";
        # Hardening
        DeviceAllow = [ "" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
        UMask = "0077";
      };
    };
  };
}
