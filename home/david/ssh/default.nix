{
  lib,
  pkgs,
  config,
  ...
}:
let
  domain = config.vars.domain;
in
{
  programs.ssh = lib.mkIf config.hm-config.dotfiles {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
      "iroha" = {
        hostname = "iroha.${domain}";
        user = "root";
      };
      "rimuru" = {
        hostname = "rimuru.${domain}";
        user = "root";
      };
      "rpi5" = {
        hostname = "rpi5.${domain}";
        user = "root";
        forwardAgent = true;
      };
      "ryuzu" = {
        hostname = "ryuzu.${domain}";
        user = "david";
        forwardAgent = true;
      };
      "xiatian" = {
        hostname = "xiatian.${domain}";
        user = "david";
        forwardAgent = true;
      };
      "git-ssh.mainlining.org" = {
        proxyCommand = "${lib.getExe pkgs.cloudflared} access ssh --hostname %h";
      };
      "mainlining" = {
        hostname = "mail.mainlining.org";
        user = "root";
      };
      "postmarketos" = {
        hostname = "172.16.42.1";
        userKnownHostsFile = "/dev/null";
      };
    };
  };
}
