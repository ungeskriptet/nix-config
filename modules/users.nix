{
  config,
  lib,
  pkgs,
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
      description = "Username for the default user.";
    };
    userDescription = lib.mkOption {
      type = lib.types.str;
      default = "David";
      description = "GECOS description for the default user.";
    };
    hashedPassword = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Hashed password for the default user.";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.hashedPassword != null;
        message = "Please set config.users.hashedPassword";
      }
    ];

    users = {
      mutableUsers = false;
      users = {
        ${cfg.userName} = {
          isNormalUser = true;
          description = cfg.userDescription;
          extraGroups = [
            "dialout"
            "input"
            "wheel"
          ]
          ++ lib.optionals config.networking.networkmanager.enable [ "networkmanager" ]
          ++ lib.optionals config.programs.tcpdump.enable [ "pcap" ]
          ++ lib.optionals config.programs.wireshark.enable [ "wireshark" ]
          ++ lib.optionals config.virtualisation.libvirtd.enable [ "libvirt" ]
          ++ lib.optionals config.virtualisation.podman.enable [ "podman" ];
          hashedPassword = cfg.hashedPassword;
          openssh.authorizedKeys.keys =
            config.vars.sshPubKeys
            ++ lib.optionals (config.networking.hostName == "ryuzu") [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCo1aBmLiSmZrjtnFVYczuv4/cNXjxF+4soUTSIeZla hass"
            ];
        };
        root = {
          openssh.authorizedKeys.keys = config.vars.sshPubKeys;
        };
      };
    }
    // lib.optionalAttrs config.programs.zsh.enable { defaultUserShell = pkgs.zsh; };
  };
}
