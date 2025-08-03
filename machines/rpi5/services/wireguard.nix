{
  config,
  lib,
  pkgs,
  ...
}:

let
  interfaceName = "end0";
in
{
  sops.secrets =
    lib.genAttrs
      [
        "wireguard/rpi5/privkey"
        "wireguard/rpi5/psk-1"
        "wireguard/rpi5/psk-2"
        "wireguard/rpi5/psk-3"
        "wireguard/support/privkey"
        "wireguard/support/psk-1"
        "wireguard/support/psk-2"
      ]
      (secret: {
        owner = "systemd-network";
      });

  networking.nat = {
    enable = true;
    externalInterface = "end0";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall.allowedUDPPorts = [
    33434
    53286
  ];

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

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
            AllowedIPs = [
              "192.168.128.2/32"
              "fd96::2/128"
            ]; # xiatian
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/rpi5/psk-1".path;
            PublicKey = "ucC5RYVWTZWuJPjJjdAgq2Vw4kCnlLTdftnll0GOgzU=";
          }
          {
            AllowedIPs = [
              "192.168.128.3/32"
              "fd96::3/128"
            ]; # surya
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/rpi5/psk-2".path;
            PublicKey = "3aqGBPeBmtL9n4yqX7kG5TZ8yugsr0iQWq2WZlBxbzk=";
          }
          {
            AllowedIPs = [
              "192.168.128.4/32"
              "fd96::4/128"
            ]; # e3q
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/rpi5/psk-3".path;
            PublicKey = "lWicyBn8SEltKKGSVNZMJ4KodIDdnGqNO5DtiaGzqT0=";
          }
        ];
      };
      "51-wg1" = {
        netdevConfig = {
          Kind = "wireguard";
          MTUBytes = "1420";
          Name = "wg1";
        };
        wireguardConfig = {
          ListenPort = 53286;
          PrivateKeyFile = config.sops.secrets."wireguard/support/privkey".path;
        };
        wireguardPeers = [
          {
            AllowedIPs = [ "192.168.3.4/32" ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/support/psk-1".path;
            PublicKey = "4wC5jefLRAvgsqSWX0XOtRCJ1HFKsjCD211JMnTgM3I=";
          }
          {
            AllowedIPs = [ "192.168.3.2/32" ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/support/psk-2".path;
            PublicKey = "4oTuxNTPPqamD9fuQkdzpPILoDufM0Bh18jxrg1uZFM=";
          }
        ];
      };

    };
    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = [
        "192.168.128.1/24"
        "fd96::1/64"
      ];
      networkConfig = {
        IPMasquerade = "both";
      };
    };
    networks.wg1 = {
      matchConfig.Name = "wg1";
      address = [ "192.168.3.1/24" ];
    };
  };
}
