{
  config,
  pkgs,
  ...
}:
let
  fqdn = "webmail.${domain}";
  domain = config.networking.domain;
in
{
  networking.hosts = {
    "::1" = [ fqdn ];
    "127.0.0.1" = [ fqdn ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/roundcube/enigma 0750 roundcube roundcube -"
  ];

  services = {
    caddy.virtualHosts."https://${fqdn}".extraConfig = ''
      tls ${config.acme.tlsCert} ${config.acme.tlsKey}
      reverse_proxy http://${fqdn}:8091
    '';

    roundcube = {
      enable = true;
      hostName = fqdn;
      dicts = with pkgs.aspellDicts; [
        en
        de
        pl
      ];
      extraConfig = ''
        $config['imap_host'] = [
          'ssl://mail.${domain}:993' => 'Stalwart'
        ];
        $config['smtp_host'] = 'ssl://mail.${domain}:465';
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
        $config['managesieve_host'] = 'ssl://mail.${domain}:4190';
        $config['enigma_passwordless'] = true;
        $config['enigma_pgp_agent'] = '${pkgs.gnupg}/bin/gpg-agent';
        $config['enigma_pgp_binary'] = '${pkgs.gnupg}/bin/gpg';
        $config['enigma_pgp_gpgconf'] = '${pkgs.gnupg}/bin/gpgconf';
        $config['enigma_pgp_homedir'] = '/var/lib/roundcube/enigma';
        $config['session_lifetime'] = 1440;
        $config['message_show_email'] = true;
      '';
      plugins = [
        "archive"
        "enigma"
        "managesieve"
        "newmail_notifier"
      ];
    };

    nginx.virtualHosts.${fqdn} = {
      forceSSL = false;
      enableACME = false;
      listen = [
        {
          addr = "127.0.0.1";
          port = 8091;
        }
      ];
    };

    homer.settings.services = [
      {
        items = [
          {
            name = "Webmail";
            subtitle = "Roundcube email client";
            url = "https://${fqdn}";
            logo = "https://cdn.jsdelivr.net/gh/selfhst/icons@master/svg/roundcube.svg";
          }
        ];
      }
    ];
  };
}
