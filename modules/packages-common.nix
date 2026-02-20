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
    bat.enable = true;
    git.enable = true;
    tcpdump.enable = true;
    htop = {
      enable = true;
      settings = {
        "screen:Main" =
          "PID USER PRIORITY NICE M_VIRT M_RESIDENT M_SHARE STATE PERCENT_CPU PERCENT_MEM ELAPSED Command";
        "tree_view" = 1;
      };
    };
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
      baseIndex = 1;
      extraConfig = ''
        set -g mouse on
        set -g renumber-windows on
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
      parted
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
