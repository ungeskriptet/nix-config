{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets-david.yaml;
    age.keyFile = "/home/david/.config/sops-nix/key.txt";
    secrets = {
      "ssh/privkey" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0400";
      };
    };
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      userName = "David Wronek";
      userEmail = "david.wronek@mainlining.org";
    };
    home-manager.enable = true;
  };

  home = {
    username = "david";
    homeDirectory = "/home/david";
    stateVersion = "25.05";
    file = {
      ".ssh/config".text = import ./ssh/config.nix { inherit lib pkgs; };
      ".ssh/id_ed25519.pub".source = ./ssh/id_ed25519.pub;
    };
  };
}
