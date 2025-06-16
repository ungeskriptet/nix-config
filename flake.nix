{
  description = "David's NixOS configs";

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/develop";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    samsung-grab = {
      url = "github:ungeskriptet/samsung-grab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zmod = {
      url = "github:zarzob/Simply-Love-SM5/itgmania-release";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixos-raspberrypi, sops-nix, lanzaboote, ... }@inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
  in {
    nixosConfigurations.ryuzu = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
	vars = import ./vars.nix;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/ryuzu
        ./modules/secureboot.nix
	sops-nix.nixosModules.sops
	lanzaboote.nixosModules.lanzaboote
      ];
    };
    nixosConfigurations.xiatian = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        vars = import ./vars.nix;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/xiatian
        ./modules/secureboot.nix
        sops-nix.nixosModules.sops
        lanzaboote.nixosModules.lanzaboote
      ];
    };
    nixosConfigurations.rpi5 = nixos-raspberrypi.lib.nixosSystem {
      specialArgs = {
        inherit inputs nixos-raspberrypi;
        vars = import ./vars.nix;
      };
      system = "aarch64-linux";
      modules = [
        ./machines/rpi5
        sops-nix.nixosModules.sops
        nixos-raspberrypi.nixosModules.raspberry-pi-5.base
        nixos-raspberrypi.nixosModules.raspberry-pi-5.display-vc4
        nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
      ];
    };

    packages = nixpkgs.lib.recursiveUpdate (forAllSystems (system: {
      dumpyara = nixpkgs.legacyPackages.${system}.callPackage ./packages/dumpyara.nix { };
      mdns-scan = nixpkgs.legacyPackages.${system}.callPackage ./packages/mdns-scan.nix { };
      ttf-ms-win11 = nixpkgs.legacyPackages.${system}.callPackage ./packages/ttf-ms-win11.nix { };
      pixeldrain-cli = nixpkgs.legacyPackages.${system}.callPackage ./packages/pixeldrain-cli.nix { };
      samfirm-js = nixpkgs.legacyPackages.${system}.callPackage ./packages/samfirm-js.nix { };
      sshwifty = nixpkgs.legacyPackages.${system}.callPackage ./packages/sshwifty.nix { };
    })) {
      x86_64-linux = {
        ida-pro = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/ida-pro.nix { };
        itgmania-zmod = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/itgmania-zmod.nix {
          inherit (inputs) zmod;
        };
        odin4 = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/odin4.nix { };
        outfox-alpha5 = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/outfox-alpha5.nix { };
      };
    };
  };
}
