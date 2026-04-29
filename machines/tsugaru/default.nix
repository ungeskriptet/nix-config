# Acer Aspire V3-771
{
  inputs,
  pkgs,
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
    defaultSopsFile = "${inputs.self}/secrets/secrets-tsugaru.yaml";
  };

  networking = {
    hostName = "tsugaru";
    firewall.allowedTCPPorts = [ 3389 ];
  };

  environment = {
    systemPackages = with pkgs; [
      prismlauncher
    ];
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
    defaultLocale = lib.mkForce "pl_PL.UTF-8";
    extraLocaleSettings = lib.mkForce (
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
      ] (var: "pl_PL.UTF-8")
    );
  };

  users = {
    hashedPassword = "$y$j9T$zVs7BkMuIfSOpUDWx5WYS/$8Mqb4/741mi/cpECCoIN883LNL6zs6eiGt/N9o5wydA";
    userName = "kamil";
    userDescription = "Kamil";
  };

  home-manager.users.kamil =
    { ... }:
    {
      imports = [ ../../home/kamil.nix ];
      gnome.monitorID = "CMO-0x00000000";
    };
}
