{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.stalwart;
  stalwartIdentifier = "stalwart";

  # Config file only contains settings for the main data store
  configFormat = pkgs.formats.json { };
  configFile = configFormat.generate "stalwart.json" cfg.datastore;

  # NDJSON: one operation per line, no enclosing array.
  planText = input: lib.concatMapStringsSep "\n" (op: builtins.toJSON op) input;
  writePlan = text: pkgs.writeText "stalwart-plan.ndjson" (planText text);
  defaultPlan = [
    {
      "@type" = "destroy";
      object = "Application";
    }
    {
      "@type" = "destroy";
      object = "Tracer";
    }
    {
      "@type" = "update";
      object = "SpamSettings";
      value = {
        spamFilterRulesUrl = "file://${cfg.package.spam-filter}";
      };
    }
    {
      "@type" = "create";
      object = "Application";
      value = {
        webui = {
          enabled = true;
          description = "Stalwart Web Application";
          resourceUrl = "file://${cfg.package.webui}";
          urlPrefix = {
            "/admin" = true;
            "/account" = true;
          };
        };
      };
    }
    {
      "@type" = "create";
      object = "Tracer";
      value = {
        journal = {
          "@type" = "Journal";
          enable = true;
          level = "info";
        };
      };
    }
  ];

  needsRecoveryMode =
    let
      cmp = lib.getExe' pkgs.diffutils "cmp";
    in
    lib.concatStringsSep " " [
      (lib.optionalString cfg.plan.enableDefaultPlan "! ${cmp} -s ${writePlan defaultPlan} $STATE_DIRECTORY/.default-plan.ndjson ||")
      "! ${cmp} -s ${writePlan cfg.plan.sequence} $STATE_DIRECTORY/.plan.ndjson ||"
      "[ -n '${lib.optionalString cfg.recoveryMode.forceEnable "FORCE_RECOVERY"}' ]"
    ];
in
{
  options.services.stalwart = {
    enable = lib.mkEnableOption "the all-in-one collaboration and mail server, Stalwart";
    package = lib.mkPackageOption pkgs "stalwart" { };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${stalwartIdentifier}";
      description = ''
        Data directory for stalwart
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = stalwartIdentifier;
      description = ''
        User ownership of service.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = stalwartIdentifier;
      description = ''
        Group ownership of service
      '';
    };

    recoveryMode = {
      forceEnable = lib.mkEnableOption "Stalwart's recovery mode";

      port = lib.mkOption {
        type = lib.types.port;
        description = ''
          The port to use for recovery mode.
        '';
        default = 8080;
        example = 443;
      };

      user = lib.mkOption {
        type = lib.types.str;
        description = ''
          Username for recovery mode.

          Setting this option is required.
        '';
        default = "recovery-admin";
      };

      passwordFile = lib.mkOption {
        type = lib.types.oneOf [
          lib.types.str
          lib.types.path
        ];
        description = ''
          File containing the password for recovery mode.

          Setting this option is required.
        '';
        default = "";
      };
    };

    plan = {
      enableDefaultPlan = lib.mkOption {
        type = lib.types.bool;
        description = ''
          Whether to apply a base plan with useful defaults.

          ::: {.warning}
          When using this option, ensure *every* change made to the
          server is defined in {option}`services.stalwart.plan.sequence`,
          as the default plan will execute `destroy` operations.
          :::
        '';
        default = false;
      };
      sequence = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        description = ''
          Plan to apply after launching Stalwart. See
          [the documentation](https://stalw.art/docs/management/cli/apply)
          for more details.

          Use this option to create an initial admin user.

          ::: {.note}
          Every time this config changes, Stalwart will temporarily
          be booted into recovery mode to apply the new plan.
          :::
        '';
        default = [ ];
        example = [
          {
            "@type" = "destroy";
            object = "Domain";
          }
          {
            "@type" = "destroy";
            object = "Account";
          }
          {
            "@type" = "destroy";
            object = "DkimSignature";
          }
          {
            "@type" = "create";
            object = "Domain";
            value.dom-a.name = "example.org";
          }
          {
            "@type" = "create";
            object = "Account";
            value = {
              restore-1 = {
                "@type" = "User";
                name = "admin";
                domainId = "#dom-a";
                roles."@type" = "Admin";
                credentials."0" = {
                  "@type" = "Password";
                  secret = "<hash from 'echo -n YOUR_PASSWORD | argon2 $(tr -dc A-Za-z0-9 < /dev/urandom | head -c24) -id -t 2 -k 19456 -p 1 -l 32'>";
                };
              };
            };
          }
        ];
      };
    };

    datastore = lib.mkOption {
      type = configFormat.type;
      description = ''
        Data store backend configuration for Stalwart. See
        [the documentation](https://stalw.art/docs/ref/object/data-store)
        for more details.

        By default, RocksDB will be configured.
      '';
      default = {
        "@type" = "RocksDb";
        path = "${cfg.dataDir}/db";
      };
    };

    credentials = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = ''
        Credentials used to configure Stalwart secrets.

        These secrets can be accessed at
        `/run/credentials/stalwart.service`
        when using the `SecretKeyFile` type.
      '';
      default = { };
      example = {
        dkim_ed25519_privkey = "/run/keys/stalwart_dkim_ed25519_privkey";
      };
    };

    environmentFile = lib.mkOption {
      type = lib.types.oneOf [
        lib.types.path
        lib.types.str
      ];
      description = ''
        Path to a file containing extra environment variables.

        Use the `SecretKeyEnvironmentVariable` type to read these
        variables in the apply plan.
      '';
      default = "";
      example = "/run/secrets/stalwart/env";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.recoveryMode.passwordFile != "" && cfg.recoveryMode.user != "";
        message = ''
          The following options must be set:
          - 'services.stalwart.recoveryMode.user'
          - 'services.stalwart.recoveryMode.passwordFile'
        '';
      }
    ];

    # This service stores a potentially large amount of data.
    # Running it as a dynamic user would force chown to be run everytime the
    # service is restarted on a potentially large number of files.
    # That would cause unnecessary and unwanted delays.
    users = {
      groups = lib.mkIf (cfg.group == stalwartIdentifier) {
        ${cfg.group} = { };
      };
      users = lib.mkIf (cfg.user == stalwartIdentifier) {
        ${cfg.user} = {
          isSystemUser = true;
          # stalwart-cli requires a valid home directory,
          # otherwise it fails with EPERM
          home = cfg.dataDir;
          inherit (cfg) group;
        };
      };
    };

    environment.etc."stalwart/config.json".source = configFile;

    systemd = {
      packages = [ cfg.package ];
      services = {
        stalwart-apply-plan = lib.mkIf (!cfg.recoveryMode.forceEnable) {
          after = [ "stalwart.service" ];
          wantedBy = [ "stalwart.service" ];
          environment = {
            STALWART_URL = "http://localhost:${toString cfg.recoveryMode.port}";
          };
          path = [
            cfg.package.cli
            pkgs.curl
            pkgs.systemd
          ];
          serviceConfig = {
            Type = "oneshot";
            TimeoutSec = "5m";
            User = cfg.user;
            Group = cfg.group;
            LoadCredential = [ "recovery_password:${cfg.recoveryMode.passwordFile}" ];
            StateDirectory = stalwartIdentifier;
            StateDirectoryMode = "0750";
            ExecStart = [
              (pkgs.writeShellScript "stalwart-apply-plan-start" ''
                if ${needsRecoveryMode}; then
                  # https://github.com/stalwartlabs/stalwart/issues/283
                  count=0
                  while ! curl --fail --max-time 60 $STALWART_URL/healthz/ready; do
                    ((count++))
                    if [ $count -ge 10 ]; then
                      echo "Stalwart not up after $count attempts, bailing out."
                      break
                    fi
                    echo "Stalwart is not up yet, retrying in 3 seconds."
                    sleep 3
                  done

                  export STALWART_USER='${cfg.recoveryMode.user}'
                  export STALWART_PASSWORD=$(cat $CREDENTIALS_DIRECTORY/recovery_password)

                  ${lib.optionalString cfg.plan.enableDefaultPlan ''
                    # Defaults can be overridden with `services.stalwart.plan.sequence`
                    stalwart-cli apply --file ${writePlan defaultPlan}
                  ''}

                  ${lib.optionalString (cfg.plan.sequence != [ ]) ''
                    stalwart-cli apply --file ${writePlan cfg.plan.sequence}
                  ''}
                fi
              '')
              (
                "+" # Launch last step with elevated privileges. See systemd.service(5) for more details.
                + pkgs.writeShellScript "stalwart-apply-plan-end" ''
                  if ${needsRecoveryMode}; then
                    ${lib.optionalString cfg.plan.enableDefaultPlan ''
                      ln -sf ${writePlan defaultPlan} $STATE_DIRECTORY/.default-plan.ndjson
                    ''}
                    ln -sf ${writePlan cfg.plan.sequence} $STATE_DIRECTORY/.plan.ndjson
                    systemctl restart stalwart.service
                  fi
                ''
              )
            ];
          };
        };
        stalwart = {
          wantedBy = [ "multi-user.target" ];
          path = [
            cfg.package
          ];
          environment = {
            STALWART_RECOVERY_MODE_PORT = toString cfg.recoveryMode.port;
          };
          serviceConfig = {
            ExecStart = [
              ""
              (pkgs.writeShellScript "stalwart-start" ''
                # Launch Stalwart into recovery mode if plan changes or services.stalwart.recoveryMode.forceEnable is true.
                if ${needsRecoveryMode}; then
                  export STALWART_RECOVERY_MODE=true
                  export STALWART_RECOVERY_ADMIN="${cfg.recoveryMode.user}:$(cat $CREDENTIALS_DIRECTORY/recovery_password)"
                fi
                exec stalwart --config /etc/stalwart/config.json
              '')
            ];
            LoadCredential = lib.mapAttrsToList (key: value: "${key}:${value}") (
              cfg.credentials // { recovery_password = cfg.recoveryMode.passwordFile; }
            );
            EnvironmentFile = lib.mkIf (cfg.environmentFile != "") cfg.environmentFile;
            StateDirectory = stalwartIdentifier;
            StateDirectoryMode = "0750";
            LogsDirectory = stalwartIdentifier;

            # Upstream uses "stalwart" as the username since 0.12.0
            User = cfg.user;
            Group = cfg.group;

            # Bind standard privileged ports
            AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
            CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

            # Hardening
            DeviceAllow = [ "" ];
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            PrivateDevices = true;
            PrivateUsers = false; # incompatible with CAP_NET_BIND_SERVICE
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
    };

    # Make admin commands available in the shell
    environment.systemPackages = [
      cfg.package
      cfg.package.cli
    ];
  };
}
