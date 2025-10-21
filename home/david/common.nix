{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  imports = [
    ./email.nix
    ./vars.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets-david.yaml;
    age.keyFile = "${homeDir}/.config/sops-nix/key.txt";
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
    };
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      userName = config.myuser.realName;
      userEmail = "david.wronek@mainlining.org";
      extraConfig = {
        sendemail.identity = "mainlining";
        patatt = {
          signingkey = "ed25519:20250914";
          selector = "20250914";
        };
      };
    };
    home-manager.enable = true;
  };

  home = {
    username = lib.mkDefault "david";
    homeDirectory = lib.mkDefault "/home/david";
    stateVersion = "25.05";
    file = {
      ".android/adbkey.pub".source = ./dotfiles/adbkey.pub;
      ".ssh/config".text = import ./dotfiles/ssh/config.nix { inherit lib pkgs; };
      ".ssh/id_ed25519.pub".source = ./dotfiles/ssh/id_ed25519.pub;
    }
    // lib.mergeAttrsList (
      builtins.map (file: { ".local/share/patatt/public/${file}".source = ./dotfiles/patattkey.pub; }) [
        "ed25519/mainlining.org/david.wronek/20250914"
        "ed25519/mainlining.org/david.wronek/default"
        "20250914.pub"
      ]
    );
  };
}
