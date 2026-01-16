{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.services.drasl;
  format = pkgs.formats.toml { };
  settings = format.generate "drasl-config.toml" cfg.settings;
in
{
  options.services.drasl = {
    enable = lib.mkEnableOption "Drasl";
    package = lib.mkPackageOption inputs.self.packages.${pkgs.stdenv.hostPlatform.system} "drasl" { };
    enableDebug = lib.mkEnableOption "debugging";
    settings = lib.mkOption {
      type = format.type;
      default = { };
      description = ''
        Configuration for Drasl. See the
        [Drasl documentation](https://github.com/unmojang/drasl/blob/master/doc/configuration.md)
        for possible options.
      '';
    };
    settingsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a TOML configuration file for Drasl. See the
        [Drasl documentation](https://github.com/unmojang/drasl/blob/master/doc/configuration.md)
        for possible options. Use this option to provide secrets to the application.

        ::: {.note}
        {option}`services.drasl.settings` takes priority over
        {option}`services.drasl.settingsFile`.
        :::
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings != { } || cfg.settingsFile != null;
        message =
          "No configuration provided for Drasl. "
          + "Please set `services.drasl.settings` or "
          + "`settings.drasl.settingsFile`.";
      }
    ];
    systemd.services.drasl = {
      description = "Drasl";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script =
        lib.optionalString (cfg.settings != { } && cfg.settingsFile != null) (
          lib.concatStringsSep " " [
            (lib.getExe' pkgs.remarshal "json2toml")
            "<(${lib.getExe pkgs.jq} -s '.[0] * .[1]'"
            "<(${lib.getExe' pkgs.remarshal "toml2json"} \"$CREDENTIALS_DIRECTORY\"/config.toml)"
            "<(${lib.getExe' pkgs.remarshal "toml2json"} ${settings}))"
            "> \"$RUNTIME_DIRECTORY\"/config.toml"
            "\n"
          ]
        )
        + lib.concatStringsSep " " [
          (lib.getExe cfg.package)
          "-config"
          (lib.optionalString (cfg.settings != { } && cfg.settingsFile == null) settings)
          (lib.optionalString (
            cfg.settings == { } && cfg.settingsFile != null
          ) "\"$CREDENTIALS_DIRECTORY\"/config.toml")
          (lib.optionalString (
            cfg.settings != { } && cfg.settingsFile != null
          ) "\"$RUNTIME_DIRECTORY\"/config.toml")
        ];
      serviceConfig = {
        DynamicUser = true;
        RuntimeDirectory = "drasl";
        RuntimeDirectoryMode = "0700";
        StateDirectory = "drasl";
        LoadCredential = lib.optionals (cfg.settingsFile != null) [ "config.toml:${cfg.settingsFile}" ];
        # Hardening
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
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
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        PrivateTmp = "disconnected";
        ProcSubset = "pid";
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = [
          "~cgroup"
          "~ipc"
          "~mnt"
          "~net"
          "~pid"
          "~user"
          "~uts"
        ];
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
    }
    // lib.optionalAttrs cfg.enableDebug { environment.DRASL_DEBUG = "1"; };
  };

  meta.maintainers = with lib.maintainers; [ ungeskriptet ];
}
