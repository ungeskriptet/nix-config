{
  lib,
  runCommand,
  python3Packages,
  fetchFromGitHub,
  callPackage,
  nix-update-script,
  _7zz,
  android-tools,
  cpio,
  erofs-utils,
  squashfsTools,
  zip,
}:
python3Packages.buildPythonApplication {
  pname = "dumpyara";
  # unstable because latest release depends on old python libraries which no longer exist in nixpkgs
  version = "1.0.10-unstable-2025-11-06";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sebaubuntu-python";
    repo = "dumpyara";
    rev = "8d75d1ceb01fcfb03384f0cb459267c8e6dea787";
    hash = "sha256-bQMqgFbnU5c6QpIKeSl5tfQ6tzLLRBONBAliGlQK6LI=";
  };

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    brotli
    liblp
    lz4
    protobuf5
    py7zr
    zstandard
    (callPackage ./sebaubuntu-libs.nix { })
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      _7zz
      android-tools
      cpio
      erofs-utils
    ])
  ];

  passthru = {
    tests.requiredTools =
      runCommand "check-required-tools"
        {
          nativeBuildInputs = [
            android-tools
            squashfsTools
            zip
            (callPackage ./dumpyara.nix { })
          ];
        }
        ''
          echo foo > bar.txt
          mkbootimg --kernel bar.txt -o boot.img
          mksquashfs bar.txt system.img
          zip system.zip *.img
          dumpyara system.zip
          touch $out
        '';
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Android firmware dumper, rewritten in Python";
    homepage = "https://github.com/sebaubuntu-python/dumpyara";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ungeskriptet ];
    mainProgram = "dumpyara";
  };
}
