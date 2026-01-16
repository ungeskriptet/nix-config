{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  domain = config.networking.domain;
  papermc = pkgs.callPackage "${inputs.nixpkgs}/pkgs/games/papermc/derivation.nix" {
    version = "1.21.11-69";
    hash = "sha256-zzdPKvnXHfzHU0Pze3IqerywkcV0ExuV47E8b8LLj64=";
  };
in
{
  services.minecraft-server = {
    enable = true;
    package = papermc;
    eula = true;
    openFirewall = true;
    declarative = true;
    jvmOpts = lib.concatStringsSep " " [
      "-Xmx16G"
      "-Xms2G"
      "-Dminecraft.api.env=custom"
      "-Dminecraft.api.auth.host=https://drasl.${domain}/auth"
      "-Dminecraft.api.account.host=https://drasl.${domain}/account"
      "-Dminecraft.api.profiles.host=https://drasl.${domain}/account"
      "-Dminecraft.api.session.host=https://drasl.${domain}/session"
      "-Dminecraft.api.services.host=https://drasl.${domain}/services"
    ];
    serverProperties = {
      difficulty = "easy";
      enforce-whitelist = true;
      gamemode = "survival";
      max-players = 20;
      motd = "NixOS powered server -> https://drasl.${domain}";
      online-mode = true;
      simulation-distance = 4;
      view-distance = 10;
      white-list = true;
    };
    whitelist = {
      "Ungeskriptet" = "b993ea78-8e79-4acc-acef-46569dc5f761";
    };
  };
}
