{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      paperless-ngx = prev.paperless-ngx.overrideAttrs {
        # Checks take a long time
        doCheck = false;
        doInstallCheck = false;
      };
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
