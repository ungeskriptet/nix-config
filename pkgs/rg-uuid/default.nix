{
  lib,
  writeShellScriptBin,
  writers,
  ripgrep,
}:
let
  uuid-to-bytes = writers.writePython3Bin "uuid-to-bytes" { } ./uuid-to-bytes.py;
in
writeShellScriptBin "rg-uuid" ''
  set -euo pipefail

  help () {
    cat <<EOF
  Wrapper for ripgrep to search for binary UUIDs.
  See rg(1) for ripgrep help.

  Usage:
  rg-uuid [-s] <UUID> [rg options]

  Options:
  -s | --swap    Swap UUID bytes
  -h | --help    Show help and exit
  EOF
  }

  # Defaults
  swap=0

  while [ $# -gt 0 ]; do
    case "$1" in
      --swap|-s) swap=1; shift 1 ;;
      --help|-h) help; exit ;;
      *) break ;;
    esac
  done

  if [ $swap -eq 0 ]; then
    UUID=$(${lib.getExe uuid-to-bytes} little $1)
  else
    UUID=$(${lib.getExe uuid-to-bytes} big $1)
  fi

  shift 1

  ${lib.getExe ripgrep} --text --encoding=none "(?-u)$UUID" "$@"
''
