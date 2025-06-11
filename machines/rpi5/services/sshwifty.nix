{ config, lib, pkgs, vars, ... }:

let
  domain = "ssh.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";

  sshwifty = let
    version = "0.3.23-beta-release-prebuild";
    url = "https://github.com/nirui/sshwifty/releases/download/0.3.23-beta-release-prebuild/sshwifty_0.3.23-beta-release_linux_arm64.tar.gz";
    src = pkgs.fetchzip {
    inherit url;
      sha256 = "sha256-pQpHjODjP7ic6M/hrufKNBCJlYzDvcBcP8cKyQSBkzE=";
      stripRoot = false;
    };
  in pkgs.runCommandLocal "sshwifty" {
    meta.mainProgram = "sshwifty";
  } ''
    mkdir -p $out/bin
    ln -s ${src}/sshwifty_linux_arm64 $out/bin/sshwifty
  '';
in
{
  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  sops.secrets = {
    "sshwifty/basicauth".owner = "caddy";
    "sshwifty/sharedkey".owner = "root";
  };

  services.caddy.virtualHosts."https://${domain}".extraConfig = ''
    tls ${tlsCert} ${tlsKey}
    reverse_proxy http://${domain}:8089
    basic_auth {
      import ${config.sops.secrets."sshwifty/basicauth".path}
    }
  '';

  systemd.services.sshwifty = {
    description = "Sshwifty";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      SSHWIFTY_HOSTNAME = domain;
      SSHWIFTY_LISTENINTERFACE = "127.0.0.1";
      SSHWIFTY_LISTENPORT = "8089";
    };
    serviceConfig = {
      ExecStart = lib.getExe sshwifty;
      EnvironmentFile = config.sops.secrets."sshwifty/sharedkey".path;
      DynamicUser = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      RemoveIPC = true;
      RestrictsUIDSGID = true;
    };
  };
}
