{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nix-config;
in
{
  options.nix-config = {
    deviceType = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "desktop" ]);
      description = "The device type.";
      default = null;
    };
  };

  config = lib.mkIf (cfg.deviceType == "desktop") {
    sops.secrets."dns/tsig".owner = "root";

    services = {
      printing.enable = true;
      pulseaudio.enable = false;
      nm-nsupdate = {
        enable = true;
        fqdn = config.networking.fqdn;
        nameServer = "ns1.${config.networking.domain}";
        tsigKeyFile = config.sops.secrets."dns/tsig".path;
      };
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };

    networking = {
      firewall = {
        allowedUDPPorts = [
          67
          8612 # Canon Scanner
        ];
        # Required for WireGuard
        checkReversePath = false;
      };
      networkmanager = {
        enable = true;
        plugins = with pkgs; [
          networkmanager-openvpn
        ];
      };
    };
  };
}
