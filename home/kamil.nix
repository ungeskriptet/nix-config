{ ... }:
{
  imports = [
    ./common.nix
    ./gnome.nix
  ];

  sops.defaultSopsFile = ../secrets/secrets-kamil.yaml;

  nix-config = {
    firefox = {
      preset = "default";
      language = "pl";
    };
  };

  home = {
    username = "kamil";
    homeDirectory = "/home/kamil";
  };
}
