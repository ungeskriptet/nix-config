{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  fqdn = "mail.${domain}";
  domain = config.networking.domain;
  sieveList = expr: list: "anyof (${lib.concatStringsSep ", " (map (x: "${expr} \"${x}\"") list)})";
  mkWildcard =
    domains:
    lib.concatLists (
      map (domain: [
        "*.${domain}"
        domain
      ]) domains
    );
  # They block me, so I block them too!
  # (But seriously, they should block based on
  # reputation and not based on prejudices...)
  blockedServers = sieveList "string :matches \"\${env.helo_domain}\"" (mkWildcard [
    "gmx.de"
    "gmx.net"
    "ionos.de"
    "kundenserver.de"
  ]);
  blockedAliases = sieveList "envelope :is :all \"to\"" (
    map (alias: "${alias}@${domain}") [
      "info"
      "sales"
    ]
  );
  mkSendOnlyUser =
    {
      name,
      description,
      secret,
    }:
    {
      "@type" = "User";
      inherit name description;
      aliases = { };
      domainId = "#domain-1";
      locale = "en_US";
      memberGroupIds = { };
      memberTenantId = null;
      timeZone = null;
      quotas = { };
      permissions = {
        "@type" = "Inherit";
      };
      roles = {
        "@type" = "Custom";
        roleIds = {
          "#role-1" = true;
        };
      };
      credentials = {
        "0" = {
          "@type" = "Password";
          allowedIps = {
            "127.0.0.0/8" = true;
            "::1" = true;
          };
          expiresAt = null;
          inherit secret;
        };
      };
    };
