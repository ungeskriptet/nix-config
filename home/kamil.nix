{ ... }:
{
  imports = [
    ./common.nix
    ./gnome.nix
  ];

  sops.defaultSopsFile = ../secrets/secrets-kamil.yaml;

  home = {
    username = "kamil";
    homeDirectory = "/home/kamil";
  };
}
