{
  writeShellScriptBin,
  apiKeyFile ? "/var/lib/pixeldrain",
  lib,
  curl,
}:

writeShellScriptBin "pixeldrain-cli" ''
  APIKEY=$(cat ${apiKeyFile})
  ${lib.getExe curl} \
    -T "$1" -u :$APIKEY \
    https://pixeldrain.com/api/file/ | cat
''