in
{
  disabledModules = [ "services/mail/stalwart.nix" ];
  imports = [ ../../../modules/stalwart.nix ];

  sops.secrets = {
    "stalwart/dbpass".owner = "root";
    "stalwart/recoverypass".owner = "root";
    "stalwart/tsig-key".owner = "root";
    "stalwart/vapid-key".owner = "root";
  };

  networking.firewall = {
    allowedTCPPorts = [
      25
      465
      993
      4190
    ];
  };

  security.acme.defaults.reloadServices = [ "stalwart.service" ];

  systemd.services = {
    stalwart = {
      serviceConfig.SupplementaryGroups = [ "acme" ];
      requires = [ "postgresql.target" ];
      after = [ "postgresql.target" ];
    };

    postgresql-setup = {
      serviceConfig = {
        LoadCredential = [ "dbpass:${config.sops.secrets."stalwart/dbpass".path}" ];
      };
      script = lib.mkAfter ''
        PASSWORD=$(cat "$CREDENTIALS_DIRECTORY"/dbpass)
        psql -tAc "ALTER USER \"stalwart-mail\" WITH PASSWORD '$PASSWORD';"
      '';
    };
  };

  services = {
    postgresql = {
      ensureDatabases = [ "stalwart-mail" ];
      ensureUsers = [
        {
          name = "stalwart-mail";
          ensureDBOwnership = true;
        }
      ];
    };

    stalwart = {
      enable = true;
      package = {
        spam-filter = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.stalwart-spam-filter;
        webui = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.stalwart-webui;
      };
      credentials = {
        dbpass = config.sops.secrets."stalwart/dbpass".path;
        tsig-key = config.sops.secrets."stalwart/tsig-key".path;
        vapid-key = config.sops.secrets."stalwart/vapid-key".path;
      };
      recoveryMode = {
        port = 8087;
        user = "admin";
        passwordFile = config.sops.secrets."stalwart/recoverypass".path;
      };
      datastore = {
        "@type" = "PostgreSql";
        host = "localhost";
        port = 5432;
        database = "stalwart-mail";
        authUsername = "stalwart-mail";
        authSecret = {
          "@type" = "File";
          filePath = "/run/credentials/stalwart.service/dbpass";
        };
      };
      plan = {
        enableDefaultPlan = true;
        sequence = [
          {
            "@type" = "reconcile";
            matchOn = [ "name" ];
            object = "MtaTlsStrategy";
            value = {
              strategy-1 = {
                allowInvalidCerts = false;
                dane = "disable";
                description = "Default TLS settings";
                mtaSts = "optional";
                mtaStsTimeout = 300000;
                name = "default";
                startTls = "optional";
                tlsTimeout = 180000;
              };
              strategy-2 = {
                allowInvalidCerts = true;
                dane = "optional";
                description = "Allow invalid TLS certificates";
                mtaSts = "optional";
                mtaStsTimeout = 300000;
                name = "invalid-tls";
                startTls = "optional";
                tlsTimeout = 180000;
              };
            };
          }
          {
            "@type" = "reconcile";
            matchOn = [ "subjectAlternativeNames" ];
            object = "Certificate";
            value = {
              cert-1 = {
                certificate = {
                  "@type" = "File";
                  filePath = config.acme.tlsCert;
                };
                privateKey = {
                  "@type" = "File";
                  filePath = config.acme.tlsKey;
                };
                subjectAlternativeNames = {
                  "*.${domain}" = true;
                  ${domain} = true;
                };
              };
            };
          }
          {
            "@type" = "reconcile";
            object = "DnsServer";
            matchOn = [ "key" ];
            value = {
              dnsserver-1 = {
                "@type" = "Tsig";
                description = "Knot DNS";
                keyName = "localhost";
                host = "::2";
                protocol = "udp";
                tsigAlgorithm = "hmac-sha512";
                port = 53;
                key = {
                  "@type" = "File";
                  filePath = "/run/credentials/stalwart.service/tsig-key";
                };
              };
            };
          }
          {
            "@type" = "reconcile";
            object = "Domain";
            matchOn = [ "name" ];
            value = {
              domain-1 = {
                name = domain;
                description = "Default";
                aliases = { };
                allowRelaying = false;
                catchAllAddress = "moe@${domain}";
                directoryId = null;
                dkimManagement = {
                  "@type" = "Automatic";
                  algorithms = {
                    Dkim1Ed25519Sha256 = true;
                    Dkim1RsaSha256 = true;
                  };
                  deleteAfter = 2592000000;
                  retireAfter = 604800000;
                  rotateAfter = 7776000000;
                  selectorTemplate = "v{version}-{algorithm}-{date-%Y%m%d}";
                };
                dnsManagement = {
                  "@type" = "Automatic";
                  dnsServerId = "#dnsserver-1";
                  origin = null;
                  publishRecords = {
                    autoConfig = true;
                    autoConfigLegacy = true;
                    autoDiscover = true;
                    caa = true;
                    dkim = true;
                    dmarc = true;
                    mtaSts = true;
                    mx = true;
                    spf = true;
                    srv = true;
                    tlsRpt = true;
                    tlsa = true;
                  };
                };
                certificateManagement = {
                  "@type" = "Manual";
                };
                isEnabled = true;
                logo = null;
                memberTenantId = null;
                reportAddressUri = "mailto:postmaster";
                subAddressing = {
                  "@type" = "Enabled";
                };
              };
            };
          }
          {
            "@type" = "reconcile";
            object = "NetworkListener";
            matchOn = [ "name" ];
            value = {
              listener-1 = {
                name = "https";
                bind = {
                  "[::1]:8087" = true;
                };
                protocol = "http";
                useTls = true;
                tlsImplicit = true;
              };
              listener-2 = {
                name = "smtp";
                bind = {
                  "[::]:25" = true;
                };
                protocol = "smtp";
                useTls = true;
              };
              listener-3 = {
                name = "smtps";
                bind = {
                  "[::]:465" = true;
                };
                protocol = "smtp";
                useTls = true;
                tlsImplicit = true;
              };
              listener-4 = {
                name = "imaps";
                bind = {
                  "[::]:993" = true;
                };
                protocol = "imap";
                useTls = true;
                tlsImplicit = true;
              };
              listener-5 = {
                name = "sieve";
                bind = {
                  "[::]:4190" = true;
                };
                protocol = "manageSieve";
                useTls = true;
                tlsImplicit = true;
              };
            };
          }
          {
            "@type" = "upsert";
            matchOn = [ "description" ];
            object = "Role";
            value = {
              role-1 = {
                description = "Send Only";
                enabledPermissions = {
                  authenticate = true;
                  calendarAlarmsSend = true;
                  calendarSchedulingSend = true;
                  emailSend = true;
                };
              };
            };
          }
          {
            "@type" = "reconcile";
            object = "Account";
            matchOn = [ "name" ];
            value = {
              account-1 = {
                "@type" = "User";
                name = "moe";
                domainId = "#domain-1";
                description = "David Wronek";
                roles."@type" = "Admin";
                credentials = {
                  # read pass; echo -n "$pass" | nix run nixpkgs#libargon2 -- "$(head -c 20 /dev/random | base64)" -id -k 19456
                  "0" = {
                    "@type" = "Password";
                    secret = "$argon2id$v=19$m=19456,t=3,p=1$eDYyaW00K3l1VnMrZmVXTldjeVR3Qlltdm9ZPQ$50ic9c9vZBsilnDNU5G5ddsrYOGhxy+TIN6AUIIVeKE";
                  };
                };
              };
              account-2 = mkSendOnlyUser {
                secret = "$argon2id$v=19$m=19456,t=3,p=1$NXo2ak1STm9Ba0tNWFQ0QXNUNHJ4MUw5bkdZPQ$c3GSIvBKOHAz2QVwTTQkZQUKECk6ezihyTc9gTHrtq4";
                description = "Goeland";
                name = "goeland";
              };
              account-3 = mkSendOnlyUser {
                secret = "$argon2id$v=19$m=19456,t=3,p=1$TWdsc2JNbklwTGhwYVVGM2VCMU5vREpITFVvPQ$5b/S0epP+Hp1cEQkrKKvw0MwmdsNzgsb1vDLbiFCdTg";
                description = "Immich";
                name = "immich";
              };
              account-4 = mkSendOnlyUser {
                secret = "$argon2id$v=19$m=19456,t=3,p=1$T0FLWVYrcU1hUldncFNucGFjeitFVW1reU9zPQ$fDYpWMgr+W1fyX4nVxPJg+dQpK35OP6Ko5ONz9XvZg8";
                description = "OpenCloud";
                name = "bakacloud";
              };
              account-5 = mkSendOnlyUser {
                secret = "$argon2id$v=19$m=19456,t=3,p=1$a3ZvY3lqSVJZQ25FSDhHTWVtbWVxQzRCRVIwPQ$xAHk19RThaoKtSBAdyKYBol8cmCb/ODZ8KqBy939PU0";
                description = "Paperless-ngx";
                name = "paperless";
              };
              account-6 = mkSendOnlyUser {
                secret = "$argon2id$v=19$m=19456,t=3,p=1$OTNlK0o2dnJJVjdqZkh0ckdwcWt5UDU3NTRBPQ$ike/eVShzJgl1evnYcthuWqMb1aY1+ouTSOtVkb4Yoc";
                description = "Vaultwarden";
                name = "vaultwarden";
              };
            };
          }
          {
            "@type" = "reconcile";
            matchOn = [ "name" ];
            object = "SieveSystemScript";
            value = {
              script-1 = {
                name = "data-script";
                description = "Sieve script for DATA stage";
                isActive = true;
                contents = ''
                  require ["variables", "ereject"];
                  if ${blockedServers} {
                    ${lib.concatStringsSep " " [
                      "ereject \"551 5.1.1"
                      "Sorry, :( deine E-Mail wurde abgeleht da '\${env.helo_domain}' meinen"
                      "Mailserver blockiert. Das heisst, dass ich auf deine Nachricht nicht"
                      "antworten kann. Bitte kontaktiere mich von einem anderem E-Mail Provider."
                      "Sorry, :( your E-Mail has been rejected because '\${env.helo_domain}'"
                      "blocks my mailserver. This means I won't be able to reply to your"
                      "message. Please contact me from a different E-Mail provider.\";"
                    ]}
                  }
                  if anyof(
                    header :matches "Subject" "*Limited?Time Offer*",
                    header :matches "From" "Luxury*"
                  ) {
                    ${lib.concatStringsSep " " [
                      "ereject \"551 5.1.1"
                      "I don't want luxury watches."
                      "(If you're not a spammer, use a different subject"
                      "or change your sender name in case it contains"
                      "the word 'Luxury'.)\";"
                    ]}
                  }
                '';
              };
              script-2 = {
                name = "rcpt-script";
                description = "Sieve script for RCPT stage";
                isActive = true;
                contents = ''
                  require ["envelope", "variables", "ereject"];
                  if ${blockedAliases} {
                    ${lib.concatStringsSep " " [
                      "ereject \"550"
                      "Hi! Deine E-Mail wurde blockiert, aber keine sorge, wenn du mich"
                      "erreichen moechtest, nutze bitte einen anderen zufaelligen Alias"
                      "(Den Teil der E-Mail adresse vor dem '@')."
                      "Hi! Your message was blocked, but fear not, if you want to reach"
                      "me, use a different random alias (The part of the E-Mail address"
                      "before the '@').\";"
                    ]}
                  }
                  set "envelope.to" "moe@${domain}";
                '';
              };
            };
          }
          {
            "@type" = "update";
            object = "SystemSettings";
            value = {
              defaultDomainId = "#domain-1";
              defaultHostname = fqdn;
            };
          }
          {
            "@type" = "update";
            object = "Http";
            value = {
              enableHsts = true;
              usePermissiveCors = false;
              useXForwarded = true;
            };
          }
          {
            "@type" = "update";
            object = "MtaSts";
            value = {
              maxAge = 86400000; # 1 day
              mode = "enforce";
              mxHosts = {
                ${domain} = true;
                "*.${domain}" = true;
              };
            };
          }
          {
            "@type" = "update";
            object = "MtaStageAuth";
            value = {
              maxFailures = {
                "else" = "3";
                match = { };
              };
              mustMatchSender = {
                "else" = "true";
                match = {
                  "0" = {
                    "if" = "authenticated_as == \"moe@${domain}\"";
                    "then" = "false";
                  };
                };
              };
              require = {
                "else" = "local_port != 25";
                match = { };
              };
              saslMechanisms = {
                "else" = "false";
                match = {
                  "0" = {
                    "if" = "local_port != 25 && is_tls";
                    "then" = "[plain, login, oauthbearer, xoauth2]";
                  };
                  "1" = {
                    "if" = "local_port != 25";
                    "then" = "[oauthbearer, xoauth2]";
                  };
                };
              };
              waitOnFail = {
                "else" = "5s";
                match = { };
              };
            };
          }
          {
            "@type" = "update";
            object = "MtaStageConnect";
            value = {
              hostname = {
                "else" = "system('hostname')";
                match = { };
              };
              script = {
                "else" = "false";
                match = { };
              };
              smtpGreeting = {
                "else" = "system('hostname') + ' Hi! :3'";
                match = { };
              };
            };
          }
          {
            "@type" = "update";
            object = "MtaStageData";
            value = {
              addAuthResultsHeader = {
                "else" = "false";
                match = {
                  "0" = {
                    "if" = "local_port == 25";
                    "then" = "true";
                  };
                };
              };
              addDateHeader = {
                "else" = "false";
                match = {
                  "0" = {
                    "if" = "local_port == 25";
                    "then" = "true";
                  };
                };
              };
              addDeliveredToHeader = true;
              addMessageIdHeader = {
                "else" = "false";
                match = {
                  "0" = {
                    "if" = "local_port == 25";
                    "then" = "true";
                  };
                };
              };
              addReceivedHeader = {
                "else" = "false";
                match = {
                  "0" = {
                    "if" = "local_port == 25";
                    "then" = "true";
                  };
                };
              };
              addReceivedSpfHeader = {
                "else" = "false";
                match = {
                  "0" = {
                    "if" = "local_port == 25";
                    "then" = "true";
                  };
                };
              };
              addReturnPathHeader = {
                "else" = "false";
                match = {
                  "0" = {
                    "if" = "local_port == 25";
                    "then" = "true";
                  };
                };
              };
              enableSpamFilter = {
                "else" = "is_empty(authenticated_as)";
                match = { };
              };
              maxMessageSize = {
                "else" = "104857600";
                match = { };
              };
              maxMessages = {
                "else" = "10";
                match = { };
              };
              maxReceivedHeaders = {
                "else" = "50";
                match = { };
              };
              script = {
                "else" = "'data-script'";
                match = { };
              };
            };
          }
          {
            "@type" = "update";
            object = "MtaStageRcpt";
            value = {
              allowRelaying = {
                "else" = "!is_empty(authenticated_as)";
                match = { };
              };
              maxFailures = {
                "else" = "5";
                match = { };
              };
              maxRecipients = {
                "else" = "100";
                match = { };
              };
              rewrite = {
                "else" = "false";
                match = { };
              };
              script = {
                "else" = "'rcpt-script'";
                match = { };
              };
              waitOnFail = {
                "else" = "5s";
                match = { };
              };
            };
          }
          {
            "@type" = "update";
            object = "MtaOutboundStrategy";
            value = {
              connection = {
                "else" = "'default'";
                match = { };
              };
              route = {
                "else" = "'mx'";
                match = {
                  "0" = {
                    "if" = "is_local_domain(rcpt_domain)";
                    "then" = "'local'";
                  };
                };
              };
              schedule = {
                "else" = "'remote'";
                match = {
                  "0" = {
                    "if" = "is_local_domain(rcpt_domain)";
                    "then" = "'local'";
                  };
                  "1" = {
                    "if" = "source == 'dsn'";
                    "then" = "'dsn'";
                  };
                  "2" = {
                    "if" = "source == 'report'";
                    "then" = "'report'";
                  };
                };
              };
              tls = {
                "else" = "'default'";
                match = {
                  "0" = {
                    "if" = "retry_num > 0 && last_error == 'tls'";
                    "then" = "'invalid-tls'";
                  };
                };
              };
            };
          }
          {
            "@type" = "update";
            object = "MtaStageRcpt";
            value = {
              allowRelaying = {
                "else" = "!is_empty(authenticated_as)";
                match = { };
              };
              maxFailures = {
                "else" = "5";
                match = { };
              };
              maxRecipients = {
                "else" = "100";
                match = { };
              };
              rewrite = {
                "else" = "false";
                match = { };
              };
              script = {
                "else" = "'rcpt-script'";
                match = { };
              };
              waitOnFail = {
                "else" = "5s";
                match = { };
              };
            };
          }
          {
            "@type" = "update";
            object = "ReportSettings";
            value = {
              inboundReportAddresses = {
                "noreply-dmarc-support@*" = true;
                "noreply-smtp-tls-reporting@*" = true;
                "postmaster@*" = true;
              };
              inboundReportForwarding = false;
              outboundReportDomain = null;
              outboundReportSubmitter = {
                "else" = "system('hostname')";
                match = { };
              };
            };
          }
          {
            "@type" = "update";
            object = "SenderAuth";
            value = {
              arcVerify = {
                "else" = "disable";
                match = { };
              };
              dkimSignDomain = {
                "else" = "false";
                match = {
                  "0" = {
                    "if" = "is_local_domain(sender_domain) && !is_empty(authenticated_as)";
                    "then" = "sender_domain";
                  };
                };
              };
              dkimStrict = true;
              dkimVerify = {
                "else" = "strict";
                match = { };
              };
              dmarcVerify = {
                "else" = "disable";
                match = {
                  "0" = {
                    "if" = "local_port == 25";
                    "then" = "strict";
                  };
                };
              };
              reverseIpVerify = {
                "else" = "disable";
                match = {
                  "0" = {
                    "if" = "local_port == 25";
                    "then" = "relaxed";
                  };
                };
              };
              spfEhloVerify = {
                "else" = "disable";
                match = {
                  "0" = {
                    "if" = "local_port == 25";
                    "then" = "relaxed";
                  };
                };
              };
              spfFromVerify = {
                "else" = "disable";
                match = {
                  "0" = {
                    "if" = "local_port == 25";
                    "then" = "relaxed";
                  };
                };
              };
            };
          }
          {
            "@type" = "update";
            object = "Jmap";
            value = {
              changesMaxResults = 5000;
              eventSourceThrottle = 1000;
              getMaxResults = 500;
              maxConcurrentRequests = 4;
              maxConcurrentUploads = 4;
              maxMethodCalls = 16;
              maxRequestSize = 10000000;
              maxSubscriptions = 15;
              maxUploadCount = 1000;
              maxUploadSize = 50000000;
              parseLimitContact = 10;
              parseLimitEmail = 10;
              parseLimitEvent = 10;
              pushAttemptWait = 60000;
              pushMaxAttempts = 3;
              pushRequestTimeout = 10000;
              pushRetryWait = 1000;
              pushShardsTotal = 1;
              pushThrottle = 1000;
              pushVerifyTimeout = 60000;
              queryMaxResults = 5000;
              setMaxObjects = 500;
              snippetMaxResults = 100;
              uploadQuota = 50000000;
              uploadTtl = 3600000;
              webPushContact = null;
              webPushKey = {
                "@type" = "File";
                filePath = "/run/credentials/stalwart.service/vapid-key";
              };
              websocketHeartbeat = 60000;
              websocketThrottle = 1000;
              websocketTimeout = 600000;
            };
          }
        ];
      };
    };

    caddy.hosts = {
      stalwart = {
        fqdns = [
          fqdn
          "autoconfig.${domain}"
          "autodiscover.${domain}"
          "mta-sts.${domain}"
        ];
        reverseProxies."https://${fqdn}:8087" = { };
      };
      ${domain} = {
        reverseProxies."https://${fqdn}:8087" = {
          paths = [
            "/dav/*"
            "/jmap/*"
            "/.well-known/caldav"
            "/.well-known/carddav"
            "/.well-known/jmap"
          ];
        };
      };
    };
  };
}
