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
  sshScript = pkgs.writeShellScript "servfail-update-ssh" ''
    set -euo pipefail

    hostname="$1"

    [[ -z "''${SSH_ORIGINAL_COMMAND:-}" ]] && \
      echo "Please specify IP addresses to update." 2>&1 \
      && exit 1

    IFS=" " read -a args <<< "$SSH_ORIGINAL_COMMAND"
    while [[ ''${#args[@]} -gt 0 ]]; do
      case "$args" in
       ipv6) ipv6="''${args[1]}"; args=(''${args[@]:2}) ;;
       ipv4) ipv4="''${args[1]}"; args=(''${args[@]:2}) ;;
       *) echo "Access denied for unknown argument" 1>&2; exit 1
      esac
    done

    args=(
      --zone ${lib.strings.escapeShellArg cfg.zone}
      --nameserver ${lib.strings.escapeShellArg cfg.nameserver}
      --token ${lib.strings.escapeShellArg cfg.tokenFile}
      --hostname "$hostname"
    )
    [[ -n "''${ipv6:-}" ]] && args+=(--ipv6 "$ipv6")
    [[ -n "''${ipv4:-}" ]] && args+=(--ipv4 "$ipv4")

    ${lib.getExe cfg.package} "''${args[@]}"
  '';
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
      readOnly = true;
    };
    dyndnsTokenFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        Path to a file containg the dynamic DNS token.
        This token should point to your root domain.
      '';
      readOnly = true;
    };
    extraRRSets = lib.mkOption {
      type = format.type;
      description = ''
        Additional RRsets to update.
      '';
      default = { };
    };
    clients = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      description = ''
        Attribute set of hostnames and public SSH keys
        as a list for remote clients to update records.
      '';
      default = { };
    };
  };
  config = lib.mkIf cfg.enable {
    services.servfail-update = {
      tokenFile = config.sops.secrets."servfail-update/token".path;
      dyndnsTokenFile = config.sops.secrets."servfail-update/dyndns".path;
    };
    sops.secrets = {
      "servfail-update/token" = {
        owner = "root";
        group = config.users.groups.nsupdate.name;
        mode = "0440";
      };
      "servfail-update/dyndns" = {
        owner = "root";
        group = config.users.groups.nsupdate.name;
        mode = "0440";
      };
    };
    users = lib.mkIf (cfg.clients != { }) {
      groups.nsupdate = { };
      users.nsupdate = {
        isSystemUser = true;
        shell = pkgs.bashInteractive;
        group = config.users.groups.nsupdate.name;
        openssh.authorizedKeys.keys = lib.concatLists (
          lib.mapAttrsToList (
            hostname: keys:
            let
              command = lib.concatStringsSep " " [
                (lib.getExe' pkgs.systemdMinimal "systemd-run")
                "--user"
                "--pipe"
                "--collect"
                "--property=TimeoutStartSec=60"
                "--description='Update IPs for ${hostname}'"
                "--service-type=oneshot"
                "--setenv=SSH_ORIGINAL_COMMAND"
                sshScript
                hostname
              ];
            in
            map (key: "restrict,command=\"${command}\" ${key}") keys
          ) cfg.clients
        );
      };
    };
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
