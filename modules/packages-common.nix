{
  config,
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
    pixeldrain-cli.enable = lib.mkDefault true;
    htop.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    ssh = {
      startAgent = true;
      extraConfig = ''
        Host git-ssh.mainlining.org
          ProxyCommand ${lib.getExe pkgs.cloudflared} access ssh --hostname %h
      '';
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
