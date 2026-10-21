{ lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      paperless-ngx = prev.paperless-ngx.overrideAttrs {
        # Checks take a long time
        doCheck = false;
        doInstallCheck = false;
      };
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (
          pyFinal: pyPrev:
          lib.genAttrs
            [
              "llama-index-embeddings-huggingface"
              "ocrmypdf"
              "plotly"
              "spacy"
              "sweeps"
              "torchaudio"
              "wandb"
            ]
            (
              pkg:
              pyPrev.${pkg}.overrideAttrs {
                doCheck = false;
                doInstallCheck = false;
              }
            )
        )
      ];
    })
  ];
}
