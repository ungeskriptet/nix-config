{
  config,
  lib,
  ...
}:
let
  fqdn = "mail.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets = {
    "stalwart/pass".owner = "root";
    "stalwart/dbpass".owner = "root";
  };

  networking.firewall = {
    allowedTCPPorts = [
      25
      465
      993
      4190
    ];
  };

  networking.hosts."127.0.0.1" = [ fqdn ];

  systemd.services.stalwart-mail = {
    serviceConfig.SupplementaryGroups = [ "acme" ];
    requires = [ "postgresql.target" ];
    after = [ "postgresql.target" ];
  };

  systemd.services.postgresql-setup = {
    serviceConfig = {
      LoadCredential = [ "dbpass:${config.sops.secrets."stalwart/dbpass".path}" ];
    };
    script = lib.mkAfter ''
      PASSWORD=$(cat "$CREDENTIALS_DIRECTORY"/dbpass)
      psql -tAc "ALTER USER \"stalwart-mail\" WITH PASSWORD '$PASSWORD';"
    '';
  };

  services.postgresql = {
    ensureDatabases = [ "stalwart-mail" ];
    ensureUsers = [
      {
        name = "stalwart-mail";
        ensureDBOwnership = true;
      }
    ];
  };

  services.stalwart-mail = {
    enable = true;
    credentials = {
      dbpass = config.sops.secrets."stalwart/dbpass".path;
      pass = config.sops.secrets."stalwart/pass".path;
    };
    settings = {
      config.local-keys = [
        "authentication.fallback-admin.*"
        "auth.*"
        "certificate.*"
        "cluster.*"
        "config.local-keys.*"
        "directory.*"
        "email.*"
        "http.*"
        "report.*"
        "resolver.*"
        "server.*"
        "!server.allowed-ip.*"
        "!server.blocked-ip.*"
        "session.*"
        "spam-filter.resource"
        "storage.blob"
        "storage.data"
        "storage.directory"
        "storage.fts"
        "storage.lookup"
        "store.*"
        "tracer.*"
        "webadmin.*"
      ];
      auth = {
        dmarc.verify = [
          {
            "if" = "local_port == 25";
            "then" = "strict";
          }
          { "else" = "disable"; }
        ];
        spf.verify = {
          ehlo = [
            {
              "if" = "local_port == 25";
              "then" = "relaxed";
            }
            { "else" = "disable"; }
          ];
          mail-from = [
            {
              "if" = "local_port == 25";
              "then" = "relaxed";
            }
            { "else" = "disable"; }
          ];
        };
      };
      session = {
        mta-sts = {
          mode = "enforce";
          max-age = "1h";
          mx = [
            domain
            "*.${domain}"
          ];
        };
        connect.greeting = "config_get('server.hostname') + ' Hi! :3'";
        rcpt = {
          catch-all = true;
          rewrite = [
            {
              "if" = "is_local_domain('', rcpt_domain)";
              "then" = "'moe@${domain}'";
            }
            { "else" = false; }
          ];
        };
      };
      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:%{env:CREDENTIALS_DIRECTORY}%/pass}%";
      };
      store = {
        db.type = "postgresql";
        db.host = "localhost";
        db.database = "stalwart-mail";
        db.user = "stalwart-mail";
        db.password = "%{file:%{env:CREDENTIALS_DIRECTORY}%/dbpass}%";
      };
      certificate.default = {
        cert = "%{file:${config.acme.tlsCert}}%";
        private-key = "%{file:${config.acme.tlsKey}}%";
        default = true;
      };
      http = {
        url = "protocol + '://${fqdn}:443'";
        use-x-forwarded = true;
        hsts = true;
        permissive-cors = false;
      };
      server = {
        hostname = fqdn;
        listener.http = {
          protocol = "http";
          bind = [
            "[::1]:8087"
            "127.0.0.1:8087"
          ];
          tls.implicit = true;
        };
        listener.smtp = {
          protocol = "smtp";
          bind = [ "[::]:25" ];
        };
        listener.smtps = {
          protocol = "smtp";
          bind = [ "[::]:465" ];
          tls.implicit = true;
        };
        listener.imap = {
          protocol = "imap";
          bind = [ "[::]:993" ];
          tls.implicit = true;
        };
        listener.sieve = {
          protocol = "managesieve";
          bind = [ "[::]:4190" ];
          tls.implicit = true;
        };
      };
      email.folders = {
        archive = {
          name = "Archive";
          create = true;
          subscribe = true;
        };
      };
      report.analysis = {
        addresses = [
          "abuse@*"
          "dmarc@*"
          "noreply-dmarc-support@*"
          "noreply-smtp-tls-reporting@*"
          "postmaster@*"
        ];
        forward = false;
        store = "30d";
      };
      resolver = {
        type = "quad9";
        concurrency = 2;
        timeout = "5s";
        attempts = 2;
        preserve-intermediates = true;
        try-tcp-on-error = true;
        edns = true;
      };
    };
  };

  services.caddy.virtualHosts = {
    "https://${fqdn}, https://autodiscover.${domain}, https://autoconfig.${domain}, https://mta-sts.${domain}" =
      {
        extraConfig = ''
          tls ${config.acme.tlsCert} ${config.acme.tlsKey}
          reverse_proxy https://${fqdn}:8087
        '';
      };
    "https://${domain}" = {
      extraConfig = ''
        reverse_proxy /dav/* https://${fqdn}:8087
        reverse_proxy /jmap/* https://${fqdn}:8087
        reverse_proxy /.well-known/caldav https://${fqdn}:8087
        reverse_proxy /.well-known/carddav https://${fqdn}:8087
        reverse_proxy /.well-known/jmap https://${fqdn}:8087
      '';
    };
  };

  services.homer.settings.services = [
    {
      items = [
        {
          name = "Stalwart";
          subtitle = "Manage email server";
          url = "https://${fqdn}";
          logo = "https://cdn.jsdelivr.net/gh/selfhst/icons@master/svg/stalwart.svg";
        }
      ];
    }
  ];
}
