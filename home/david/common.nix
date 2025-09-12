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
    ./vars.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets-david.yaml;
    age.keyFile = "/home/david/.config/sops-nix/key.txt";
    secrets = {
      "adb/privkey" = {
        path = "${homeDir}/.android/adbkey";
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
    };
    home-manager.enable = true;
  };

  xdg.enable = true;

  home = {
    username = "david";
    homeDirectory = "/home/david";
    stateVersion = "25.05";
    file = {
      ".android/adbkey.pub".source = ./dotfiles/adbkey.pub;
      ".ssh/config".text = import ./dotfiles/ssh/config.nix { inherit lib pkgs; };
      ".ssh/id_ed25519.pub".source = ./dotfiles/ssh/id_ed25519.pub;
    };
  };
}
