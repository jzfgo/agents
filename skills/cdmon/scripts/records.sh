#!/usr/bin/env bash
# List the DNS records of a domain.
#   records.sh DOMAIN [--type TYPE] [--host HOST] [--json]
# HOST is relative to the zone ("@" for the apex, "www", "_dmarc").
# Example: ./records.sh example.com --type TXT
. "$(dirname "$0")/_lib.sh"

domain="${1:-}"; [ -n "$domain" ] || cdmon_die "usage: records.sh DOMAIN [--type TYPE] [--host HOST] [--json]"
shift
type="" host="" json=0
while [ $# -gt 0 ]; do
  case "$1" in
    --type) type="$(printf '%s' "$2" | tr '[:lower:]' '[:upper:]')"; shift 2 ;;
    --host) host="$2"; shift 2 ;;
    --json) json=1; shift ;;
    *) cdmon_die "unknown argument: $1" ;;
  esac
done

data="$(cdmon_records "$domain" | jq -c --arg t "$type" --arg h "$host" \
  'map(select(($t == "" or .type == $t) and ($h == "" or .host == $h)))')"

if [ "$json" = 1 ]; then
  jq . <<<"$data"
else
  jq -r '(["TYPE", "HOST", "TTL", "PRIO", "VALUE"] | @tsv),
         (sort_by(.type, .host)[] | [.type, .host, .ttl, (.priority // "-"), .value] | @tsv)' \
    <<<"$data" | column -t -s $'\t'
fi
