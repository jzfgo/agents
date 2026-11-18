#!/usr/bin/env bash
# List the domains in the cdmon account.
#   domains.sh            table: domain, expiry, auto-renew, nameservers
#   domains.sh --json     same data as JSON (contacts are always dropped)
# Example: ./domains.sh
. "$(dirname "$0")/_lib.sh"

json=0
[ "${1:-}" = "--json" ] && json=1

data="$(cdmon_call domains/list '{"data":{"extended_info":1}}' |
  jq -c '[.data.result[] | {domain, expiration_date, registration_date, autorenew,
          nameservers: .dns_zones}]')"

if [ "$json" = 1 ]; then
  jq . <<<"$data"
else
  jq -r '(["DOMAIN", "EXPIRES", "AUTORENEW", "NAMESERVERS"] | @tsv),
         (.[] | [.domain, .expiration_date, .autorenew, (.nameservers | join(","))] | @tsv)' \
    <<<"$data" | column -t -s $'\t'
fi
