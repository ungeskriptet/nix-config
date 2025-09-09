{ lib, pkgs }:
{
  default = "ddg";
  engines = lib.mergeAttrsList (
    lib.map (file: import (./. + "/${file}") { inherit pkgs; }) (
      lib.attrNames (
        lib.filterAttrs (
          file: type: file != "default.nix" && type == "regular" && lib.hasSuffix ".nix" file
        ) (builtins.readDir ./.)
      )
    )
  );
}
