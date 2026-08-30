{
  config,
  ...
}:
let
  fqdn = "grafana.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets = {
    "grafana/admin-pass".owner = "root";
    "grafana/secret-key".owner = "root";
    "grafana/smtp-pass".owner = "root";
  };

  networking = {
    hosts = {
      "::1" = [
        "loki.${domain}"
      ];
      "127.0.0.1" = [
        "loki.${domain}"
      ];
    };
  };

  systemd.services = {
    caddy = {
      wants = [ config.systemd.services.grafana.name ];
      serviceConfig.SupplementaryGroups = [ "grafana" ];
    };
    grafana.serviceConfig = {
      LoadCredential = [
        "admin-pass:${config.sops.secrets."grafana/admin-pass".path}"
        "secret-key:${config.sops.secrets."grafana/secret-key".path}"
        "smtp-pass:${config.sops.secrets."grafana/smtp-pass".path}"
      ];
    };
    loki.serviceConfig = {
      SupplementaryGroups = [ "acme" ];
    };
  };

  environment.etc."alloy/config.alloy".text = ''
    otelcol.receiver.otlp "default" {
      grpc {}

      output {
        logs = [otelcol.exporter.loki.default.input]
      }
    }

    otelcol.exporter.loki "default" {
      forward_to = [loki.write.local.receiver]
    }

    loki.write "local" {
      endpoint {
        url = "https://loki.${domain}:8081/loki/api/v1/push"
      }
    }
  '';

  services = {
    caddy.hosts = {
      ${fqdn} = {
        reverseProxies."unix//run/${config.systemd.services.grafana.serviceConfig.RuntimeDirectory}/grafana.sock" =
          { };
      };
      "alloy.${domain}" = {
        reverseProxies."http://alloy.${domain}:8078" = { };
        extraConfig = ''
          forward_auth unix//run/tinyauth/tinyauth.sock {
            uri /api/auth/caddy
          }
        '';
      };
    };

    postgresql = {
      enable = true;
      ensureDatabases = [ "grafana" ];
      ensureUsers = [
        {
          name = "grafana";
          ensureDBOwnership = true;
        }
      ];
    };

    alloy = {
      enable = true;
      extraFlags = [
        "--disable-reporting"
        "--server.http.listen-addr=[::1]:8078"
      ];
    };

    loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        server = {
          http_listen_address = "::1";
          http_listen_port = 8081;
          http_tls_config = {
            cert_file = config.acme.tlsCert;
            key_file = config.acme.tlsKey;
          };
          grpc_listen_address = "::1";
          grpc_listen_port = 8079;
        };
        common = {
          instance_addr = "::1";
          ring = {
            kvstore = {
              store = "inmemory";
            };
          };
          replication_factor = 1;
          path_prefix = "/tmp/loki";
        };
        schema_config = {
          configs = [
            {
              from = "2026-08-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };
        storage_config = {
          filesystem = {
            directory = "/tmp/loki/chunks";
          };
        };
        analytics = {
          reporting_enabled = false;
        };
      };
    };

    grafana = {
      enable = true;
      declarativePlugins = [ ];
      settings = {
        server = {
          protocol = "socket";
          domain = fqdn;
          root_url = "https://${fqdn}";
          socket_mode = "0660";
          socket = "/run/grafana/grafana.sock";
        };
        database = {
          type = "postgres";
          host = "/run/postgresql";
          user = "grafana";
          name = "grafana";
        };
        security = {
          admin_user = "david";
          admin_password = "$__file{/run/credentials/grafana.service/admin-pass}";
          admin_email = "grafana@${domain}";
          cookie_secure = true;
          cookie_samesite = "strict";
          secret_key = "$__file{/run/credentials/grafana.service/secret-key}";
        };
        users = {
          allow_org_create = false;
          allow_sign_up = false;
          viewers_can_edit = false;
          login_hint = "meow :3";
        };
        "auth.basic" = {
          enabled = true;
          password_policy = false;
        };
        smtp = {
          enabled = true;
          host = "mail.${domain}:465";
          user = "grafana@${domain}";
          password = "$__file{/run/credentials/grafana.service/smtp-pass}";
          from_address = "grafana@${domain}";
        };
        analytics = {
          reporting_enabled = false;
          check_for_updates = false;
        };
      };
    };
  };
}
