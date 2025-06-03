{
  description = "David's NixOS configs";

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
    connect-timeout = 5;
  };

  inputs = {
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/develop";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixos-raspberrypi, nixpkgs, sops-nix, ... }@inputs: {
    nixosConfigurations.rpi5 = nixos-raspberrypi.lib.nixosSystem {
      specialArgs = { inherit inputs nixos-raspberrypi; };
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        sops-nix.nixosModules.sops
        nixos-raspberrypi.nixosModules.raspberry-pi-5.base
        nixos-raspberrypi.nixosModules.raspberry-pi-5.display-vc4
        nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
      ];
    };
  };
}
