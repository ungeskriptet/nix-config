{ ... }:
{
  imports = [
    ./common.nix
    ./gnome.nix
  ];

  sops.defaultSopsFile = ../secrets/secrets-omao.yaml;

  home = {
    username = "omao";
    homeDirectory = "/home/omao";
  };
}
