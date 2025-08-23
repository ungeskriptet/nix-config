{
  config,
  pkgs,
  inputs,
  vars,
  ...
}:
let
  domain = "code.${baseDomain}";
  baseDomain = vars.baseDomain;
  tlsKey = "${config.security.acme.certs."${baseDomain}".directory}/key.pem";
  tlsCert = "${config.security.acme.certs."${baseDomain}".directory}/fullchain.pem";
  openvscode-server = inputs.nixpkgs.legacyPackages.${pkgs.system}.openvscode-server;
in
{
  sops.secrets = {
    "openvscode-server/basicauth".owner = "caddy";
    "openvscode-server/token".owner = "openvscode-server";
  };

  networking.hosts."::1" = [ domain ];
  networking.hosts."127.0.0.1" = [ domain ];

  systemd.tmpfiles.rules = [
    "d /var/lib/openvscode-server/extensions 0755 openvscode-server openvscode-server -"
    "d /var/lib/openvscode-server/serverdata 0755 openvscode-server openvscode-server -"
    "d /var/lib/openvscode-server/userdata 0755 openvscode-server openvscode-server -"
  ];

  services.caddy.virtualHosts = {
    "https://${domain}".extraConfig = ''
      tls ${tlsCert} ${tlsKey}
      reverse_proxy http://${domain}:8092
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
      cargo
      gcc
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
