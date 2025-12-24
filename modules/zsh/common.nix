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
  ];
  programs = {
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      setOptions = [ "PROMPT_SUBST" ];
      enableCompletion = true;
      shellAliases =
        let
          ffmpeg = lib.getExe pkgs.ffmpeg;
          yt-dlp = lib.getExe pkgs.yt-dlp;
          heimdall = lib.getExe pkgs.heimdall;
        in
        {
          rp = "realpath";
          wineprefix = "export WINEPREFIX=$(mktemp -d --suffix -wine)";
        }
        // lib.optionalAttrs cfg.david.enable {
          compress-vid = "${ffmpeg} -vcodec libx264 -crf 28 output.mp4 -i";
          heimdall = "heimdall-wait-for-device && ${heimdall}";
          yt-dlp-mp4 = "${yt-dlp} -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'";
        }
        // lib.optionalAttrs (!cfg.homeManager.enable) {
          switch-nixos = "sudo nixos-rebuild switch --flake path:/etc/nixos#${config.networking.hostName} -L";
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
