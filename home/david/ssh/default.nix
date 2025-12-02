{ lib, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
      "rpi5" = {
        hostname = "fd64::2";
        user = "root";
        forwardAgent = true;
      };
      "ryuzu" = {
        hostname = "fd64::8";
        user = "david";
        forwardAgent = true;
      };
      "xiatian" = {
        hostname = "xiatian";
        user = "david";
        forwardAgent = true;
      };
      "daruma" = {
        hostname = "daruma";
        user = "root";
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
        strictHostKeyChecking = "no";
      };
    };
  };
}
