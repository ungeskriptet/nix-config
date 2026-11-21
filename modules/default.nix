{ lib, ... }:
{
  imports = lib.filter (x: x != null) (
    lib.mapAttrsToList (
      file: type:
      if (type == "directory" || lib.hasSuffix ".nix" file && file != "default.nix") then
        let
          dir = builtins.readDir (./. + "/${file}");
        in
        if (type == "directory" && dir ? "nixos.nix") then
          ./. + "/${file}/nixos.nix"
        else if (type == "directory" && dir ? "nixos") then
          ./. + "/${file}/nixos"
        else
          ./. + "/${file}"
      else if (file == "default.nix") then
        null
      else
        abort "Unknown module: ${file}"
    ) (builtins.readDir ./.)
  );
}
