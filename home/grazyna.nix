{ ... }:
{
  imports = [
    ./common.nix
    ./gnome.nix
  ];

  sops.defaultSopsFile = ../secrets/secrets-grazyna.yaml;

  home = {
    username = "grazyna";
    homeDirectory = "/home/grazyna";
  };
}
