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
          "::2@53"
          "127.0.0.2@53"
        ];
        acl = [
          # keep-sorted start block=yes
          {
            id = "celica_acl";
            key = "celica";
            action = "update";
            update-owner = "name";
            update-owner-match = "sub-or-equal";
            update-owner-name = [ "celica" ];
          }
          {
            id = "iroha_acl";
            key = "iroha";
            action = "update";
            update-owner = "name";
            update-owner-match = "sub-or-equal";
            update-owner-name = [ "iroha" ];
          }
          {
            id = "misaka_acl";
            key = "misaka";
            action = "update";
          }
          {
            id = "rimuru_acl";
            key = "rimuru";
            action = "update";
            update-owner = "name";
            update-owner-match = "sub-or-equal";
            update-owner-name = [ "rimuru" ];
          }
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
            update-owner-match = "sub-or-equal";
            update-owner-name = [ "ryuzu" ];
          }
          {
            id = "stalwart_acl";
            key = "stalwart";
            action = "update";
          }
          {
            id = "tsugaru_acl";
            key = "tsugaru";
            action = "update";
            update-owner = "name";
            update-owner-match = "sub-or-equal";
            update-owner-name = [ "tsugaru" ];
          }
          {
            id = "xiatian_acl";
            key = "xiatian";
            action = "update";
            update-owner = "name";
            update-owner-match = "sub-or-equal";
            update-owner-name = [ "xiatian" ];
          }
          # keep-sorted end
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
                inherit config;
                inherit (inputs) dns;
              }
            );
            acl = [
              # keep-sorted start
              "celica_acl"
              "iroha_acl"
              "misaka_acl"
              "rimuru_acl"
              "rpi5_acl"
              "ryuzu_acl"
              "stalwart_acl"
              "tsugaru_acl"
              "xiatian_acl"
              # keep-sorted end
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
    hosts = lib.mkAfter {
      "::2" = [ "ns1.${domain}" ];
      "127.0.0.2" = [ "ns1.${domain}" ];
    };
  };

  sops.secrets."knot/tsig-keys".owner = "knot";
}
