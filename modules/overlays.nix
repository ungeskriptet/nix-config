{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyFinal: pyPrev: {
          ocrmypdf = pyPrev.ocrmypdf.overrideAttrs {
            # Checks take a long time
            doCheck = false;
            doInstallCheck = false;
          };
        })
      ];
    })
  ];
}
