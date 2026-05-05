# ASRock B550M Pro4 AMD Desktop
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./home-assistant/powerdown.nix
    ./home-assistant/ssh.nix
    ./itgmania.nix
    ../desktop.nix
    ../../modules/minecraft-server.nix
  ];

  sops.defaultSopsFile = ../../secrets/secrets-ryuzu.yaml;

  networking = {
    hostName = "ryuzu";
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
    david = true;
    enablePlasma = true;
    vr = true;
    secureboot.enable = true;
    hardware = {
      enable = true;
      platform = "amd";
    };
  };

  home-manager.users.david.config.hm-config.trusted = true;
}
