{
  stdenv,
  fetchurl,
  p7zip
}:

stdenv.mkDerivation rec {
  name = "ttf-ms-win11";

  src = fetchurl {
    url = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso";
    sha256 = "sha256-dVqQ1D6CanS54ZMqNHiLiY4CgnJDm3d+VZPe6NU2Iq4=";
  };

  nativeBuildInputs = [ p7zip ];

  sourceRoot = ".";

  dontUnpack = true;

  installPhase = ''
    7z x ${src} sources/install.wim
    7z e sources/install.wim Windows/{Fonts/"*".{ttf,ttc},System32/Licenses/neutral/"*"/"*"/license.rtf} -ofonts

    install -Dm444 fonts/*.{ttf,ttc} -t "$out/share/fonts/TTF"
    install -Dm444 fonts/license.rtf -t "$out/share/licenses/${name}"

    rm -rf sources
    rm -rf fonts
  '';

  meta = {
    description = "Microsoft Windows 11 fonts";
    homepage = "https://www.microsoft.com/typography/fonts/product.aspx?PID=164";
  };
}
