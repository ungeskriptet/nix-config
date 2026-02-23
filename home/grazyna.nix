{ ... }:
{
  imports = [
    ./common.nix
    ./desktop.nix
    ./gnome.nix
  ];

  sops.defaultSopsFile = ../secrets/secrets-grazyna.yaml;

  home = {
    username = "grazyna";
    homeDirectory = "/home/grazyna";
  };
}
