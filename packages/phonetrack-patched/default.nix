{ runCommand }:
runCommand "phonetrack-patched" { } ''
  mkdir -p $out
  tar xzf ${./phonetrack-0.9.2.tar.gz} --strip-components=1 -C $out
''
