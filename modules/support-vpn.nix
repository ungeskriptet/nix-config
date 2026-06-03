{
  lib,
  config,
  inputs,
  ...
}:
let
  domain = config.networking.domain;
  cfg = config.networking.supportVpn;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  options.networking.supportVpn.interfaceAddress = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "IPv4 address for the support VPN interface";
  };

  config = lib.mkIf (cfg.interfaceAddress != "") {
    sops.secrets = lib.genAttrs [ "wireguard/rpi5/privkey" "wireguard/rpi5/psk" ] (secret: {
      owner = "root";
    });

    networking = {
      networkmanager.unmanaged = [ "rpi5" ];
      wireguard = {
        enable = true;
        interfaces."rpi5" = {
          dynamicEndpointRefreshSeconds = 300;
          mtu = 1280;
          ips = [ "${cfg.interfaceAddress}/24" ];
          privateKeyFile = config.sops.secrets."wireguard/rpi5/privkey".path;
          peers = [
            {
              name = "rpi5";
              allowedIPs = [ "192.168.3.0/24" ];
              endpoint = "${domain}:53286";
              persistentKeepalive = 25;
              presharedKeyFile = config.sops.secrets."wireguard/rpi5/psk".path;
              publicKey = "8GcNH4kbA+BEmNnWwHDr79y2b91izCfVb40MFB+fRm4=";
            }
          ];
        };
      };
    };
  };
}
