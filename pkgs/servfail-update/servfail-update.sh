#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Copyright (C) 2026 David Wronek <david.wronek@mainlining.org>
set -eou pipefail

help () {
  cat <<EOF
DNS updater for Project SERVFAIL.

Usage:
servfail-update <arguments>

Required arguments:
-z, --zone
      The zone to update.
-t, --token
      Path to a file containing the API token.
-n, --nameserver
      The name server to update the DNS zone on.
-d, --dyndns
      Path to a file containg the dynamic DNS token.
      This token should point to your root domain.

Optional arguments:
-h, --help
      Show help and exit.
-r, --rrsets
      Path to a JSON file containing additional RRsets.
EOF
}

zone=
token=
dyndns=
nameserver=
base_url="https://beta.servfail.network"
curl_args=(
  -sS
  --max-time 3
  --retry 10
  --fail
  --user-agent "ungeskriptet/servfail-update"
)

while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) help; exit ;;
    --zone|-z) shift 1; zone="${1:-}"; [[ $# -gt 0 ]] && shift 1 ;;
    --token|-t) shift 1; token="${1:-}"; [[ $# -gt 0 ]] && shift 1 ;;
    --dyndns|-y) shift 1; dyndns="${1:-}"; [[ $# -gt 0 ]] && shift 1 ;;
    --rrsets|-r) shift 1; rrsets_file="${1:-}"; [[ $# -gt 0 ]] && shift 1 ;;
    --nameserver|-n) shift 1; nameserver="${1:-}"; [[ $# -gt 0 ]] && shift 1 ;;
    *) help; exit 1 ;;
  esac
done

if [[ -z "$nameserver" || -z "$zone" || ! -e "$token" || ! -e "$dyndns" || -v rrsets_file && ! -e "$rrsets_file" ]]; then
  help
  exit 1
fi

for ip_arg in "-4" "-6"; do
  curl \
    "${curl_args[@]}" \
    "$ip_arg" \
    --get \
    --data-urlencode token@"$dyndns" \
    "$base_url"/ddns
done

entries=()
while IFS=" " read -ra line; do
  if [[ "${line[0]}" == "::1" ]]; then
    unset "line[0]"
    for entry in "${line[@]}"; do
      if [[ "$entry" == *."$zone" ]]; then
        entries+=("$entry")
      fi
    done
  fi
done < /etc/hosts

rrsets="[]"
for entry in "${entries[@]}"; do
  rrsets=$(echo "$rrsets" | jq -rc ". +=
    [
      {
        \"name\":\"$entry.\",
        \"type\":\"ALIAS\",
        \"ttl\":300,
        \"changetype\":\"REPLACE\",
        \"records\": [
          {\"content\":\"$zone.\"}
        ]
      }
    ]
  ")
done

if [[ -v rrsets_file && -e "$rrsets_file" ]]; then
  rrsets=$(echo "$rrsets" | jq -rcs "add" - "$rrsets_file")
fi

payload=$(echo "{\"rrsets\":$rrsets}" | jq -rc ".")

exec {token_header}<<<"X-API-Key: $(<"$token")"

if curl \
  "${curl_args[@]}" \
  -X PATCH \
  -H @/dev/fd/"$token_header" \
  -H "Content-Type: application/json" \
  --data-raw "$payload" \
  "$base_url"/api/v1/servers/"$nameserver"./zones/"$zone".
then
  echo "Zone successfully updated"
else
  echo "Failed to update zone"
fi
