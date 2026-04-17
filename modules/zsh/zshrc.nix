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
  programs.zsh-david = {
    zshrc =
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
        bindkey "^[[1;5A" vi-forward-blank-word
        bindkey "^[[1;5B" vi-backward-blank-word

        mkdir -p $HOME/.cache/zsh

        export WORDCHARS="''${WORDCHARS/\/}"
        export WORDCHARS="''${WORDCHARS/.}"

        if [ "$UID" -eq 0 -a -z "$SSH_AGENT_PID" -a "$SSH_AUTH_SOCK" = "/run/user/0/ssh-agent" ]; then
          eval $(ssh-agent -s) > /dev/null
        fi

        kill-ssh-add () { ${lib.getExe pkgs.killall} ssh-add &> /dev/null }
        trap kill-ssh-add INT
        ssh-add -l &> /dev/null || ssh-add > /dev/null
        trap - INT

        export NIX_SSHOPTS="${
          lib.concatStringsSep " " [
            "-oIdentityAgent=$SSH_AUTH_SOCK"
            "-oStrictHostKeyChecking=no"
            "-oUserKnownHostsFile=/dev/null"
          ]
        }"

        source ${pkgs.fzf}/share/fzf/completion.zsh
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh

        duplines () {
          sort $1 | uniq --count --repeated
        }
        ${lib.optionalString cfg.david.enable ''
          adb-sideload () {
            echo "< waiting for any device >"
            adb wait-for-sideload
            adb sideload "$@"
          };
          fdroid-install () {
            echo "< waiting for any device >"
            ${adb} -d wait-for-device &&
            rm -f "$1.apk"
            ${curl} https://f-droid.org/repo/$1_$(${curl} -s https://f-droid.org/api/v1/packages/$1 | ${jq} .suggestedVersionCode).apk -o "$1.apk"
            ${adb} -d install "$1.apk"
            [[ $2 = "--no-rm" ]] || rm -f "$1.apk"
          }
          heimdall-wait-for-device () {
            echo "< waiting for any device >"
            while ! ${heimdall} detect > /dev/null 2>&1; do
              sleep 1
            done
          }
          libneeds () {
            ${readelf} -d $1 |grep '\(NEEDED\)' | sed -r 's/.*\[(.*)\]/\1/'
          }
          python-shell () {
            nix-shell -p "python3.withPackages (ps: with ps; [ $* ])"
          }
        ''}
        gh-cherry-pick () {
          curl https://github.com/$1/commit/$2.patch | git am
        }
        git-remote () {
          if [ -z "$1" ]; then
            REMOTE="ungeskriptet/$(basename "$PWD")"
          else
            REMOTE="$1"
          fi
          git remote add gh "gh:$REMOTE"
          git remote add cb "cb:$REMOTE"
        }
        last-journalctl () {
          journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value $1`
        }
        nix-log () {
          nix log --impure --expr "with import <nixpkgs> { }; $1"
        }
        ${lib.optionalString cfg.gitinfo.enable ''
          precmd () {
            gitinfo=$(${git} branch --show-current 2> /dev/null)
            [[ -z $gitinfo ]] && return
            [[ -z $(${git} status --porcelain 2> /dev/null) ]] && gitinfo="%F{green} ($gitinfo)%f" ||
            gitinfo="%F{yellow} ($gitinfo %B●%b)%f"
          }
        ''}
        search () {
          [ -z "$2" ] && find . -iname "*$1*" | cut -c3- || find $2 -iname "*$1*"
        }
        smartunpack () {
          COUNT=$(($(7z l -slt $1 | grep 'Path = [^/]*$' | wc -l)-1))
          if [ "$COUNT" -gt 1 ]; then
            OUT="''${1%*[.^]*}-$RANDOM"
            [ -e "$OUT" ] && echo "Already exists: $OUT" && return 1
            mkdir -p "$OUT"
            7z x $1 -o"$OUT"
            realpath "$OUT"
          else
            7z x $1
          fi
        }
        stfu () {
            $@>/dev/null 2>&1 &!
        }
        ucd () {for i in $(seq 1 $1); do cd ..; done}
        wherebin () {readlink $(which $1)}
        ${lib.optionalString config.programs.zoxide.enableZshIntegration ''
          zoxide-widget () { zi; zle reset-prompt }
          zle -N zoxide-widget
          bindkey "^G" zoxide-widget
        ''}
      '';
  };
}
