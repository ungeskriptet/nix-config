{ lib, pkgs }:
''
  AddKeysToAgent yes
  Host rpi5
    Hostname rpi5
    User root
    ForwardAgent yes
  Host ryuzu
    Hostname ryuzu
    User david
    ForwardAgent yes
  Host xiatian
    Hostname xiatian
    User david
    ForwardAgent yes
  Host daruma
    Hostname daruma
    User root
  Host git-ssh.mainlining.org
    ProxyCommand ${lib.getExe pkgs.cloudflared} access ssh --hostname %h
  Host mainlining
    Hostname mail.mainlining.org
    User root
''
