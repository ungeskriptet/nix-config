# ASRock B550M Pro4 AMD Desktop
{ ... }:
{
  imports = [
    ./games.nix
    ./hardware-configuration.nix
    ./home-assistant/powerdown.nix
    ./home-assistant/ssh.nix
    ./nginx.nix
    ../../modules/minecraft-server.nix
  ];

  networking = {
    interfaces.enp5s0.wakeOnLan.enable = true;
  };

  security = {
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (action.id == "com.bitwarden.Bitwarden.unlock" && subject.isInGroup("wheel")) {
              return polkit.Result.YES;
          }
      });
    '';
    sudo.wheelNeedsPassword = false;
  };

  users.hashedPassword = "$y$j9T$sMN/eKYxYfh97dxUFDtzf.$sD76l.o1RyplUGb./VV.m3/qgEOrHIh5MkhLoeDpXUB";

  nix-config = {
    deviceType = "desktop";
    vr = true;
    secureboot.enable = true;
    david = {
      enable = true;
      profile = "personal";
    };
    hardware = {
      enable = true;
      platform = "amd";
    };
  };

  home-manager.users.david = {
    hm-config.trusted = true;
    programs = {
      plasma = {
        configFile = {
          kscreenlockerrc.Daemon = {
            Autolock = false;
            Timeout = 0;
          };
        };
      };
    };
  };
}
