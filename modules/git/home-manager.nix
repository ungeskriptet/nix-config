{ lib, config, ... }:
{
  programs.git = lib.mkIf config.hm-config.dotfiles {
    enable = true;
    settings = import ./config.nix;
  };
}
