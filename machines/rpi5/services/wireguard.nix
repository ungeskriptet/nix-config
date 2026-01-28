{
  config,
  lib,
  pkgs,
  ...
}:
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
        "wireguard/support/psk-3"
        "wireguard/support/psk-4"
        "wireguard/support/psk-5"
        "wireguard/support/psk-6"
        "wireguard/support/psk-7"
        "wireguard/support/psk-8"
        "wireguard/netflix/privkey"
        "wireguard/netflix/psk-1"
        "wireguard/netflix/psk-2"
        "wireguard/netflix/psk-3"
        "wireguard/netflix/psk-4"
      ]
      (secret: {
        owner = "systemd-network";
      });

  boot = {
    kernelModules = [ "nf_nat_ftp" ];
    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.default.forwarding" = true;
      "net.ipv6.conf.all.accept_ra" = 2;
      "net.ipv6.conf.all.forwarding" = true;
      "net.ipv6.conf.default.accept_ra" = 2;
      "net.ipv6.conf.default.forwarding" = true;
    };
  };

  networking = {
    firewall = {
      allowedUDPPorts = [
        33434
        53286
        57349
      ];
      extraForwardRules = ''
        iifname "end0" oifname { "wg1", "wg2" } accept
        iifname "wg0" accept
        iifname "wg2" oifname "end0" meta l4proto { tcp, udp } th dport { 80, 443 } ip daddr != 192.168.0.0/16 accept
        iifname "wg2" oifname "end0" meta l4proto { tcp, udp } th dport { 80, 443 } ip6 daddr != fd00::/16 accept
      '';
    };
    nftables.tables.nixos-nat-custom = {
      family = "inet";
      content = ''
        chain pre {
                type nat hook prerouting priority dstnat; policy accept;
        }
        chain post {
                type nat hook postrouting priority srcnat; policy accept;
                iifname { "wg0", "wg2" } oifname "end0" masquerade
                oifname "wg1" masquerade
        }
        chain out {
                type nat hook output priority mangle; policy accept;
        }
      '';
    };
  };

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
            ]; # crownlte
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/rpi5/psk-2".path;
            PublicKey = "Kxg/OwMvTY1FG0kY18Kq/my/b2+QAQeQzavZdqve9Ds=";
          }
          {
            AllowedIPs = [
              "192.168.128.4/32"
              "fd96::4/128"
            ]; # e3q
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/rpi5/psk-3".path;
            PublicKey = "ImQpwLq5lv+ts5zKA82QycNyx2TIu6bLgSYLPMy5Y3c=";
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
          RouteTable = 96;
        };
        wireguardPeers = [
          {
            AllowedIPs = [ "192.168.3.4/32" ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/support/psk-1".path;
            PublicKey = "66ooPFrN5/ce2sAkm96mz2kShgsT0WTZm77ghzFCMno=";
          }
          {
            AllowedIPs = [ "192.168.3.2/32" ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/support/psk-2".path;
            PublicKey = "4oTuxNTPPqamD9fuQkdzpPILoDufM0Bh18jxrg1uZFM=";
          }
          {
            AllowedIPs = [ "192.168.3.11/32" ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/support/psk-3".path;
            PublicKey = "4hgNyQxySCsFnee8t4nCZX16hqkgs+P16dku1tngkCo=";
          }
          {
            AllowedIPs = [ "192.168.3.12/32" ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/support/psk-4".path;
            PublicKey = "77JDO2aRLAHOMbQTx6KqxJ1f3ulnm3CWXfe+BK+7H14=";
          }
          {
            AllowedIPs = [
              "192.168.3.13/32"
              "0.0.0.0/0"
            ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/support/psk-5".path;
            PublicKey = "OwTjaAnS6j5HvG+o2ysloZRxpD2buUkzOPVCsaQSYBo=";
          }
          {
            AllowedIPs = [ "192.168.3.3/32" ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/support/psk-6".path;
            PublicKey = "0zU//E78ALwoiXfvGLU/OO1O8ZOj6UvqwP2bbzwJTT4=";
          }
          {
            AllowedIPs = [ "192.168.3.5/32" ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/support/psk-7".path;
            PublicKey = "WjTGJ6HlgZNlPVIpKl/7OnaLu/+56DkKLNlvCVkn1z8=";
          }
          {
            AllowedIPs = [ "192.168.3.6/32" ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/support/psk-8".path;
            PublicKey = "qSpGolxn7FgZpefRyFjkZ7x8Up0IzFFbyL73GLq4BR4=";
          }
        ];
      };
      "52-wg2" = {
        netdevConfig = {
          Kind = "wireguard";
          MTUBytes = "1420";
          Name = "wg2";
        };
        wireguardConfig = {
          ListenPort = 57349;
          PrivateKeyFile = config.sops.secrets."wireguard/netflix/privkey".path;
          RouteTable = 36;
        };
        wireguardPeers = [
          {
            AllowedIPs = [
              "192.168.36.2/32"
              "fd36::2/128"
            ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/netflix/psk-1".path;
            PublicKey = "Z+dpBU2imvHy/wlVckmpre7qVyEWnG3K6O6waOLcIn4=";
          }
          {
            AllowedIPs = [
              "192.168.36.3/32"
              "fd36::3/128"
            ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/netflix/psk-2".path;
            PublicKey = "D5uVvbROZ6r+H+DV+XlmGBTdznD7mLS8FPpjhFe7hFc=";
          }
          {
            AllowedIPs = [
              "192.168.36.4/32"
              "fd36::4/128"
            ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/netflix/psk-3".path;
            PublicKey = "VNkHC2EdlNr92OsqShYPfPzBj54bxAhaT4TWQyG65kg=";
          }
          {
            AllowedIPs = [
              "192.168.36.5/32"
              "fd36::5/128"
            ];
            PersistentKeepalive = 25;
            PresharedKeyFile = config.sops.secrets."wireguard/netflix/psk-4".path;
            PublicKey = "vBnjpb8OQJ1ZMh+OSt+x4IJRGWKAnLmL5oWd9UpBfk4=";
          }
        ];
      };
    };
    networks = {
      wg0 = {
        matchConfig.Name = "wg0";
        address = [
          "192.168.128.1/24"
          "fd96::1/64"
        ];
      };
      wg1 = {
        matchConfig.Name = "wg1";
        addresses = [
          {
            Address = "192.168.3.1/24";
            AddPrefixRoute = false;
          }
        ];
        routingPolicyRules = [
          {
            To = "192.168.3.0/24";
            Table = 96;
          }
          {
            To = "192.168.96.0/24";
            Table = 96;
          }
          {
            From = "192.168.64.10";
            Table = 96;
          }
        ];
      };
      wg2 = {
        matchConfig.Name = "wg2";
        address = [
          "192.168.36.1/24"
          "fd36::1/64"
        ];
      };
    };
  };
}
