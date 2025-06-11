{ lib, ... }:

{
  imports = [
    ../modules/packages-common.nix
    ../modules/users.nix
    ../modules/virtualization.nix
    ../modules/zsh.nix
  ];

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  boot.kernel.sysctl."kernel.dmesg_restrict" = false;
  boot.tmp.cleanOnBoot = true;

  security.rtkit.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  environment.sessionVariables = {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    PATH = [ "$HOME/.local/bin" ];
  };

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";
  services.xserver.xkb.layout = "de";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = lib.genAttrs [
      "LC_ADDRESS" "LC_IDENTIFICATION"
      "LC_NAME"    "LC_MEASUREMENT"
      "LC_NUMERIC" "LC_MONETARY"
      "LC_PAPER"   "LC_TELEPHONE"
      "LC_TIME"
    ] (var: "de_DE.UTF-8");
  };

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc.automatic = true;
    gc.dates = "weekly";
    gc.options = "--delete-older-than 7d";
  };
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";
}
