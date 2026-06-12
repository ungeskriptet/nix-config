{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyFinal: pyPrev: {
          uefi-firmware-parser = pyPrev.uefi-firmware-parser.overrideAttrs {
            buildInputs = with pkgs.python3Packages; [ setuptools-scm ];
          };
        })
      ];
    })
  ];
}
