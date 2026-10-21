{ ... }:
{
  imports = [
    ../../modules/git/home-manager.nix
    ../../modules/popt/home-manager.nix
    ../../modules/zsh/home-manager
    ./common.nix
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
    zsh-david = {
      david.enable = true;
      homeManager.enable = true;
    };
  };
}
