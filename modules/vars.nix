{ lib, ... }:
{
  options = {
    networking.lanIPv4 = lib.mkOption {
      type = lib.types.str;
      description = "IPv4 address inside the LAN";
    };
    networking.lanIPv6 = lib.mkOption {
      type = lib.types.str;
      description = "IPv6 address inside the LAN";
    };
    networking.lanDomain = lib.mkOption {
      type = lib.types.str;
      description = "LAN domain";
      default = "fritz.box";
    };
    networking.gatewayIP = lib.mkOption {
      type = lib.types.str;
      description = "Default gateway IP";
      default = "192.168.64.1";
    };
    networking.secGatewayIP = lib.mkOption {
      type = lib.types.str;
      description = "Secondary Gateway IP";
      default = "192.168.64.15";
    };
    nix-config.enablePlasma = lib.mkEnableOption "Plasma" // {
      default = true;
    };
    nix-config.david = lib.mkEnableOption "David's desktop configs" // {
      default = true;
    };
    vars.sshPubKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Trusted SSH public keys";
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+HHP+nC6vrDwqEbTgiNhFnaqD3WEBgZMq7FUPWV0Ls main@bitwarden"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDwbbh5g3ustRbSg1T8etYXTwVLC5QRTuhGhhT23sJwE david@key4"
      ];
    };
  };
}
