{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  samsung-grab = inputs.samsung-grab.packages.${pkgs.system}.samsung-grab;
  selfPkgs = inputs.self.packages.${pkgs.system};
in
{
  programs = {
    git.enable = true;
    htop.enable = true;
    pixeldrain-cli.enable = lib.mkDefault true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
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
    b4
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

    samsung-grab
    selfPkgs.mdns-scan
  ];
}
