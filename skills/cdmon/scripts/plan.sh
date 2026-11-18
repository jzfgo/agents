#!/usr/bin/env bash
# Show what a changes file would do to a domain. Reads only; never writes.
#   plan.sh DOMAIN CHANGES.json [--json]
# Exit: 0 plan is valid, 2 plan has errors.
# Example: ./plan.sh example.com changes.json
#
# CHANGES.json is an array of ops (host relative to the zone, "@" = apex):
#   {"op":"add",    "type":"TXT","host":"@","value":"v=spf1 -all","ttl":900}
#   {"op":"add",    "type":"CNAME","host":"www","value":"example.com"}
#   {"op":"set",    "type":"A",  "host":"@","values":["192.0.2.1","192.0.2.2"]}
#   {"op":"upsert", "type":"TXT","host":"@","match":"^v=spf1","value":"v=spf1 include:x ~all"}
#   {"op":"remove", "type":"TXT","host":"@","value":"old-verification=abc"}
#   {"op":"delete", "type":"CNAME","host":"old"}
. "$(dirname "$0")/_lib.sh"

[ $# -ge 2 ] || cdmon_die "usage: plan.sh DOMAIN CHANGES.json [--json]"
domain="$1" changes="$2"
current="$(cdmon_records "$domain")" || exit 1
plan="$(cdmon_plan "$domain" "$current" "$changes")"
if [ "${3:-}" = "--json" ]; then jq . <<<"$plan"; else cdmon_render <<<"$plan"; fi
jq -e '.errors | length == 0' >/dev/null <<<"$plan" || exit 2
