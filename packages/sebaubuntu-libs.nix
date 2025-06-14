{
  python3Packages,
  fetchFromGitHub,
}:

with python3Packages;

buildPythonPackage rec {
  pname = "sebaubuntu_libs";
  version = "1.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sebaubuntu-python";
    repo = pname;
    rev = "1e3d3da935654755932b34715dc693e024cd3e22";
    hash = "sha256-TBRHRfbWdhl2OB2AwuGVTd/QJao4qeb90pQC1B4ZYJI=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    gitpython
    pyelftools
    requests
  ];
}
