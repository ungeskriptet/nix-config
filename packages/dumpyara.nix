{
  python3Packages,
  fetchFromGitHub,
  callPackage,
  makeWrapper,
  lib,
  erofs-utils,
  buildFHSEnv,
}:

with python3Packages;

let
  version = "1.0.10";

  dumpyara = buildPythonApplication rec {
    pname = "dumpyara-unwrapped";
    inherit version;
    pyproject = true;

    src = fetchFromGitHub {
      owner = "sebaubuntu-python";
      repo = "dumpyara";
      rev = "4ad627639c98df304169ed1edd4cd1c5b0c7ad5f";
      hash = "sha256-4EYugh0NL6MaUXu0wDz1J0czKSujUqEsDXYxqQeSYuI=";
    };

    build-system = [
      poetry-core
    ];

    dependencies = [
      brotli
      lz4
      protobuf5
      py7zr
      zstandard

      (callPackage ./liblp.nix { })
      (callPackage ./sebaubuntu-libs.nix { })
    ];

    nativeBuildInputs = [ makeWrapper ];

    postFixup = ''
      wrapProgram $out/bin/dumpyara \
        --prefix PATH : "${lib.makeBinPath [ erofs-utils ]}"
    '';
  };
in
buildFHSEnv rec {
  pname = "dumpyara";
  inherit version;

  runScript = "${dumpyara}/bin/dumpyara";
}
