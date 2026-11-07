{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
}:
stdenv.mkDerivation {
  pname = "sigscan";
  version = "0-unstable-2022-03-17";

  src = fetchFromGitHub {
    owner = "luk1337";
    repo = "SigScan";
    rev = "e6fd9b31f2db3a1cb273fd418a39a8ec18490544";
    hash = "sha256-6QkkwFKmSzeo4wCfi3Vm/cKvEej/9OK8OAI/J6H9Y7s=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "set(Boost_USE_STATIC_LIBS ON)" "" \
      --replace-fail "if (NOT APPLE)" "if (0)"
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    boost
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp SigScan $out/bin/sigscan

    runHook postInstall
  '';

  meta = {
    description = "Basic binary signature scanner";
    homepage = "https://github.com/luk1337/SigScan";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ungeskriptet ];
    mainProgram = "sigscan";
  };
}
