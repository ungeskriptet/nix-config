{ config, ... }:
let
  fqdn = "firefox.${domain}";
  domain = config.networking.domain;
in
{
  networking.hosts."::1" = [ fqdn ];
  networking.hosts."127.0.0.1" = [ fqdn ];
  networking.firewall.extraForwardRules = ''
    iifname podman0 oifname end0 accept
  '';

  sops.secrets."firefox/basicauth".owner = "caddy";

  systemd.tmpfiles.rules = [
    "d /var/lib/firefox-kasmvnc 0755 root root -"
  ];

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };

  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers."firefox" = {
    image = "lscr.io/linuxserver/firefox:latest";
    environment = {
      "FIREFOX_CLI" = "https://data.nicolas17.xyz/samsung-grab/";
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Europe/Berlin";
    };
    volumes = [
      "/var/lib/firefox-kasmvnc:/config:rw"
    ];
    ports = [
      "127.0.0.1:8090:3001/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--security-opt=seccomp:unconfined"
      "--shm-size=1073741824"
    ];
  };

  services.caddy.virtualHosts = {
    "https://${fqdn}".extraConfig = ''
            tls ${config.acme.tlsCert} ${config.acme.tlsKey}
            basic_auth {
              import ${config.sops.secrets."firefox/basicauth".path}
            }
            reverse_proxy https://${fqdn}:8090 {
              transport http {
      	  tls
      	  tls_insecure_skip_verify
      	}
            }
    '';
  };
}
