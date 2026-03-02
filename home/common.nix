{
  config,
  pkgs,
  inputs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  programs = {
    home-manager.enable = true;
  };

  sops.age = {
    keyFile = "${homeDir}/.config/sops-nix/key.txt";
    generateKey = true;
  };

  home = {
    stateVersion = "26.05";
  };
}
