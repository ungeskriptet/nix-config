{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.nix-config.kate;
in
{
  options.nix-config.kate = {
    enable = lib.mkEnableOption "Kate";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.callPackage (
        {
          lib,
          symlinkJoin,
          makeWrapper,
          kdePackages,
          cargo,
          gcc,
          openssl,
          pkg-config-unwrapped,
          rust-analyzer,
          rustc,
          rustPlatform,
        }:
        symlinkJoin {
          name = "kate-dev";
          nativeBuildInputs = [ makeWrapper ];
          paths = [ kdePackages.kate ];
          postBuild = ''
            wrapProgram $out/bin/kate \
              --set RUST_SRC_PATH '${rustPlatform.rustLibSrc}' \
              --prefix PKG_CONFIG_PATH : '${lib.getDev openssl}/lib/pkgconfig' \
              --prefix PATH : '${
                lib.makeBinPath [
                  cargo
                  gcc
                  pkg-config-unwrapped
                  rust-analyzer
                  rustc
                ]
              }'
          '';
        }
      ) { })
    ];
  };
}
