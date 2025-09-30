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
    { nixpkgs, nixos-raspberrypi, ... }@inputs:
    let
      lib = import ./lib.nix { inherit nixpkgs; };
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
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
      // lib.mkNixos [ "daruma" "ryuzu" "xiatian" ] inputs;
      packages =
        let
          pkgs = nixpkgs.legacyPackages;
        in
        nixpkgs.lib.recursiveUpdate
          (forAllSystems (system: {
            mdns-scan = pkgs.${system}.callPackage ./packages/mdns-scan.nix { };
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
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
