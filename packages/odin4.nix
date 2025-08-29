{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  unzip,
}:
stdenv.mkDerivation rec {
  pname = "odin4";
  version = "1.2.1.dc05e3ea0";

  src = fetchurl {
    url = "https://web.archive.org/web/20230225072710if_/https://forum.xda-developers.com/attachments/odin-zip.5629297/";
    hash = "sha256-2RjxMrCy7ly+7yf7Yfau7jc0zbICstyOOEWpVTAwAsU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  unpackCmd = "unzip -o -d odin4 $curSrc";

  installPhase = ''
    runHook preInstall
    install -Dm555 -t $out/bin $pname
    runHook postInstall
  '';

  meta = {
    description = "Odin4 Samsung firmware flasher";
    mainprogram = pname;
  };
}
