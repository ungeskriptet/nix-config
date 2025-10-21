{
  lib,
  pkgs,
  inputs,
  ...
}:
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

    inputs.self.packages.${pkgs.system}.openssh-nix-on-droid
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

  time.timeZone = "Europe/Berlin";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";
}
