{ config, lib, inputs, vars, ... }:

let
  domain = "ssh.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";

  arch = config.nixpkgs.hostPlatform.system;
  sshwifty = lib.getExe inputs.self.packages.${arch}.sshwifty;
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
      ExecStart = sshwifty;
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
