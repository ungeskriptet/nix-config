{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.services.fritzbox-dyndns-interceptor;
in
{
  options.services.fritzbox-dyndns-interceptor = {
    enable = lib.mkEnableOption "fritzbox-dyndns-interceptor";
    package =
      lib.mkPackageOption inputs.self.packages.${pkgs.stdenv.hostPlatform.system}
        "fritzbox-dyndns-interceptor"
        { };
    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = ''
        Configuration for fritzbox-dyndns-interceptor.

        Use {option}`services.fritzbox-dyndns-interceptor.environmentFile`
        to specify secrets.
      '';
      default = { };
    };
    environmentFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        Path to file containing environment variables.

        Use this option to specify secrets.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.fritzbox-dyndns-interceptor = {
      inherit (cfg) environment;
      description = "fritzbox-dyndns-interceptor";
      after = [
        "network-online.target"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        EnvironmentFile = cfg.environmentFile;
        Restart = "always";
        RestartSec = "10m";
        DynamicUser = true;
        # Hardening
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RemoveIPC = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        CapabilityBoundingSet = "";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        ProcSubset = "pid";
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "~@clock"
          "~@cpu-emulation"
          "~@debug"
          "~@module"
          "~@mount"
          "~@obsolete"
          "~@privileged"
          "~@raw-io"
          "~@reboot"
          "~@resources"
          "~@swap"
        ];
        UMask = "0077";
      };
    };
  };
}
