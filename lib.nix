{ inputs }:
let
  lib = inputs.nixpkgs.lib;
in
rec {
  defaultSystems = [
    "aarch64-linux"
    "x86_64-linux"
  ];
  forAllSystems = lib.genAttrs defaultSystems;
  mkHomeConfigurations =
    user: attrs:
    lib.mergeAttrsList (
      map (system: {
        "${system}-${user}" = inputs.home-manager.lib.homeManagerConfiguration (
          attrs
          // {
            extraSpecialArgs = { inherit inputs; };
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
        );
      }) defaultSystems
    );
  mkNixos =
    hosts: inputs:
    lib.mergeAttrsList (
      map (
        {
          host,
          system ? "x86_64-linux",
        }:
        {
          ${host} = lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs; };
            modules = [
              ./machines/${host}
            ];
          };
        }
      ) hosts
    );
}
