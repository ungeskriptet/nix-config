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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
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
    phonetrack-notify = {
      url = "git+https://codeberg.org/ungeskriptet/phonetrack-notify.git";
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
      nixos-raspberrypi,
      ...
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      nixosConfigurations.ryuzu = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        system = "x86_64-linux";
        modules = [
          ./machines/ryuzu
        ];
      };
      nixosConfigurations.xiatian = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        system = "x86_64-linux";
        modules = [
          ./machines/xiatian
        ];
      };
      nixosConfigurations.daruma = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        system = "x86_64-linux";
        modules = [
          ./machines/daruma
        ];
      };
      nixosConfigurations.rpi5 =
        nixos-raspberrypi.lib.int.nixosSystemRPi
          {
            nixpkgs =
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
                    (pkgs.fetchpatch {
                      url = "https://github.com/NixOS/nixpkgs/pull/437851.patch";
                      hash = "sha256-ty4vBfTHyu+PL4jjSKwNX52bdjrIGzDv7dceh5X5RyY=";
                    })
                  ];
                };
                rpipkgs = (import "${pkgsPatched}/flake.nix").outputs { self = inputs.self; };
              in
              rpipkgs;
            rpiModules = import ./modules/rpimodules.nix { inherit nixos-raspberrypi; };
          }
          {
            specialArgs = {
              inherit inputs nixos-raspberrypi;
            };
            system = "aarch64-linux";
            modules = [
              ./machines/rpi5
            ];
          };

      packages =
        nixpkgs.lib.recursiveUpdate
          (forAllSystems (system: {
            mdns-scan = nixpkgs.legacyPackages.${system}.callPackage ./packages/mdns-scan.nix { };
            pixeldrain-cli = nixpkgs.legacyPackages.${system}.callPackage ./packages/pixeldrain-cli.nix { };
            pmbootstrap-git = nixpkgs.legacyPackages.${system}.callPackage ./packages/pmbootstrap-git.nix {
              inherit (inputs) pmbootstrap-git;
            };
            ttf-ms-win11 = nixpkgs.legacyPackages.${system}.callPackage ./packages/ttf-ms-win11.nix { };
          }))
          {
            x86_64-linux = {
              ida-pro = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/ida-pro.nix { };
              itgmania-zmod = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/itgmania-zmod.nix {
                inherit (inputs) zmod;
              };
              odin4 = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/odin4.nix { };
              outfox-alpha5 = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/outfox-alpha5.nix { };
            };
          };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
