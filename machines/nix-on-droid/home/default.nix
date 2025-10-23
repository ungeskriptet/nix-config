{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  homeDir = "/data/data/com.termux.nix/files/home";
in
{
  imports = [
    ../../../home/david/vars.nix
    ../../../modules/zsh/home-manager
    inputs.sops-nix.homeManagerModules.sops
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
    zsh-david = {
      nixOnDroid = {
        enable = true;
        opensshPkg = inputs.self.packages.${pkgs.system}.openssh-nix-on-droid;
      };
      david.enable = config.hm-config.david;
      homeManager.enable = true;
    };
  };

  home = {
    homeDirectory = lib.mkForce homeDir;
    sessionVariables = {
      XDG_RUNTIME_DIR = "/tmp/run";
    };
  };
}
