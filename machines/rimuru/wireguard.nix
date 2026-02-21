{ lib, config, ... }:
{
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
        ips = [ "192.168.3.7/24" ];
        privateKeyFile = config.sops.secrets."wireguard/rpi5/privkey".path;
        peers = [
          {
            name = "rpi5";
            allowedIPs = [ "192.168.3.0/24" ];
            endpoint = "david-w.eu:53286";
            persistentKeepalive = 25;
            presharedKeyFile = config.sops.secrets."wireguard/rpi5/psk".path;
            publicKey = "8GcNH4kbA+BEmNnWwHDr79y2b91izCfVb40MFB+fRm4=";
          }
        ];
      };
    };
  };
}
