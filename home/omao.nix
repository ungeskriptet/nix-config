{ ... }:
{
  imports = [
    ./common.nix
    ./gnome.nix
  ];

  nix-config = {
    firefox = {
      preset = "default";
      language = "de";
    };
    thunderbird = {
      preset = "default";
      language = "de";
    };
  };

  home = {
    username = "omao";
    homeDirectory = "/home/omao";
  };
}
