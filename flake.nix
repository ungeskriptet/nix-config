{
  description = "David's NixOS configs";
  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:ungeskriptet/home-manager/ssh-strictHostKeyChecking";
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
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pmbootstrap-git = {
      url = "git+https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git";
      flake = false;
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
              specialArgs = { inherit inputs nixos-raspberrypi pkgsPatched; };
              system = "aarch64-linux";
              modules = [ ./machines/rpi5 ];
            };
      }
      // lib.mkNixos [ "daruma" "ryuzu" "tsugaru" "xiatian" ] inputs;
      nixOnDroidConfigurations.nix-on-droid = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./machines/nix-on-droid ];
      };
      packages =
        let
          pkgs = nixpkgs.legacyPackages;
        in
        nixpkgs.lib.recursiveUpdate
          (forAllSystems (system: {
            dumpyara = pkgs.${system}.callPackage ./packages/dumpyara.nix { };
            mdns-scan = pkgs.${system}.callPackage ./packages/mdns-scan.nix { };
            openssh-nix-on-droid = pkgs.${system}.callPackage ./packages/openssh-nix-on-droid.nix { };
            pmbootstrap-git = pkgs.${system}.callPackage ./packages/pmbootstrap-git.nix {
              inherit (inputs) pmbootstrap-git;
            };
            ttf-ms-win11 = pkgs.${system}.callPackage ./packages/ttf-ms-win11.nix { };
          }))
          {
            x86_64-linux = {
              ida-pro = pkgs.x86_64-linux.callPackage ./packages/ida-pro.nix { };
              itgmania-zmod = pkgs.x86_64-linux.callPackage ./packages/itgmania-zmod.nix {
                inherit (inputs) zmod;
              };
              odin4 = pkgs.x86_64-linux.callPackage ./packages/odin4.nix { };
              outfox-alpha5 = pkgs.x86_64-linux.callPackage ./packages/outfox-alpha5.nix { };
              silverfort-client = pkgs.x86_64-linux.callPackage ./packages/silverfort-client.nix { };
            };
          };
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check inputs.self;
      });
    };
}
