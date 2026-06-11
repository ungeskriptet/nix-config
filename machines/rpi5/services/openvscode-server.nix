{ pkgs, config, ... }:
let
  domain = config.networking.domain;
  fqdn = "code.${domain}";
  stateDir = "/var/lib/openvscode";
in
{
  programs.nix-ld.enable = true;
  services = {
    openvscode-server = {
      enable = true;
      host = fqdn;
      port = 8100;
      withoutConnectionToken = true;
      socketPath = "/run/openvscode-server/socket";
      userDataDir = "${stateDir}/userdata";
      serverDataDir = "${stateDir}/serverdata";
      extensionsDir = "${stateDir}/extensions";
      telemetryLevel = "off";
      extraPackages = with pkgs; [ jdk ];
      extraEnvironment = with pkgs; {
        NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
          stdenv.cc.cc
          openssl
        ];
        NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
      };
    };
    caddy.hosts.${fqdn} = {
      reverseProxies."unix///run/openvscode-server/socket" = { };
      extraConfig = ''
        forward_auth unix///run/tinyauth/tinyauth.sock {
          uri /api/auth/caddy
        }
      '';
    };
  };

  systemd.services = {
    caddy = {
      serviceConfig.SupplementaryGroups = [ config.services.openvscode-server.group ];
    };
    openvscode-server = {
      postStart = ''
        while [[ ! -S /run/openvscode-server/socket ]]; do
          sleep 1
        done
        chmod 660 /run/openvscode-server/socket
      '';
      serviceConfig.StateDirectory = "openvscode";
    };
  };
}
