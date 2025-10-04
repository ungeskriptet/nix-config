{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.nix-config;
  samsung-grab = inputs.samsung-grab.packages.${pkgs.system}.samsung-grab;
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
    ssh = lib.mkIf (config.services.gnome.gcr-ssh-agent.enable == null) {
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

  environment.systemPackages =
    with pkgs;
    [
      android-tools
      binutils
      dig
      dnsmasq
      exfat
      ffmpeg
      file
      inetutils
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
      unrar
      unzip
      usbutils
      zip
    ]
    ++ lib.optionals cfg.david [
      b4
      binwalk
      dtc
      internetarchive
      samfirm-js
      sops

      samsung-grab
      selfPkgs.mdns-scan
    ];
}
