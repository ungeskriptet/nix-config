{
  rustPlatform,
  aws-lc,
  pkg-config,
}:
rustPlatform.buildRustPackage {
  name = "fritzbox-dyndns-interceptor";

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ aws-lc ];

  meta.mainProgram = "fritzbox-dyndns-interceptor";
}
