{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.zsh-david;
in
{
  options.programs.zsh-david = {
    nixOnDroid = {
      enable = lib.mkEnableOption "Nix-on-Droid";
      opensshPkg = lib.mkPackageOption pkgs "openssh" { };
    };
    homeManager.enable = lib.mkEnableOption "Home Manager";
    david.enable = lib.mkEnableOption "David's configs" // {
      default = true;
    };
    histSize = lib.mkOption {
      type = lib.types.int;
      description = "History size for zsh";
      default = 10000;
    };
    gitinfo.enable = lib.mkEnableOption "Git info in the prompt" // {
      default = if cfg.nixOnDroid.enable then false else true;
    };
    prompt = lib.mkOption {
      type = lib.types.lines;
      description = "Zsh prompt";
      default = ''
        [ $UID = 0 ] && COLOR="{red}" || COLOR="{${if cfg.nixOnDroid.enable then "yellow" else "magenta"}}"
        PROMPT="╭─%F''${COLOR}${
          if cfg.nixOnDroid.enable then "nix-on-droid" else "%n@%m"
        }%f %F{blue}%~%f${lib.optionalString cfg.gitinfo.enable "\\$gitinfo"}
        ╰─ "
      '';
    };
    zshrc = lib.mkOption {
      type = lib.types.lines;
      description = ".zshrc content";
      default =
        let
          adb = lib.getExe' pkgs.android-tools "adb";
          curl = lib.getExe pkgs.curl;
          git = lib.getExe pkgs.git;
          heimdall = lib.getExe pkgs.heimdall;
          jq = lib.getExe pkgs.jq;
          readelf = lib.getExe' pkgs.binutils "readelf";
        in
        lib.mkBefore ''
          zstyle ':completion:*' menu select

          autoload -U edit-command-line \
            bracketed-paste-magic \
            down-line-or-beginning-search \
            history-search-end \
            select-word-style \
            up-line-or-beginning-search \
            url-quote-magic

          ${lib.optionalString cfg.homeManager.enable ''
            autoload -U bashcompinit && bashcompinit
            ${cfg.prompt}
          ''}

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

          export WORDCHARS="''${WORDCHARS/\/}"
          export WORDCHARS="''${WORDCHARS/.}"

          [ $UID = 0 ] &&
            [ -z $SSH_AGENT_PID ] &&
            [ $SSH_AUTH_SOCK = "/run/user/0/ssh-agent" ] &&
            eval $(ssh-agent -s)

          duplines () {
            sort $1 | uniq --count --repeated
          }
          ${lib.optionalString cfg.david.enable ''
            fdroid-install () {
              echo "< waiting for any device >"
              ${adb} wait-for-device &&
              rm -f "$1.apk"
              ${curl} https://f-droid.org/repo/$1_$(${curl} -s https://f-droid.org/api/v1/packages/$1 | ${jq} .suggestedVersionCode).apk -o "$1.apk"
              ${adb} install "$1.apk"
              [[ $2 = "--no-rm" ]] || rm -f "$1.apk"
            }
            heimdall-wait-for-device () {
              echo "< waiting for any device >"
              while ! ${heimdall} detect > /dev/null 2>&1; do
                sleep 1
              done
            }
            libneeds () {${readelf} -d $1 |grep '\(NEEDED\)' | sed -r 's/.*\[(.*)\]/\1/'}
          ''}
          gh-cherry-pick () {
            curl https://github.com/$1/commit/$2.patch | git am
          }
          last-journalctl () {
            journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value $1`
          }
          ${lib.optionalString cfg.gitinfo.enable ''
            precmd () {
              gitinfo=$(${git} branch --show-current 2> /dev/null)
              [[ -z $gitinfo ]] && return
              [[ -z $(${git} status --porcelain 2> /dev/null) ]] && gitinfo="%F{green} ($gitinfo)%f" ||
              gitinfo="%F{yellow} ($gitinfo %B●%b)%f"
            }
          ''}
          search () {[ -z "$2" ] && find . -iname "*$1*" | cut -c3- || find $2 -iname "*$1*"}
          stfu () {
              $@>/dev/null 2>&1 &!
          }
          ucd () {for i in $(seq 1 $1); do cd ..; done}
          wherebin () {readlink $(which $1)}
          ${lib.optionalString config.programs.zoxide.enableZshIntegration ''
            zoxidezle () { zle -I; zi }
            zle -N zoxidezle zoxidezle
            bindkey "^G" zoxidezle
          ''}
        '';
    };
  };
}
