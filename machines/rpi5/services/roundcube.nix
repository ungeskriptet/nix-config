{
  config,
  pkgs,
  vars,
  ...
}:

let
  domain = "webmail.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
in
{
  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  services.caddy.virtualHosts."https://${domain}".extraConfig = ''
    tls ${tlsCert} ${tlsKey}
    reverse_proxy http://${domain}:8091
  '';

  systemd.tmpfiles.rules = [
    "d /var/lib/roundcube/enigma 0750 roundcube roundcube -"
  ];

  services.roundcube = {
    enable = true;
    hostName = domain;
    dicts = with pkgs.aspellDicts; [
      en
      de
      pl
    ];
    extraConfig = ''
      $config['imap_host'] = [
        'ssl://mail.${baseDomain}:993' => 'Stalwart'
      ];
      $config['smtp_host'] = 'ssl://mail.${baseDomain}:465';
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      $config['managesieve_host'] = 'ssl://mail.${baseDomain}:4190';
      $config['enigma_passwordless'] = true;
      $config['enigma_pgp_agent'] = '${pkgs.gnupg}/bin/gpg-agent';
      $config['enigma_pgp_binary'] = '${pkgs.gnupg}/bin/gpg';
      $config['enigma_pgp_gpgconf'] = '${pkgs.gnupg}/bin/gpgconf';
      $config['enigma_pgp_homedir'] = '/var/lib/roundcube/enigma';
    '';
    plugins = [
      "archive"
      "enigma"
      "managesieve"
      "newmail_notifier"
    ];
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = false;
    enableACME = false;
    listen = [
      {
        addr = "127.0.0.1";
        port = 8091;
      }
    ];
  };
}
