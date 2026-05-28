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
    settings = {
      "*" = {
        AddKeysToAgent = true;
      };
      "iroha" = {
        HostName = "iroha.${domain}";
        User = "root";
      };
      "rimuru" = {
        HostName = "rimuru.${domain}";
        User = "root";
      };
      "rpi5" = {
        HostName = "rpi5.${domain}";
        User = "root";
        ForwardAgent = true;
      };
      "ryuzu" = {
        HostName = "ryuzu.${domain}";
        User = "david";
        ForwardAgent = true;
      };
      "xiatian" = {
        HostName = "xiatian.${domain}";
        User = "david";
        ForwardAgent = true;
      };
      "git-ssh.mainlining.org" = {
        ProxyCommand = "${lib.getExe pkgs.cloudflared} access ssh --HostName %h";
      };
      "mainlining" = {
        HostName = "mail.mainlining.org";
        User = "root";
      };
      "postmarketos" = {
        HostName = "172.16.42.1";
        UserKnownHostsFile = "/dev/null";
      };
    };
  };
}
