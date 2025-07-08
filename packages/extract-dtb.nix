{
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonApplication rec {
  pname = "extract-dtb";
  version = "1.2.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-g8Dadd0YwE5c/z6Bh/hIGtHsbmoGsgvAQjE/Hfl2+ag=";
  };

  build-system = with python3Packages; [
    setuptools
  ];
}
