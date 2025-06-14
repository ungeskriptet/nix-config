{
  python3Packages,
  fetchPypi,
}:

with python3Packages;

buildPythonPackage rec {
  pname = "liblp";
  version = "1.0.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XlIvX7Q4d2Sg79Ii/9xyHSH4WvWrZKPvtY7IEJ0oCkU=";
  };

  build-system = [
    poetry-core
  ];
}
