{ lib, ... }:
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

  hm-config = {
    david = lib.mkDefault true;
    trusted = lib.mkDefault false;
    dotfiles = lib.mkDefault false;
  };
}
