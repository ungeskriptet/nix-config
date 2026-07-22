{ ... }:
{
  imports = [
    ./common.nix
    ./gnome.nix
  ];

  sops.defaultSopsFile = ../secrets/secrets-omao.yaml;

  nix-config = {
    firefox = {
      preset = "default";
      language = "de";
    };
  };

  home = {
    username = "omao";
    homeDirectory = "/home/omao";
  };
}
