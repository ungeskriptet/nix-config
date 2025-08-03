{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

let
  domain = "irc.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";

  gamjaIcon = pkgs.stdenv.mkDerivation {
    name = "gamja-icon";
    src = pkgs.fetchurl {
      url = "https://codeberg.org/emersion/goguma/raw/commit/a77804963d6cd79603484661b9319188e133d800/android/app/src/main/res/drawable-hdpi/ic_stat_name.png";
      hash = "sha256-3FcQdPr2mIsp9zkefNdaz26ajRcZbJUW3ohgYlDlNOk=";
    };
    dontUnpack = true;
    installPhase = "install -D -m 0755 $src $out/favicon.ico";
  };
in
{
  networking.firewall = {
    allowedTCPPorts = [ 6697 ];
  };

  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  users = {
    groups.soju = { };
    users.soju = {
      group = "soju";
      isSystemUser = true;
      createHome = false;
    };
  };

  systemd.services.soju = {
    requires = [ "postgresql.target" ];
    after = [ "postgresql.target" ];
    postStart = ''
      while [[ ! -S /run/soju/socket ]]; do
        sleep 1
      done
      chmod 660 /run/soju/socket
    '';
    serviceConfig.SupplementaryGroups = [ "acme" ];
  };

  systemd.services.caddy = {
    serviceConfig.SupplementaryGroups = [ "soju" ];
  };

  services.postgresql = {
    ensureDatabases = [ "soju" ];
    ensureUsers = [
      {
        name = "soju";
        ensureDBOwnership = true;
      }
    ];
  };

  services.caddy.virtualHosts = {
    "https://${domain}" = {
      extraConfig = ''
        tls ${tlsCert} ${tlsKey}
        @uploads path /uploads /uploads/*
        reverse_proxy @uploads unix//run/soju/socket
        reverse_proxy /socket unix//run/soju/socket
        respond /config.json {"server":{"url":"/socket","auth":"mandatory"}} 200
        root /favicon.ico ${gamjaIcon}
        root ${pkgs.gamja}
        file_server
      '';
    };
  };

  services.soju = {
    enable = true;
    configFile = pkgs.writeText "soju.conf" ''
      listen http+unix:///run/soju/socket
      listen ircs://:6697
      listen unix+admin:///run/soju/admin
      hostname ${domain}
      tls ${tlsCert} ${tlsKey}
      db postgres "host=/run/postgresql dbname=soju"
      message-store db
      accept-proxy-ip localhost
      file-upload fs /var/lib/soju/uploads
      title "David's IRC Bouner"
    '';
  };
}
