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
    ../../../home/david/standalone.nix
  ];

  programs = {
    zsh-david.nixOnDroid = {
      enable = true;
      opensshPkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.openssh-nix-on-droid;
    };
  };

  hm-config = {
    dotfiles = true;
    trusted = true;
  };

  home = {
    file = {
      ".ssh/authorized_keys".text = lib.concatStringsSep "\n" config.vars.sshPubKeys;
    };
    homeDirectory = lib.mkForce homeDir;
    sessionVariables = {
      XDG_RUNTIME_DIR = "/tmp/run";
    };
  };
}
