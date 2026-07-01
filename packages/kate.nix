{
  lib,
  symlinkJoin,
  makeWrapper,
  kdePackages,
  cargo,
  gcc,
  openssl,
  pkg-config-unwrapped,
  python3,
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
          rust-analyzer
          rustc
          (python3.withPackages (
            ps: with ps; [
              python-lsp-server
              black
            ]
          ))
        ]
      }'
  '';
})
