{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  domain = config.networking.domain;
  lanIpv4 = config.networking.lanIPv4;
  lanIpv6 = config.networking.lanIPv6;
  globalIpv6 = config.networking.globalIpv6;
  util = inputs.dns.util.${pkgs.stdenv.hostPlatform.system};
in
{
  services = {
    knot = {
      enable = true;
      keyFiles = [ config.sops.secrets."knot/tsig-keys".path ];
      settings = {
        server.listen = [
          "${lanIpv4}@53"
          "${lanIpv6}@53"
          "${globalIpv6}@53"
        ];
        acl = [
          {
            id = "rpi5_acl";
            key = "rpi5";
            action = "update";
          }
          {
            id = "ryuzu_acl";
            key = "ryuzu";
            action = "update";
            update-owner = "name";
            update-owner-match = "equal";
            update-owner-name = [ "ryuzu" ];
          }
          {
            id = "xiatian_acl";
            key = "xiatian";
            action = "update";
            update-owner = "name";
            update-owner-match = "equal";
            update-owner-name = [ "xiatian" ];
          }
        ];
        policy = [
          {
            id = "default";
            nsec3 = "on";
          }
        ];
        zone = [
          {
            inherit domain;
            file = util.writeZone domain (
              import (./dns-zones + "/default-zone.nix") {
                inherit lib config;
                inherit (inputs) dns;
              }
            );
            acl = [
              "rpi5_acl"
              "xiatian_acl"
            ];
            dnssec-signing = "on";
            dnssec-policy = "default";
            journal-content = "all";
            semantic-checks = "on";
            zonefile-sync = "-1";
            zonefile-load = "difference-no-serial";
          }
        ];
      };
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
    hosts = {
      ${lanIpv4} = [ "ns1.${domain}" ];
      ${lanIpv6} = [ "ns1.${domain}" ];
    };
  };

  sops.secrets."knot/tsig-keys".owner = "knot";
}
