{ nixpkgs }:
{
  mkNixos =
    hosts: inputs:
    nixpkgs.lib.mergeAttrsList (
      map (
        {
          host,
          system ? "x86_64-linux",
        }:
        {
          ${host} = nixpkgs.lib.nixosSystem {
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
