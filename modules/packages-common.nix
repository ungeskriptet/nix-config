{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  selfPkgs = inputs.self.packages.${pkgs.system};
in
{
  programs = {
    git.enable = true;
    htop.enable = true;
    pixeldrain-cli.enable = lib.mkDefault true;
    ssh.startAgent = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    tmux = {
      enable = true;
      extraConfig = ''
        set -g mouse on
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    android-tools
    binutils
    binwalk
    dig
    dnsmasq
    dtc
    exfat
    ffmpeg
    file
    inetutils
    internetarchive
    jq
    lz4
    ncdu
    p7zip
    pciutils
    picocom
    pv
    python3
    ripgrep
    rsync
    samfirm-js
    sops
    unrar
    unzip
    usbutils
    zip

    selfPkgs.mdns-scan
  ];
}
