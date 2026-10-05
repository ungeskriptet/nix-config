{ inputs }:
let
  lib = inputs.nixpkgs.lib;
  defaultSystems = [
    "aarch64-linux"
    "x86_64-linux"
  ];
in
{
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
    hosts:
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
              ./modules/module-list.nix
              {
                nixpkgs.hostPlatform = system;
                networking.hostName = host;
              }
            ];
          };
        }
      ) hosts
    );
  autoArgs =
    fn: autoArgs:
    let
      f = if builtins.isFunction fn then fn else import fn;
      fargs = builtins.functionArgs f;
      allArgs = builtins.intersectAttrs fargs autoArgs;
    in
    f allArgs;
}
