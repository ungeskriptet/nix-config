{
  config,
  inputs,
  lib,
  pkgs,
  vars,
  ...
}:

let
  cfg = config.users;
in
{
  options.users = {
    userName = lib.mkOption {
      type = lib.types.str;
      default = "david";
    };
    userDescription = lib.mkOption {
      type = lib.types.str;
      default = "David";
    };
  };

  config = {
    sops = {
      secrets."users/${cfg.userName}" = {
        neededForUsers = true;
        owner = "root";
      };
    };

    users = {
      mutableUsers = false;
      users.${cfg.userName} = {
        isNormalUser = true;
        description = cfg.userDescription;
        extraGroups = [
          "wheel"
        ]
        ++ lib.optionals config.networking.networkmanager.enable [ "networkmanager" ]
        ++ lib.optionals config.programs.wireshark.enable [ "wireshark" ]
        ++ lib.optionals config.virtualisation.libvirtd.enable [ "libvirt" ]
        ++ lib.optionals config.virtualisation.podman.enable [ "podman" ];
        hashedPasswordFile = config.sops.secrets."users/${cfg.userName}".path;
        openssh.authorizedKeys.keys =
          vars.sshPubKeys
          ++ lib.optionals (config.networking.hostName == "ryuzu") [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCo1aBmLiSmZrjtnFVYczuv4/cNXjxF+4soUTSIeZla hass"
          ];
      };
      users.root = {
        openssh.authorizedKeys.keys = vars.sshPubKeys;
      };
    }
    // lib.optionalAttrs config.programs.zsh.enable { defaultUserShell = pkgs.zsh; };
  };
}
