{ config, ... }:
let
  cfg = config.programs.zsh-david;
in
{
  imports = [
    ../common.nix
  ];
  environment.sessionVariables.ZDOTDIR = "$HOME/.config/zsh";
  programs.zsh = {
    setOptions = [ "HIST_IGNORE_ALL_DUPS" ];
    histSize = cfg.histSize;
    histFile = "$HOME/.cache/zsh/zsh_history";
    interactiveShellInit = cfg.zshrc;
    promptInit = cfg.prompt;
    autosuggestions.enable = true;
  };
}
