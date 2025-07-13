{ config, lib, pkgs, vars, ... }:

let
  domain = "mail.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";

  # Fix Stalwart on systems with a 16 KiB page size
  stalwart-mail = pkgs.stalwart-mail.overrideAttrs (old: {
    env.JEMALLOC_SYS_WITH_LG_PAGE = 16;
  });
in
{
  users = {
    groups.stalwart-pw = { };
    users.stalwart-pw = {
      isSystemUser = true;
      group = "stalwart-pw";
    };
  };

  sops.secrets = {
    "stalwart/pass".owner = "stalwart-mail";
    "stalwart/dbpass" = {
      owner = "stalwart-pw";
      group = "stalwart-pw";
      mode = "0440";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 25 465 993 4190 ];
  };

  networking.hosts."127.0.0.1" = [ domain ];

  systemd.services.stalwart-mail = {
    serviceConfig.SupplementaryGroups = [ "acme" "stalwart-pw" ];
    requires = [ "postgresql.target" ];
    after = [ "postgresql.target" ];
  };

  systemd.services.postgresql-setup = {
    serviceConfig.SupplementaryGroups = [ "stalwart-pw" ];
    script = lib.mkAfter ''
      PASSWORD=$(cat ${config.sops.secrets."stalwart/dbpass".path})
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
    package = stalwart-mail;
    settings = {
      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:${config.sops.secrets."stalwart/pass".path}}%";
      };
      store = {
        db.type = "postgresql";
        db.host = "localhost";
        db.database = "stalwart-mail";
        db.user = "stalwart-mail";
        db.password = "%{file:${config.sops.secrets."stalwart/dbpass".path}}%";
      };
      certificate.default = {
        cert = "%{file:${tlsCert}}%";
        private-key = "%{file:${tlsKey}}%";
        default = true;
      };
      http = {
        url = "protocol + '://${domain}:443'";
        use-x-forwarded = true;
      };
      server = {
        hostname = domain;
        listener.http = {
          protocol = "http";
          bind = [ "[::1]:8087" "127.0.0.1:8087" ];
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
    };
  };

  services.caddy.virtualHosts = {
    "https://${domain}, https://autodiscover.${baseDomain}, https://autoconfig.${baseDomain}, https://mta-sts.${baseDomain}" = {
      extraConfig = ''
        tls ${tlsCert} ${tlsKey}
        reverse_proxy https://${domain}:8087
      '';
    };
    "https://${baseDomain}" = {
      extraConfig = "reverse_proxy /.well-known/jmap https://${domain}:8087";
    };
  };
}
