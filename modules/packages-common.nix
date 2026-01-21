{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.nix-config;
  samsung-grab = inputs.samsung-grab.packages.${pkgs.stdenv.hostPlatform.system}.samsung-grab;
  selfPkgs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs = {
    git.enable = true;
    htop.enable = true;
    tcpdump.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    ssh = lib.mkIf (config.services.gnome.gcr-ssh-agent.enable == false) {
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
      exfatprogs
      ffmpeg
      file
      inetutils
      jq
      killall
      lz4
      ncdu
      openssl
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
