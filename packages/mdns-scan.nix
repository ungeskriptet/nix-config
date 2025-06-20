{
  stdenv,
  fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "mdns-scan";
  version = "2020-07-15";

  src = fetchFromGitHub {
    owner = "alteholz";
    repo = pname;
    rev = "9c307d81d82812e423664e4ebe135f429d995ac8";
    hash = "sha256-+rbxmzHlKZVH+VDxNqzhKzPOlOZMju+KEoRVGzbXNjg=";
  };

  installPhase = "install -Dm555 -t $out/bin $pname";

  meta = {
    description = "mDNS scanner";
    homepage = "https://github.com/alteholz/mdns-scan";
    mainprogram = pname;
  };
}
