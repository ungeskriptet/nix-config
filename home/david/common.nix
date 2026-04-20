{
  lib,
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  cfg = config.hm-config;
in
{
  imports = [
    ./ssh
    ./vars.nix
    ./accounts/common.nix
    ../common.nix
  ];

  sops = lib.mkIf cfg.trusted {
    defaultSopsFile = ../../secrets/secrets-david.yaml;
    secrets = {
      "adb/privkey" = {
        path = "${homeDir}/.android/adbkey";
        mode = "0400";
      };
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
    file = lib.mkIf cfg.dotfiles (
      {
        ".android/adbkey.pub".source = ./dotfiles/adbkey.pub;
        ".ssh/id_ed25519.pub".source = ./dotfiles/ssh/id_ed25519.pub;
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
}
