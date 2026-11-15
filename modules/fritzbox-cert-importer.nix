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
    boxes = lib.mkOption {
      description = ''
        Attribute set of FRITZ!Box devices.
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              name = lib.mkOption {
                description = ''
                  Name of the FRITZ!Box.

                  The name will be the suffix for the
                  systemd service.
                '';
                default = name;
              };
              url = lib.mkOption {
                description = ''
                  URL of the FRITZ!Box.
                '';
                type = lib.types.str;
              };
              username = lib.mkOption {
                description = ''
                  Username for logging into the FRITZ!Box.
                '';
                type = lib.types.str;
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
              insecureTls = lib.mkEnableOption "insecure TLS";
            };
          }
        )
      );
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services = lib.mkMerge (
      lib.mapAttrsToList (_: v: {
        "fritzbox-cert-importer-${v.name}" = {
          description = "FRITZ!Box certificate importer (${v.name})";
          after = [
            "network-online.target"
            config.systemd.services.adguardhome.name
          ];
          wants = [
            "network-online.target"
            config.systemd.services.adguardhome.name
          ];
          environment = {
            FRITZ_URL = v.url;
            FRITZ_USERNAME = v.username;
          }
          // lib.optionalAttrs v.insecureTls { FRITZ_INSECURE_TLS = "1"; };
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${lib.getExe cfg.package} %d/full.pem";
            EnvironmentFile = v.environmentFile;
            LoadCredential = [
              "full.pem:${v.fullPemFile}"
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
      }) cfg.boxes
    );
  };
}
