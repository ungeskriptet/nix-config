{ lib, ... }:
{
  imports = lib.map (file: ./. + "/${file}") (
    lib.attrNames (
      lib.filterAttrs (
        file: type: file != "default.nix" && type == "regular" && lib.hasSuffix ".nix" file
      ) (builtins.readDir ./.)
    )
  );
}
