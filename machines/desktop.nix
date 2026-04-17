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
  imports = [
    ./common.nix
    ../modules/nm-nsupdate.nix
    ../modules/packages-desktop.nix
    ../modules/vr.nix
  ];

  config = lib.mkMerge [
    {
      home-manager = lib.mkIf (config.users.userName == "david") {
        users.david.imports = [ ../home/david/desktop.nix ];
      };

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
        networkmanager.enable = true;
        firewall = {
          allowedUDPPorts = [ 67 ];
          # Required for WireGuard
          checkReversePath = false;
        };
      };
    }
    (lib.mkIf cfg.david {
      nix-config.enableVirt = true;
      # Automatically inject payload when a Nintendo Switch is connected
      systemd.tmpfiles.rules = [ "d /var/lib/fusee-nano 0777 root root -" ];
      services.udev.extraRules = with pkgs; ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0955", ATTR{idProduct}=="7321", RUN+="${lib.getExe fusee-nano} /var/lib/fusee-nano/payload.bin"
      '';
    })
    (lib.mkIf cfg.enablePlasma {
      services = {
        desktopManager.plasma6.enable = true;
        displayManager.plasma-login-manager.enable = true;
      };

      environment = {
        plasma6.excludePackages = (
          with pkgs.kdePackages;
          [
            baloo
            baloo-widgets
            elisa
            khelpcenter
          ]
        );
        systemPackages = with pkgs; [ kdePackages.yakuake ];
      };

      environment = {
        etc."xdg/baloofilerc".source = (pkgs.formats.ini { }).generate "baloorc" {
          "Basic Settings" = {
            "Indexing-Enabled" = false;
          };
        };
      };

      systemd.user.services.ssh-add = {
        wantedBy = [ "default.target" ];
        requires = [ "ssh-agent.service" ];
        after = [ "ssh-agent.service" ];
        script = ''
          ${pkgs.openssh}/bin/ssh-add -q < /dev/null
        '';
        unitConfig.ConditionUser = "!@system";
        serviceConfig.Restart = "on-failure";
      };
    })
    (lib.mkIf (!cfg.david) {
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "-d";
      };
    })
  ];
}
