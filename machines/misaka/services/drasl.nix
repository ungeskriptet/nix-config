{ config, pkgs, ... }:
let
  fqdn = "drasl.${config.networking.domain}";
in
{
  imports = [ ../../../modules/drasl.nix ];

  services = {
    drasl = {
      enable = true;
      settings = {
        BaseURL = "https://${fqdn}";
        DefaultAdmins = [ "Ungeskriptet" ];
        Domain = fqdn;
        ForwardSkins = true;
        ListenAddress = "[::1]:8092";
        PlayerUUIDGeneration = "random";
        FallbackAPIServers = [
          {
            Nickname = "Mojang";
            DenyUnknownUsers = true;
            CacheTTLSeconds = 60;
            AccountURL = "https://api.mojang.com";
            ServicesURL = "https://api.minecraftservices.com";
            SessionURL = "https://sessionserver.mojang.com";
            SkinDomains = [ "textures.minecraft.net" ];
          }
        ];
        ImportExistingPlayer = {
          Allow = true;
          Nickname = "Mojang";
          AccountURL = "https://api.mojang.com";
          SessionURL = "https://sessionserver.mojang.com";
        };
        RegistrationNewPlayer = {
          Allow = true;
          RequireInvite = true;
        };
        RegistrationExistingPlayer = {
          Allow = true;
          RequireInvite = true;
        };
      };
    };
    caddy = {
      enable = true;
      virtualHosts = {
        "https://${fqdn}".extraConfig = ''
          tls ${config.acme.tlsCert} ${config.acme.tlsKey}
          reverse_proxy http://[::1]:8092
        '';
      };
    };
  };
}
