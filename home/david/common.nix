{
  lib,
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  cfg = config.hm-config.david;
in
{
  imports = [
    ./ssh
    ./vars.nix
    ../common.nix
  ];

  options.hm-config.david = {
    profile = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "personal" ]);
      description = ''
        Which profile to use for David's configs.
      '';
      default = null;
    };
  };

  config = {
    sops = lib.mkIf (cfg.profile == "personal") {
      secrets = {
        "adb/privkey" = {
          path = "${homeDir}/.android/adbkey";
          mode = "0400";
        };
        "github/token" = { };
        "patatt/privkey" = {
          path = "${homeDir}/.local/share/patatt/private/20250914.key";
          mode = "0400";
        };
        "ssh/privkey" = {
          path = "${homeDir}/.ssh/id_ed25519";
          mode = "0400";
        };
        "vt-cli/config" = {
          path = "${homeDir}/.vt.toml";
          mode = "0400";
        };
      };
      templates."nix.conf".content = ''
        access-tokens = github.com=${config.sops.placeholder."github/token"}
      '';
    };

    programs = {
      bash.shellAliases = {
        "cdtemp" = "cd $(mktemp -d)";
      };
      git = {
        enable = true;
        lfs.enable = true;
        settings = {
          sendemail.identity = "mainlining";
          patatt = {
            signingkey = "ed25519:20250914";
            selector = "20250914";
          };
          user = {
            name = config.myuser.realName;
            email = "david.wronek@mainlining.org";
          };
        };
      };
    };

    home = {
      username = lib.mkDefault "david";
      homeDirectory = lib.mkDefault "/home/david";
      file = lib.mkIf (cfg.profile == "personal") (
        {
          ".android/adbkey.pub".source = ./dotfiles/adbkey.pub;
          ".ssh/id_ed25519.pub".source = ./dotfiles/ssh/id_ed25519.pub;
          ".config/nix/nix.conf" = {
            source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."nix.conf".path;
            force = true;
          };
        }
        // lib.mergeAttrsList (
          map (file: { ".local/share/patatt/public/${file}".source = ./dotfiles/patattkey.pub; }) [
            "ed25519/mainlining.org/david.wronek/20250914"
            "ed25519/mainlining.org/david.wronek/default"
            "20250914.pub"
          ]
        )
      );
    };
  };
}
