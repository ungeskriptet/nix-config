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
        [ -n "$SSH_TTY" ] && SSH="%F{cyan} [SSH]%f" || SSH=""
        PROMPT="╭─%F''${COLOR}${
          if cfg.nixOnDroid.enable then "nix-on-droid" else "%n@%m"
        }%f %F{blue}%~%f''${SSH}${lib.optionalString cfg.gitinfo.enable "\\$gitinfo"}
        ╰─ "
      '';
    };
    zshrc = lib.mkOption {
      type = lib.types.lines;
      description = ".zshrc content";
    };
  };
}
