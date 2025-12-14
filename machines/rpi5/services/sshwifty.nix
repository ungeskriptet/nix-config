{
  config,
  ...
}:
let
  fqdn = "ssh.${domain}";
  domain = config.networking.domain;
in
{
  networking.hosts = {
    "::1" = [ fqdn ];
    "127.0.0.1" = [ fqdn ];
  };

  sops.secrets = {
    "sshwifty/sharedkey".owner = "root";
  };

  services = {
    caddy.virtualHosts."https://${fqdn}".extraConfig = ''
      tls ${config.acme.tlsCert} ${config.acme.tlsKey}
      reverse_proxy http://${fqdn}:80
      basic_auth {
        david $2b$05$/lL3Z49W7HZYObGWxkdVkuyyYBvMacdd/FtMr4lAHtSWIkAumPgie
      }
    '';

    sshwifty = {
      enable = true;
      sharedKeyFile = config.sops.secrets."sshwifty/sharedkey".path;
      settings = {
        HostName = fqdn;
        Servers = [
          {
            ListenInterface = "::1";
            ListenPort = 80;
          }
        ];
        OnlyAllowPresetRemotes = true;
        Presets = [
          {
            Title = "rpi5";
            Type = "SSH";
            Host = "rpi5:22";
            TabColor = "110000";
            Meta = {
              User = "root";
              Encoding = "utf-8";
              Authentication = "Private Key";
              Fingerprint = "SHA256:35mSb4euaL49ndfSQQdYr5RV0TIlvb42/r8H3ryROYc";
            };
          }
          {
            Title = "ryuzu";
            Type = "SSH";
            Host = "ryuzu:22";
            TabColor = "000011";
            Meta = {
              User = "david";
              Encoding = "utf-8";
              Authentication = "Private Key";
              Fingerprint = "SHA256:joNUIEw6X8A/3zwN/wNygS8Ag9DKcxffwOsiaQjmRbs";
            };
          }
        ];
      };
    };

    homer.settings.services = [
      {
        items = [
          {
            name = "Sshwifty";
            subtitle = "Web-based SSH client";
            url = "https://${fqdn}";
            logo = "https://cdn.jsdelivr.net/gh/selfhst/icons@master/svg/sshwifty.svg";
          }
        ];
      }
    ];
  };
}
