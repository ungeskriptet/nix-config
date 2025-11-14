{
  config,
  pkgs,
  inputs,
  ...
}:
let
  fqdn = "code.${domain}";
  domain = config.networking.domain;
  openvscode-server =
    inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.openvscode-server;
in
{
  sops.secrets = {
    "openvscode-server/basicauth".owner = "caddy";
    "openvscode-server/token".owner = "openvscode-server";
  };

  networking.hosts."::1" = [ fqdn ];
  networking.hosts."127.0.0.1" = [ fqdn ];

  systemd.tmpfiles.rules = [
    "d /var/lib/openvscode-server/extensions 0755 openvscode-server openvscode-server -"
    "d /var/lib/openvscode-server/serverdata 0755 openvscode-server openvscode-server -"
    "d /var/lib/openvscode-server/userdata 0755 openvscode-server openvscode-server -"
  ];

  services.caddy.virtualHosts = {
    "https://${fqdn}".extraConfig = ''
      tls ${config.acme.tlsCert} ${config.acme.tlsKey}
      reverse_proxy http://${fqdn}:8092
      basic_auth {
        import ${config.sops.secrets."openvscode-server/basicauth".path}
      }
    '';
  };

  services.openvscode-server = {
    enable = true;
    host = "::1";
    port = 8092;
    package = openvscode-server;
    extraEnvironment = {
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
    };
    extraPackages = with pkgs; [
      biome
      cargo
      delve
      gcc
      go
      lld
      nixd
      pkg-config
      rustc
    ];
    telemetryLevel = "off";
    extensionsDir = "/var/lib/openvscode-server/extensions";
    serverDataDir = "/var/lib/openvscode-server/serverdata";
    userDataDir = "/var/lib/openvscode-server/userdata";
    connectionTokenFile = config.sops.secrets."openvscode-server/token".path;
  };
}
