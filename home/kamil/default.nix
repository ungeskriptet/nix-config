{ config, inputs, ... }:
{
  imports = [
    ./gnome.nix
    ../common-allusers.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets-kamil.yaml;
    age.generateKey = true;
    age.keyFile = "${config.home.homeDirectory}/.config/sops-nix/key.txt";
  };

  programs = {
    home-manager.enable = true;
  };

  home = {
    username = "kamil";
    homeDirectory = "/home/kamil";
    stateVersion = "25.05";
  };
}
