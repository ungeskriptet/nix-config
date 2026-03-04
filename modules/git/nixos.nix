{ ... }:
{
  programs.git = {
    enable = true;
    config = import ./config.nix;
  };
}
