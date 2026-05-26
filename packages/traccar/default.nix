{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchNpmDeps,
  makeWrapper,
  npmHooks,
  gradle,
  jdk_headless,
  jre_minimal,
  nodejs,
  protobuf,
}:
let
  jre = jre_minimal.override {
    jdk = jdk_headless;
    modules = [
      "java.desktop"
      "java.logging"
      "java.management"
      "java.naming"
      "java.sql"
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "traccar";
  version = "6.13.3";

  src = fetchFromGitHub {
    owner = "traccar";
    repo = "traccar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oRAO4dbN/HRWcfsC0QnHA4+R3TFZLrZgk3G7E63sXHg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    makeWrapper
    npmHooks.npmConfigHook
    gradle
    nodejs
  ];

  patches = [ ./use-protobuf-from-nixpkgs.patch ];

  postPatch = ''
    substituteAllInPlace build.gradle
  '';

  env.protocPath = lib.getExe' protobuf "protoc";

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  npmRoot = "traccar-web";

  npmDeps = fetchNpmDeps {
    src = "${finalAttrs.src}/traccar-web";
    hash = "sha256-zqOCfS7ANwkumXIrR6Gj0sVeyfyhg9V/MhauP6zoPQQ=";
  };

  preBuild = ''
    pushd traccar-web
    npm run build
    popd
  '';

  gradleBuildTask = "build";

  doCheck = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r {schema,target/*,templates} $out
    cp -r traccar-web/build $out/web
    cp -r traccar-web/src/resources/l10n $out/templates/translations
    makeWrapper ${lib.getExe jre} $out/bin/traccar \
      --add-flags "-jar $out/tracker-server.jar"
    runHook postInstall
  '';

  meta = {
    description = "Open source GPS tracking system";
    homepage = "https://www.traccar.org/";
    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      fromSource
    ];
    license = lib.licenses.asl20;
    mainProgram = "traccar";
    maintainers = with lib.maintainers; [
      frederictobiasc
      ungeskriptet
    ];
  };
})
