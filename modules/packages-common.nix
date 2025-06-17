{ config, pkgs, inputs, ... }:

let
  selfPkgs = inputs.self.packages.${pkgs.system};
in
{
  programs = {
    git.enable = true;
    htop.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    ssh = {
      startAgent = true;
    };
  };

  environment.systemPackages = with pkgs; [
    android-tools
    binutils
    binwalk
    dig
    dtc
    ffmpeg
    file
    inetutils
    internetarchive
    ncdu
    p7zip
    pciutils
    picocom
    pv
    python3
    ripgrep
    rsync
    sops
    tmux
    unrar
    unzip
    usbutils
    zip

    selfPkgs.mdns-scan
    (selfPkgs.pixeldrain-cli.override {
      apiKeyFile = config.sops.secrets."pixeldrain/apikey".path;
    })
    selfPkgs.samfirm-js
  ];

  sops = {
    secrets."pixeldrain/apikey".owner = "root";
    secrets."pixeldrain/apikey".mode = "0444";
  };
}
