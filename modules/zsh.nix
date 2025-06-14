{ config, lib, pkgs, ... }:

let
  ffmpeg = lib.getExe pkgs.ffmpeg;
  git = lib.getExe pkgs.git;
  readelf = lib.getExe' pkgs.binutils "readelf";
  yt-dlp = lib.getExe pkgs.yt-dlp;
in
{
  environment.sessionVariables.ZDOTDIR = "$HOME/.config/zsh";

  programs.zsh = {
    enable = true;

    histFile = "$HOME/.cache/zsh/zsh_history";
    histSize = 10000;
    setOptions = [
      "HIST_IGNORE_ALL_DUPS"
      "PROMPT_SUBST"
    ];

    enableBashCompletion = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      compress-vid = "${ffmpeg} -vcodec libx264 -crf 28 output.mp4 -i";
      rp = "realpath";
      switch-nixos = "sudo nixos-rebuild switch --flake path:.#${config.networking.hostName}";
      yt-dlp-mp4 = "${yt-dlp} -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'";
    };

    interactiveShellInit = ''
      zstyle ':completion:*' menu select

      autoload -Uz edit-command-line \
          bracketed-paste-magic \
          down-line-or-beginning-search \
          history-search-end \
          select-word-style \
          up-line-or-beginning-search \
          url-quote-magic

      zle -N bracketed-paste bracketed-paste-magic
      zle -N down-line-or-beginning-search
      zle -N edit-command-line
      zle -N self-insert url-quote-magic
      zle -N up-line-or-beginning-search

      bindkey -e
      bindkey "^H" backward-kill-word
      bindkey "^[[1;5D" backward-word
      bindkey "^[[H" beginning-of-line
      bindkey "^[[3~" delete-char
      bindkey "^[[B" down-line-or-beginning-search
      bindkey "^X^E" edit-command-line
      bindkey "^[[F" end-of-line
      bindkey "^[[1;5C" forward-word
      bindkey "^[[A" up-line-or-beginning-search

      mkdir -p $HOME/.cache/zsh

      export WORDCHARS="''${WORDCHARS//\/}"

      libneeds () {${readelf} -d $1 |grep '\(NEEDED\)' | sed -r 's/.*\[(.*)\]/\1/'}
      precmd () {
          gitinfo=$(${git} branch --show-current 2> /dev/null)
          [[ -z $gitinfo ]] && return
          [[ -z $(${git} status --porcelain 2> /dev/null) ]] && gitinfo="%F{green} ($gitinfo)%f" ||
          gitinfo="%F{yellow} ($gitinfo %B●%b)%f"
      }
      search () {[ -z "$2" ] && find . -iname "*$1*" | cut -c3- || find $2 -iname "*$1*"}
      stfu () {
          $@>/dev/null 2>&1 &!
      }
      ucd () {for i in $(seq 1 $1); do cd ..; done}
      wherebin () {readlink $(which $1)}
    '';

    promptInit = ''
      [ $UID = 0 ] && COLOR="{red}" || COLOR="{magenta}"
      PROMPT="╭─%F$COLOR%n@%M%f %F{blue}%~%f\$gitinfo
      ╰─ "
    '';
  };
}
