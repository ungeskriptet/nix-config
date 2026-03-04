{ ... }:
{
  programs.git = {
    enable = true;
    settings = import ./config.nix;
  };
}
