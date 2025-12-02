{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  openssh-nix-on-droid = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.openssh-nix-on-droid;
in
{
  environment.packages = with pkgs; [
    binutils
    binwalk
    dig
    file
    git
    jq
    lz4
    ncurses
    p7zip
    python3
    ripgrep
    rsync
    sops
    unzip
    which
    zip

    openssh-nix-on-droid
  ];

  environment.etcBackupExtension = ".bak";

  user.shell = lib.getExe pkgs.zsh;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    config = lib.mkMerge [
      (import ./home)
      (import ../../home/david/common.nix)
    ];
  };

  build = {
    extraProotOptions = [ "--kill-on-exit" ];
    activationAfter.genKeys = ''
      $DRY_RUN_CMD mkdir -p /etc/ssh
      $DRY_RUN_CMD ${lib.getExe' openssh-nix-on-droid "ssh-keygen"} -A
    '';
  };

  time.timeZone = "Europe/Berlin";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";
}
