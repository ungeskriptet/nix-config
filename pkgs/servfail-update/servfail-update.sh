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

Mutually exclusive arguments:
-d, --dyndns
      Path to a file containg the dynamic DNS token.
      This token should point to your root domain.
-H, --hostname
      Hostname to update.
      Requires --ipv4 or --ipv6, or both.

Optional arguments:
-h, --help
      Show help and exit.
-r, --rrsets
      Path to a JSON file containing additional RRsets.
-6, --ipv6
      Comma-separated list of IPv6 addresses.
-4, --ipv4
      Comma-separated list of IPv4 addresses.
EOF
}

build_rrset () {
  rrsets="${1:-"[]"}"
  name="$2"
  record_type="$3"
  contents="$4"

  # shellcheck disable=SC2162
  IFS=',' read -a contents <<< "$contents"
  for content in "${contents[@]}"; do
    records=$(echo "${records:-"[]"}" | jq -rc ". +=
      [{\"content\":\"$content\"}]
    ")
  done

  echo "$rrsets" | jq -rc ". +=
    [
      {
        \"name\":\"$name.\",
        \"type\":\"$record_type\",
        \"ttl\":300,
        \"changetype\":\"REPLACE\",
        \"records\": $records
      }
    ]
  "
}

base_url="https://beta.servfail.network"
curl_args=(
  -sS
  --max-time 3
  --retry 10
  --fail
  --user-agent "ungeskriptet/servfail-update"
)

# Register the argument first and set the value in the second loop iteration.
while [ $# -gt 0 ]; do
  arg="${1:-}"
  # shellcheck disable=SC2015
  case "$1" in
    --help|-h) help; exit ;;
    --zone|-z) [[ ! -v zone && -z "${zone:-}" ]] && argname=zone && zone="" && continue || shift 1 ;;
    --token|-t) [[ ! -v token && -z "${token:-}" ]] && argname=token && token="" && continue || shift 1 ;;
    --dyndns|-y) [[ ! -v dyndns && -z "${dyndns:-}" ]] && argname=dyndns && dyndns="" && continue || shift 1 ;;
    --rrsets|-r) [[ ! -v rrsets_file && -z "${rrsets_file:-}" ]] && argname=rrsets_file && rrsets_file="" && continue || shift 1 ;;
    --nameserver|-n) [[ ! -v nameserver && -z "${nameserver:-}" ]] && argname=nameserver && nameserver="" && continue || shift 1 ;;
    --hostname|-H) [[ ! -v hostname && -z "${hostname:-}" ]] && argname=hostname && hostname="" && continue || shift 1 ;;
    --ipv6|-6) [[ ! -v ipv6 && -z "${ipv6:-}" ]] && argname=ipv6 && ipv6="" && continue || shift 1 ;;
    --ipv4|-4) [[ ! -v ipv4 && -z "${ipv4:-}" ]] && argname=ipv4 && ipv4="" && continue || shift 1 ;;
    *) shift 1; [[ -n "${argname:-}" ]] && declare "$argname"="$arg" && argname="" && continue || help && exit 1 ;;
  esac
done

if [[
  -z "${nameserver:-}" ||
  -z "${zone:-}" ||
  ! -e "${token:-}" ||
  -v dyndns && ! -e "${dyndns:-}" ||
  -v rrsets_file && ! -e "${rrsets_file:-}" ||
  -v hostname && ! (-v ipv6 || -v ipv4) ||
  -v ipv6 && -z "$ipv6" || -v ipv4 && -z "$ipv4" ||
  ! (-v hostname || -v dyndns) # One of these arguments must be set
]]; then
  help
  exit 1
fi

if [[ -n "${dyndns:-}" ]]; then
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

  for entry in "${entries[@]}"; do
    rrsets=$(build_rrset "${rrsets:-}" "$entry" "ALIAS" "$zone.")
  done
elif [[ -n "${hostname:-}" ]]; then
  if [[ -n "${ipv6:-}" ]]; then
    rrsets=$(build_rrset "${rrsets:-}" "$hostname.$zone" "AAAA" "$ipv6")
  fi
  if [[ -n "${ipv4:-}" ]]; then
    rrsets=$(build_rrset "${rrsets:-}" "$hostname.$zone" "A" "$ipv4")
  fi
fi


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
  exit 1
fi
