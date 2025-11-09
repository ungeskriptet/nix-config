{
  lib,
  python3Packages,
  fetchFromGitHub,
  callPackage,
}:
python3Packages.buildPythonPackage rec {
  pname = "sebaubuntu-libs";
  version = "1.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sebaubuntu-python";
    repo = "sebaubuntu_libs";
    tag = "v${version}";
    hash = "sha256-V+9z4Q4D40AfVgSXW05EfZhctA+EIuS8xGSQkBjNGTQ=";
  };

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    gitpython
    pyelftools
    requests
  ];

  patchPhase = ''
    # Patch libaik to use AIK from nixpkgs
    substituteInPlace sebaubuntu_libs/libaik/__init__.py \
      --replace-fail \
        "Repo.clone_from(AIK_REPO, self.path)" \
        "check_output(f'ln -s ${callPackage ./android-image-kitchen.nix { }}/* {self.path}', \
          shell=True, stderr=STDOUT)" \
      --replace-fail \
        'command = [self.path / script, "--nosudo", *args]' \
        'command = [self.path / script, "--local", "--nosudo", *args]' \
      --replace-fail \
        'return check_output(command, stderr=STDOUT, universal_newlines=True, encoding="utf-8")' \
        'return check_output(command, stderr=STDOUT, universal_newlines=True, encoding="utf-8", \
          cwd=self.path)'
  '';

  # Module has no tests
  doCheck = false;

  pythonImportsCheck = [ "sebaubuntu_libs" ];

  meta = {
    description = "SebaUbuntu's shared libs";
    homepage = "https://github.com/sebaubuntu-python/sebaubuntu_libs";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ ungeskriptet ];
  };
}
