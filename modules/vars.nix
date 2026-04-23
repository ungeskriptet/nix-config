{ lib, ... }:
{
  imports = [
    ./common-vars.nix
  ];
  options = {
    networking = {
      lanIPv4 = lib.mkOption {
        type = lib.types.str;
        description = "IPv4 address inside the LAN";
      };
      lanIPv6 = lib.mkOption {
        type = lib.types.str;
        description = "IPv6 address inside the LAN";
      };
      lanDomain = lib.mkOption {
        type = lib.types.str;
        description = "LAN domain";
        default = "fritz.box";
      };
      gatewayIP = lib.mkOption {
        type = lib.types.str;
        description = "Default gateway IP";
        default = "192.168.64.1";
      };
      secGatewayIP = lib.mkOption {
        type = lib.types.str;
        description = "Secondary Gateway IP";
        default = "192.168.64.15";
      };
    };
    nix-config = {
      enablePlasma = lib.mkEnableOption "Plasma";
      david = lib.mkEnableOption "David's desktop configs";
    };
  };
}
