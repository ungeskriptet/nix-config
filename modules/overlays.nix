{ lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      paperless-ngx = prev.paperless-ngx.overrideAttrs {
        # Checks take a long time
        doCheck = false;
        doInstallCheck = false;
        pythonRelaxDeps =
          if (builtins.any (x: x == "torch") prev.paperless-ngx.pythonRelaxDeps) then
            throw "paperless-ngx: 'torch' already relaxed"
          else
            prev.paperless-ngx.pythonRelaxDeps ++ [ "torch" ];
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
