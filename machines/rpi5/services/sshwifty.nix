{
  config,
  ...
}:
let
  fqdn = "ssh.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets = {
    "sshwifty/sharedkey".owner = "root";
  };

  services = {
    caddy.hosts.${fqdn} = {
      reverseProxies."http://${fqdn}:8099" = { };
      basicAuth = {
        user = "david";
        hash = "$2b$05$/lL3Z49W7HZYObGWxkdVkuyyYBvMacdd/FtMr4lAHtSWIkAumPgie";
      };
    };

    sshwifty = {
      enable = true;
      sharedKeyFile = config.sops.secrets."sshwifty/sharedkey".path;
      settings = {
        HostName = fqdn;
        Servers = [
          {
            ListenInterface = "::1";
            ListenPort = 8099;
          }
        ];
        OnlyAllowPresetRemotes = true;
        Presets = [
          {
            Title = "rpi5";
            Type = "SSH";
            Host = "rpi5.${domain}:22";
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
            Host = "ryuzu.${domain}:22";
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
  };
}
