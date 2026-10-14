{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.services.fritzbox-cert-importer;
in
{
  options.services.fritzbox-cert-importer = {
    enable = lib.mkEnableOption "fritzbox-cert-importer";
    package =
      lib.mkPackageOption inputs.self.packages.${pkgs.stdenv.hostPlatform.system} "fritzbox-cert-importer"
        { };
    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = ''
        Configuration for fritzbox-cert-importer.

        Use {option}`services.fritzbox-cert-importer.environmentFile`
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
    fullPemFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        Path to the `full.pem` file containing the
        private key and certificate chain.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    warnings = lib.optional (cfg.environment ? FRITZ_INSECURE_TLS) ''
      services.fritzbox-cert-importer: using insecure TLS validation.
      This value should only be set when deploying certificates for
      the first time.
    '';
    systemd.services.fritzbox-cert-importer = {
      inherit (cfg) environment;
      description = "fritzbox-cert-importer";
      after = [
        "network-online.target"
        config.systemd.services.adguardhome.name
      ];
      wants = [
        "network-online.target"
        config.systemd.services.adguardhome.name
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe cfg.package} %d/full.pem";
        EnvironmentFile = cfg.environmentFile;
        LoadCredential = [
          "full.pem:${cfg.fullPemFile}"
        ];
        Restart = "on-failure";
        RestartSec = "10m";
        DynamicUser = true;
        RemainAfterExit = true;
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
