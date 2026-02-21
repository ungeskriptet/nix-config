{
  description = "David's NixOS configs";
  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
  inputs = {
    nixos-raspberrypi-kernel.url = "github:nvmd/nixos-raspberrypi/develop";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    gnome.url = "github:ungeskriptet/nixpkgs/gnome-extension";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-shell-collection = {
      url = "git+https://codeberg.org/ungeskriptet/nix-shell-collection.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    samsung-grab = {
      url = "git+https://codeberg.org/ungeskriptet/samsung-grab";
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "git+https://codeberg.org/ungeskriptet/yuribot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zmod = {
      url = "github:zarzob/Simply-Love-SM5/itgmania-release";
      flake = false;
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
      lib = import ./lib.nix { inherit nixpkgs; };
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
      treefmtEval = forAllSystems (
        system:
        inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} (
          { pkgs, ... }:
          {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              keep-sorted.enable = true;
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
      nixosConfigurations = {
        rpi5 =
          let
            pkgs = import nixpkgs { system = "aarch64-linux"; };
            pkgsPatched = pkgs.applyPatches {
              name = "rpipkgs";
              src = nixpkgs;
              patches = [
                (pkgs.fetchpatch {
                  url = "https://github.com/NixOS/nixpkgs/pull/398456.patch";
                  hash = "sha256-N4gry4cH0UqumhTmOH6jyHNWpvW11eRDlGsnj5uSi+0=";
                })
              ];
            };
            rpipkgs = (import "${pkgsPatched}/flake.nix").outputs { self = inputs.self; };
          in
          nixos-raspberrypi.lib.int.nixosSystemRPi
            {
              nixpkgs = rpipkgs;
              rpiModules = import ./modules/rpimodules.nix { inherit nixos-raspberrypi; };
            }
            {
              specialArgs = { inherit inputs nixos-raspberrypi; };
              system = "aarch64-linux";
              modules = [ ./machines/rpi5 ];
            };
      }
      // lib.mkNixos [ "daruma" "misaka" "rimuru" "ryuzu" "tsugaru" "xiatian" ] inputs;
      nixOnDroidConfigurations.nix-on-droid = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./machines/nix-on-droid ];
      };
      packages =
        let
          pkgs = nixpkgs.legacyPackages;
          pkgsUnfree =
            system:
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
        in
        nixpkgs.lib.recursiveUpdate
          (forAllSystems (system: {
            drasl = pkgs.${system}.callPackage ./packages/drasl.nix { };
            dumpyara = pkgs.${system}.callPackage ./packages/dumpyara.nix { };
            mdns-scan = pkgs.${system}.callPackage ./packages/mdns-scan.nix { };
            nix-on-droid-setup = pkgs.${system}.callPackage ./packages/nix-on-droid-setup.nix { };
            openssh-nix-on-droid = pkgs.${system}.callPackage ./packages/openssh-nix-on-droid.nix { };
            silverfort-client = (pkgsUnfree system).callPackage ./packages/silverfort-client { };
            ttf-ms-win11 = pkgs.${system}.callPackage ./packages/ttf-ms-win11.nix { };
          }))
          {
            x86_64-linux = {
              itgmania-zmod = pkgs.x86_64-linux.callPackage ./packages/itgmania-zmod.nix {
                inherit (inputs) zmod;
              };
              odin4 = pkgs.x86_64-linux.callPackage ./packages/odin4.nix { };
              outfox-alpha5 = pkgs.x86_64-linux.callPackage ./packages/outfox-alpha5.nix { };
            };
          };
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check inputs.self;
      });
    };
}
