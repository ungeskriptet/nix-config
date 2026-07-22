{ ... }:
{
  imports = [
    ./common.nix
    ./gnome.nix
  ];

  sops.defaultSopsFile = ../secrets/secrets-grazyna.yaml;

  nix-config = {
    firefox = {
      preset = "default";
      language = "de";
    };
  };

  home = {
    username = "grazyna";
    homeDirectory = "/home/grazyna";
  };
}
