{ lib, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
      "iroha" = {
        hostname = "192.168.3.8";
        user = "root";
      };
      "rimuru" = {
        hostname = "rimuru";
        user = "root";
      };
      "rpi5" = {
        hostname = "fd64::2";
        user = "root";
        forwardAgent = true;
      };
      "ryuzu" = {
        user = "david";
        forwardAgent = true;
      };
      "xiatian" = {
        hostname = "xiatian";
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
