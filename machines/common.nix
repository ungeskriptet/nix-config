{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../modules/packages-common.nix
    ../modules/users.nix
    ../modules/vars.nix
    ../modules/virtualization.nix
    ../modules/zsh/nixos
    inputs.home-manager.nixosModules.home-manager
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
  ];

  sops.age.keyFile = lib.mkDefault "/var/lib/sops-nix/key.txt";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hmbak";
  }
  // lib.optionalAttrs (config.users.userName == "david") {
    users.david = lib.mkDefault ../home/david/common.nix;
  };

  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = false;
    "kernel.sysrq" = true;
  };
  boot.tmp.cleanOnBoot = true;

  security.rtkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        action.id == "org.freedesktop.udisks2.encrypted-unlock-system" &&
        subject.isInGroup("wheel")
      ) { return polkit.Result.YES; }
    });
  '';

  networking.domain = "david-w.eu";
  networking.nftables.enable = true;
  networking.firewall.filterForward = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
  };

  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    PATH = [ "$HOME/.local/bin" ];
  };

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";
  services.xserver.xkb.layout = "de";
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = lib.mkDefault (
      lib.genAttrs [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_NAME"
        "LC_MEASUREMENT"
        "LC_NUMERIC"
        "LC_MONETARY"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"
      ] (var: "de_DE.UTF-8")
    );
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
    gc.automatic = true;
    gc.dates = "weekly";
    gc.options = "--delete-older-than 7d";
  };
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";
}
