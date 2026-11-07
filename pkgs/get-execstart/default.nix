{
  writeShellApplication,
  gnugrep,
  systemdMinimal,
}:
writeShellApplication {
  name = "get-execstart";
  runtimeInputs = [
    gnugrep
    systemdMinimal
  ];
  inheritPath = false;
  text = ''
    if [ -z "$1" ]; then
      echo "usage: get-execstart <unit>"
      exit 1
    fi
    IFS=$'\n'
    for line in $(systemctl cat "$1" | grep ExecStart); do
      echo "/''${line#*/}"
    done
  '';
}
