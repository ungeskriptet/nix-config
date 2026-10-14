{ lib, config, ... }:
let
  cfg = config.nix-config.networking;
in
{
  options = {
    nix-config.networking = {
      enable = lib.mkEnableOption "David's network config.";
      lanIpv4 = {
        address = lib.mkOption {
          type = lib.types.str;
          description = ''
            IPv4 address inside the LAN.
          '';
        };
        cidr = lib.mkOption {
          type = lib.types.ints.between 1 31;
          description = ''
            Subnet mask in CIDR notation.
          '';
        };
      };
      lanIpv6 = {
        address = lib.mkOption {
          type = lib.types.str;
          description = ''
            IPv6 ULA inside the LAN.
          '';
        };
      };
      lanDomain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "LAN domain.";
        default = null;
      };
      gatewayIpv4 = lib.mkOption {
        type = lib.types.str;
        description = ''
          IPv4 gateway address.
        '';
      };
      gatewayIpv6 = lib.mkOption {
        type = lib.types.str;
        description = ''
          IPv6 ULA for the gateway.
        '';
      };
      interface = lib.mkOption {
        type = lib.types.str;
        description = ''
          The primary network interface.
        '';
      };
      dns = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        description = ''
          Default DNS server to use.

          Defaults to localhost when left unset.
        '';
        default = null;
      };
      ipv6InterfaceId = lib.mkOption {
        type = lib.types.str;
        description = ''
          The interface ID to use for IPv6.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall.enable = true;
      useDHCP = false;
      useNetworkd = true;
    };

    systemd.network = {
      enable = true;
      networks."10-lan" = {
        matchConfig.Name = cfg.interface;
        linkConfig.RequiredForOnline = "routable";
        DHCP = "no";
        address = [
          (cfg.lanIpv4.address + "/" + toString cfg.lanIpv4.cidr)
        ];
        gateway = [ cfg.gatewayIpv4 ];
        domains = [ cfg.lanDomain ];
        dns =
          if (cfg.dns == null) then
            [
              "::1"
              "127.0.0.1"
            ]
          else
            cfg.dns;
        networkConfig = {
          IPv6AcceptRA = true;
          IPv6PrivacyExtensions = false;
        };
        ipv6AcceptRAConfig = {
          Token = cfg.ipv6InterfaceId;
        };
        dhcpV6Config = {
          UseAddress = false;
        };
      };
    };
  };
}
