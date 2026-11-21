{ ... }:
{
  imports = [
    ./common.nix
    ./gnome.nix
  ];

  nix-config = {
    firefox = {
      preset = "default";
      language = "pl";
    };
    thunderbird = {
      preset = "default";
      language = "pl";
    };
  };
}
