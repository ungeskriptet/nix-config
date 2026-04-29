{
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./wireguard.nix
    ../desktop.nix
  ];

  sops = {
    age.keyFile = lib.mkForce null;
    defaultSopsFile = "${inputs.self}/secrets/secrets-rimuru.yaml";
  };

  networking = {
    hostName = "rimuru";
    firewall.allowedTCPPorts = [ 3389 ];
    interfaces.enp2s0f1.wakeOnLan.enable = true;
  };

  nix-config = {
    gnome.enable = true;
    secureboot.enable = true;
    hardware = {
      enable = true;
      platform = "intel";
    };
  };

  i18n = {
    defaultLocale = lib.mkForce "de_DE.UTF-8";
    extraLocaleSettings = lib.mkForce { };
  };

  users = {
    hashedPassword = "$y$j9T$9EZBwL3aSCu0rlAFngWtP1$R.F4i3PyIRg0sA9PqTYkxSms6TmQ.nQ3qhoHWGn/KY2";
    userDescription = "Grazyna";
    userName = "grazyna";
  };

  home-manager.users.grazyna =
    { ... }:
    {
      imports = [ ../../home/grazyna.nix ];
      gnome.monitorID = "CMN-0x00000000";
    };
}
