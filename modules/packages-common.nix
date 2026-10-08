{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.nix-config;
  selfPkgs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
  dig = lib.removeAttrs pkgs.dig [ "man" ]; # Fix collision with pkgs.host
in
{
  programs = {
    bat.enable = true;
    nix-index-database.comma.enable = true;
    tcpdump.enable = true;
    htop = {
      enable = true;
      settings = {
        "screen:Main" =
          "PID USER PRIORITY NICE M_VIRT M_RESIDENT M_SHARE STATE PERCENT_CPU PERCENT_MEM ELAPSED Command";
        "tree_view" = 1;
      };
    };
    mosh = {
      enable = true;
      openFirewall = true;
      withUtempter = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    nix-index = {
      enableBashIntegration = false;
      enableZshIntegration = false;
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
        set -g default-terminal "screen-256color"
      '';
    };
  };

  environment.systemPackages =
    with pkgs;
    [
      # keep-sorted start
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
      lsof
      lz4
      ncdu
      nh
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
      # keep-sorted end

      selfPkgs.rg-uuid
    ]
    ++ lib.optionals cfg.david [
      # keep-sorted start
      b4
      binwalk
      dtc
      git-crypt
      git-lfs
      internetarchive
      nix-update
      samloader-rs
      sops
      ssh-to-age
      # keep-sorted end
    ];
}
