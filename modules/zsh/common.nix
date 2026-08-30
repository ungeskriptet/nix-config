{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zsh-david;
in
{
  imports = [
    ./options.nix
    ./zshrc.nix
  ];
  programs = {
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      setOptions = [
        "PROMPT_SUBST"
        "HIST_IGNORE_SPACE"
      ];
      enableCompletion = true;
      shellAliases = {
        # keep-sorted start block=yes
        c = "bat -pp";
        compress-vid = "ffmpeg -vcodec libx264 -crf 28 output.mp4 -i";
        f = "nix fmt";
        g = "git";
        gc = "nh clean all";
        gco = "nh clean all --optimise";
        gr = "cd $(git rev-parse --show-toplevel)";
        heimdall = "heimdall-wait-for-device";
        j = "journalctl";
        jeu = "journalctl -eu";
        jfu = "journalctl -fu";
        ls = "ls --color=auto";
        n = "nix";
        nb = "nix-build";
        nd = "nix develop";
        nixpkgs-info = lib.concatStringsSep " " [
          "nix flake metadata nix-config --json |"
          "jq '.locks.nodes.root.inputs.nixpkgs as $nixpkgs |"
          ".locks.nodes | to_entries[] |"
          "select(.key == $nixpkgs)'"
        ];
        nr = "nix run";
        ns = "nix-shell";
        rp = "realpath";
        rpi5 = "ssh root@rpi5";
        ryuzu = "ssh david@ryuzu";
        s = "systemctl";
        sc = "systemctl cat";
        start = "systemctl start";
        status = "systemctl status";
        stop = "systemctl stop";
        switch-nixos = "nh os switch /etc/nixos -LR --accept-flake-config --show-activation-logs";
        tftp-server = "sudo mkdir -p -m a=rwx tftp; sudo in.tftpd --foreground --listen --address :69 --secure --create ./tftp";
        v = "vim";
        wineprefix = "export WINEPREFIX=$(mktemp -d --suffix -wine)";
        yt-dlp-mp4 = "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'";
        # keep-sorted end
      }
      // lib.optionalAttrs cfg.nixOnDroid.enable {
        ping = "/system/bin/ping";
        start-sshd = "${lib.getExe' cfg.nixOnDroid.opensshPkg "sshd"} -f ${pkgs.writeText "sshd_config" ''
          HostKey /etc/ssh/ssh_host_ed25519_key
          Port 8022
          AllowUsers nix-on-droid
          PasswordAuthentication No
          KbdInteractiveAuthentication No
          Subsystem sftp ${cfg.nixOnDroid.opensshPkg}/libexec/sftp-server
        ''} -D";
        switch-nixondroid = "nix-on-droid switch -F path:/data/data/com.termux.nix/files/home/.config/nix-on-droid#nix-on-droid";
      };
      syntaxHighlighting.enable = true;
    };
  };
}
