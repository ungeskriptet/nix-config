{ lib, writeShellScriptBin, fetchurl, android-tools }:
let
  version = "30.7";
  magisk = fetchurl {
    url = "https://github.com/topjohnwu/Magisk/releases/download/v${version}/Magisk-v${version}.apk";
    hash = "sha256-4NMtISNTKGD5cSPZJ7G7hsTgjm/YpIv8a1vuCvrp69U=";
  };
in
writeShellScriptBin "magisk-install" ''
  help () {
    cat <<EOF
  Install or sideload Magisk

  Options:
  -i | --install    Install Magisk (Default)
  -s | --sideload   Sideload Magisk
  -h | --help       Show help and exit
  EOF
  }

  # Defaults
  install=0
  sideload=0

  while [ $# -gt 0 ]; do
    case "$1" in
      --install|-i) install=1; shift 1 ;;
      --sideload|-s) sideload=1; shift 1 ;;
      --help|-h) help; exit ;;
      *) break ;;
    esac
  done

  if [ $install -eq 0 ] && [ $sideload -eq 0 ]; then
    install=1
  fi

  if [ $install -ne 0 ]; then
    echo "< waiting for any device >"
    ${lib.getExe' android-tools "adb"} wait-for-usb-device
    ${lib.getExe' android-tools "adb"} -d install ${magisk}
    exit
  fi

  if [ $sideload -ne 0 ]; then
    echo "< waiting for any device >"
    ${lib.getExe' android-tools "adb"} wait-for-usb-sideload
    ${lib.getExe' android-tools "adb"} -d sideload ${magisk}
    exit
  fi
''
