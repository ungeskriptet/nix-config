{
  config,
  lib,
  pkgs,
  inputs,
  vars,
  ...
}:

let
  domain = "ssh.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";

  arch = config.nixpkgs.hostPlatform.system;
  sshwifty = lib.getExe pkgs.sshwifty;
  hostKey = "/etc/ssh/ssh_host_rsa_key.pub";
  genPreset = pkgs.writers.writePython3 "sshwifty-genpreset" { } ''
    from base64 import b64decode, b64encode
    from hashlib import sha256
    from json import dumps

    with open('/etc/ssh/ssh_host_rsa_key.pub', 'r') as keyfile:
        pubkey = keyfile.read().split(' ')[1]
        sha256 = sha256()
        sha256.update(b64decode(pubkey))
        b64fingerprint = b64encode(sha256.digest()).decode().split('=')[0]
        preset = [
            {
                'Title': 'rpi5',
                'Type': 'SSH',
                'Host': 'rpi5:22',
                'Meta': {
                    'User': 'root',
                    'Encoding': 'utf-8',
                    'Authentication': 'Private Key',
                    'Fingerprint': f'SHA256:{b64fingerprint}'
                }
            }
        ]
        print(f"SSHWIFTY_PRESETS='{dumps(preset)}'")
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
    script = ''
      eval $(${genPreset})
      export SSHWIFTY_PRESETS
      exec ${sshwifty}
    '';
    serviceConfig = {
      EnvironmentFile = config.sops.secrets."sshwifty/sharedkey".path;
      DynamicUser = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      RemoveIPC = true;
      RestrictSUIDSGID = true;
    };
  };
}
