{ rustPlatform }:
rustPlatform.buildRustPackage {
  name = "fritzbox-dyndns-interceptor";

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta.mainProgram = "fritzbox-dyndns-interceptor";
}
