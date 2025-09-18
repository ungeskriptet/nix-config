{ nixpkgs }:
{
  mkNixos =
    hosts: inputs:
    nixpkgs.lib.mergeAttrsList (
      builtins.map (host: {
        ${host} = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          system = "x86_64-linux";
          modules = [
            ./machines/${host}
          ];
        };
      }) hosts
    );
}
