{
  itgmania,
  lib,
  zmod,
}:

itgmania.overrideAttrs (old: {
  pname = "itgmania-zmod";
  buildCommand = ''
    set -euo pipefail

    ${lib.concatStringsSep "\n"
      (map
        (outputName: ''
            cp -rs --no-preserve=mode "${itgmania.${outputName}}" "''$${outputName}"
        '') [ "out" ]
      )
    }
    rm $out/bin/itgmania
    makeWrapper $out/itgmania/itgmania $out/bin/itgmania \
      --chdir $out/itgmania
    cp -r ${zmod} $out/itgmania/Themes/zmod-nixpkgs
  '';
})
