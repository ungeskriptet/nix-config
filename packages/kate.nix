{
  lib,
  symlinkJoin,
  makeWrapper,
  kdePackages,
  python3Packages,
  cargo,
  gcc,
  openssl,
  pkg-config-unwrapped,
  rust-analyzer,
  rustc,
  rustPlatform,
}:
lib.meta.hiPrio (symlinkJoin {
  inherit (kdePackages.kate) name;
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
          kdePackages.konsole
          pkg-config-unwrapped
          python3Packages.python-lsp-server
          rust-analyzer
          rustc
        ]
      }'
  '';
})
