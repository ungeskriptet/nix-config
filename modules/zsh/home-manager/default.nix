{ lib, config, ... }:
let
  cfg = config.programs.zsh-david;
in
{
  imports = [
    ../common.nix
  ];
  programs.zsh = {
    initContent = cfg.zshrc;
    profileExtra = lib.mkIf cfg.nixOnDroid.enable ''
      eval $(ssh-agent -s)
      ${lib.last config.systemd.user.services.sops-nix.Service.ExecStart}
    '';
    history = {
      append = true;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      save = cfg.histSize;
      saveNoDups = true;
      share = false;
      size = cfg.histSize;
    };
    autosuggestion.enable = true;
  };
}
