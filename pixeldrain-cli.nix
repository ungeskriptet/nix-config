{ config, lib, pkgs, ... }:

let
  pixeldrainCli = pkgs.stdenv.mkDerivation {
    name = "pixeldrain-cli";
    src = pkgs.writeText "pixeldrain-cli" ''
      #!${lib.getExe pkgs.bash}
      APIKEY=$(cat ${config.sops.secrets."pixeldrain/apikey".path})
      ${lib.getExe pkgs.curl} \
        -T "$1" -u :$APIKEY \
        https://pixeldrain.com/api/file/ | cat
    '';
    installPhase = "install -Dm555 $src $out/bin/pixeldrain-cli";
    dontUnpack = true;
  };
in
{
  sops.secrets."pixeldrain/apikey".owner = "root";

  environment.systemPackages = [ pixeldrainCli ];
}
