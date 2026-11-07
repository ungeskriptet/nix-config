{
  description = "David's NixOS configs";
  nixConfig = {
    extra-substituters = [
      "https://cache.thalheim.io"
      "https://nix-community.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
      "https://nixpkgs-update-cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "nixpkgs-update-cache.nix-community.org-1:U8d6wiQecHUPJFSqHN9GSSmNkmdiFW7GW7WNAnHW0SM="
    ];
  };
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    itgpacks.url = "https://codeberg.org/ungeskriptet/itg-songpacks-flake/archive/master.tar.gz";
    lanzaboote.url = "github:nix-community/lanzaboote";
    nixos-raspberrypi-kernel.url = "github:nvmd/nixos-raspberrypi/develop";
    "573-nix" = {
      url = "https://codeberg.org/ungeskriptet/573-nix/archive/master.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-shell-collection = {
      url = "https://codeberg.org/ungeskriptet/nix-shell-collection/archive/master.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-raspberrypi = {
      url = "github:ungeskriptet/nixos-raspberrypi/treefmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yuribot = {
      url = "https://codeberg.org/ungeskriptet/yuribot/archive/master.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      nix-on-droid,
      nixos-raspberrypi,
      ...
    }@inputs:
    let
      lib = import ./lib.nix { inherit inputs; };
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
      treefmtEval = forAllSystems (
        system:
        inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} (
          { ... }:
          {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              black.enable = true;
              keep-sorted.enable = true;
              rustfmt.enable = true;
              nixf-diagnose = {
                enable = true;
                autoFix = false;
              };
            };
            settings = {
              verbose = 1;
              on-matched = "debug";
            };
          }
        )
      );
    in
    {
      inherit lib;
      nixosModules.default = ./modules/module-list.nix;
      nixosConfigurations = {
        rpi5 = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = { inherit inputs nixos-raspberrypi; };
          modules = [
            ./machines/rpi5
            ./modules/module-list.nix
            inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
            inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
          ];
        };
      }
      // lib.mkNixos [
        { host = "celica"; }
        { host = "iroha"; }
        { host = "misaka"; }
        { host = "rimuru"; }
        { host = "ryuzu"; }
        { host = "tsugaru"; }
        { host = "xiatian"; }
        {
          host = "satone";
          system = "aarch64-linux";
        }
      ];
      nixOnDroidConfigurations.nix-on-droid = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./machines/nix-on-droid ];
      };
      homeConfigurations = lib.mkHomeConfigurations "david" {
        modules = [ ./home/david/standalone.nix ];
      };
      packages =
        let
          pkgs = nixpkgs.legacyPackages;
        in
        nixpkgs.lib.recursiveUpdate
          (forAllSystems (system: {
            # keep-sorted start block=yes
            bitwarden-show-hide = pkgs.${system}.callPackage ./pkgs/bitwarden-show-hide { };
            firefox-focus-windows = pkgs.${system}.callPackage ./pkgs/firefox-focus-windows { };
            firefox-patched = lib.autoArgs ./pkgs/firefox-patched pkgs.${system};
            fritzbox-cert-importer = pkgs.${system}.callPackage ./pkgs/fritzbox-cert-importer { };
            fritzbox-dyndns-interceptor = pkgs.${system}.callPackage ./pkgs/fritzbox-dyndns-interceptor { };
            get-execstart = pkgs.${system}.callPackage ./pkgs/get-execstart { };
            kate = pkgs.${system}.callPackage ./pkgs/kate { };
            magisk-install = pkgs.${system}.callPackage ./pkgs/magisk-install { };
            nix-on-droid-setup = pkgs.${system}.callPackage ./pkgs/nix-on-droid-setup { };
            openssh-nix-on-droid = pkgs.${system}.callPackage ./pkgs/openssh-nix-on-droid { };
            rg-uuid = pkgs.${system}.callPackage ./pkgs/rg-uuid { };
            servfail-update = pkgs.${system}.callPackage ./pkgs/servfail-update { };
            sigscan = pkgs.${system}.callPackage ./pkgs/sigscan { };
            sops-edit = pkgs.${system}.callPackage ./pkgs/sops-edit { };
            telegram-show-hide = pkgs.${system}.callPackage ./pkgs/telegram-show-hide { };
            ttf-ms-win11 = pkgs.${system}.callPackage ./pkgs/ttf-ms-win11 { };
            # keep-sorted end
          }))
          {
            x86_64-linux = {
              odin4 = pkgs.x86_64-linux.callPackage ./pkgs/odin4 { };
            };
          };
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check inputs.self;
      });
    };
}
