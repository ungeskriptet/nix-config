{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dig
    fastfetch
    file
    git
    htop
    inetutils
    internetarchive
    ripgrep
    sops
    tmux
    unzip
    zip
  ];
}
