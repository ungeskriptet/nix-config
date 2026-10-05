{
  config,
  inputs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./modules/firefox
    ./modules/thunderbird
  ];

  programs = {
    home-manager.enable = true;
  };

  sops = {
    defaultSopsFile = "${inputs.self}/secrets/user-${config.home.username}.yaml";
    age = {
      keyFile = "${homeDir}/.config/sops-nix/key.txt";
      generateKey = true;
    };
  };

  home = {
    stateVersion = "26.05";
  };
}
