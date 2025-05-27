{ config, ... }:

let
  interfaceName = "end0";
in
{
  sops.secrets = {
    "wireguard/rpi5/privkey".owner = "systemd-network";
    "wireguard/rpi5/psk-1".owner = "systemd-network";
    "wireguard/rpi5/psk-2".owner = "systemd-network";
  };

  networking.nat = {
    enable = true;
    externalInterface = "end0";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall.allowedUDPPorts = [ 33434 ];

  systemd.network = {
    enable = true;
    netdevs = {
      "50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          MTUBytes = "1420";
          Name = "wg0";
        };
        wireguardConfig = {
          ListenPort = 33434;
          PrivateKeyFile = config.sops.secrets."wireguard/rpi5/privkey".path;
        };
        wireguardPeers = [
          {
            AllowedIPs = [ "192.168.128.2/32" "fd96::2/128" ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/rpi5/psk-1".path;
            PublicKey = "YRC+IrnNovLJWW3qXi0LydpwuMQ8NtaH+9I6/rVzXHQ=";
          }
          {
            AllowedIPs = [ "192.168.128.3/32" "fd96::3/128"];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/rpi5/psk-2".path;
            PublicKey = "3aqGBPeBmtL9n4yqX7kG5TZ8yugsr0iQWq2WZlBxbzk=";
          }
        ];
      };
    };
    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = [ "192.168.128.1/24" "fd96::1/64" ];
      networkConfig = {
        IPMasquerade = "both";
      };
    };
  }; 
}
