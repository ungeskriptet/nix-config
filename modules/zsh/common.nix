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
      shellAliases =
        let
          bat = lib.getExe pkgs.bat;
          ffmpeg = lib.getExe pkgs.ffmpeg;
          heimdall = lib.getExe pkgs.heimdall;
          yt-dlp = lib.getExe pkgs.yt-dlp;
        in
        {
          gr = "cd $(git rev-parse --show-toplevel)";
          ls = "ls --color=auto";
          rp = "realpath";
          wineprefix = "export WINEPREFIX=$(mktemp -d --suffix -wine)";
        }
        // lib.optionalAttrs cfg.david.enable {
          c = "${bat} -pp";
          compress-vid = "${ffmpeg} -vcodec libx264 -crf 28 output.mp4 -i";
          heimdall = "heimdall-wait-for-device && ${heimdall}";
          rpi5 = "ssh root@rpi5";
          ryuzu = "ssh david@ryuzu";
          tftp-server = "sudo mkdir -p -m a=rwx tftp; sudo in.tftpd --foreground --listen --address :69 --secure --create ./tftp";
          yt-dlp-mp4 = "${yt-dlp} -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'";
        }
        // lib.optionalAttrs (!cfg.homeManager.enable) {
          nixpkgs-info = lib.concatStringsSep " " [
            "nix flake metadata nix-config --json |"
            "jq '.locks.nodes.root.inputs.nixpkgs as $nixpkgs |"
            ".locks.nodes | to_entries[] |"
            "select(.key == $nixpkgs)'"
          ];
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
