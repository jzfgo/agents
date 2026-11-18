# shellcheck shell=bash
# Shared helpers for the cdmon scripts. Source it; do not run it.
#
# Secret handling: the API key is read from CDMON_API_KEY and only ever
# reaches curl through a process-substitution header file, so it never shows up
# in argv (ps), in shell tracing, or in anything this library prints.

set -euo pipefail
set +x

CDMON_API_BASE="${CDMON_API_BASE:-https://api-domains.cdmon.services/api-domains}"
CDMON_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Types the API can write (verified against the live API, see
# references/api.md). AAAA, MX, NS and SOA are listed by getDnsRecords but
# create answers "DNS record type not supported".
CDMON_TYPES="A CNAME TXT"

cdmon_die() {
  printf 'cdmon: %s\n' "$*" >&2
  exit 1
}

cdmon_redact() {
  # Replace any occurrence of the key in a string. Defensive: the API has never
  # been seen echoing it, but error bodies are passed through to the user.
  local s="$1"
  if [ -n "${CDMON_API_KEY:-}" ]; then
    s="${s//"$CDMON_API_KEY"/[redacted]}"
  fi
  printf '%s' "$s"
}

cdmon_require() {
  command -v curl >/dev/null || cdmon_die "curl is required"
  command -v jq >/dev/null || cdmon_die "jq is required"
  [ -n "${CDMON_API_KEY:-}" ] || cdmon_die "CDMON_API_KEY is not set"
}

# cdmon_call ENDPOINT JSON_BODY
# Prints the response body on success ({"status":"ok",...}). On any failure,
# prints one redacted line to stderr and exits non-zero.
cdmon_call() {
  local endpoint="$1" body="$2" out code resp msg
  cdmon_require
  # The API allows 3 requests/second; stay under it. This sleeps before the
  # first call too: callers run cdmon_call in subshells ($(...), pipes), so a
  # "called before" flag would not survive between calls.
  sleep 0.4
  # Body and status come back together (status on the last line), so there is
  # no temp file to leak if the run is interrupted.
  if ! out="$(curl -sS -w '\n%{http_code}' -X POST \
      "$CDMON_API_BASE/$endpoint" \
      -H 'Accept: application/json' \
      -H 'Content-Type: application/json' \
      -H @<(printf 'apikey: %s\n' "$CDMON_API_KEY") \
      --data-binary "$body")"; then
    # Return, do not exit: apply.sh calls this inside `if` and must still print
    # its partial-failure report when the network drops mid-run.
    printf 'cdmon: %s: network error\n' "$endpoint" >&2
    return 1
  fi
  code="${out##*$'\n'}"
  resp="$(cdmon_redact "${out%$'\n'*}")"
  if [ "$code" = 200 ] && jq -e '.status == "ok"' >/dev/null 2>&1 <<<"$resp"; then
    printf '%s\n' "$resp"
    return 0
  fi
  # Two error shapes: {"status":"ko","data":"..."} from the API itself, and
  # {"message":"...","request_id":"..."} from the gateway (auth, 401).
  msg="$(jq -r 'if (.data | type) == "string" then .data
                elif .data != null then (.data | tojson)
                else (.message // tojson) end' 2>/dev/null <<<"$resp" || printf '%s' "$resp")"
  printf 'cdmon: %s: HTTP %s: %s\n' "$endpoint" "$code" "$msg" >&2
  return 1
}

# cdmon_records DOMAIN -> normalized JSON array of {type,host,ttl,value,priority}
cdmon_records() {
  local domain="$1"
  cdmon_call getDnsRecords "$(jq -nc --arg d "$domain" '{data: {domain: $d}}')" |
    jq -c '[.data.result[] | {
      type: (.type | ascii_upcase),
      host: .host,
      ttl: (.ttl | tonumber? // .),
      value: .value,
      priority: (if .priority == null then null else (.priority | tonumber? // .) end)
    }]'
}

# cdmon_plan DOMAIN CURRENT_JSON CHANGES_FILE -> plan JSON
cdmon_plan() {
  local domain="$1" current="$2" changes="$3"
  [ -f "$changes" ] || cdmon_die "changes file not found: $changes"
  jq -e 'type == "array"' "$changes" >/dev/null 2>&1 || cdmon_die "changes file must be a JSON array"
  jq -n --arg domain "$domain" --arg types "$CDMON_TYPES" \
    --argjson cur "$current" --slurpfile changes "$changes" \
    -f "$CDMON_LIB_DIR/plan.jq"
}

cdmon_render() {
  jq -r -f "$CDMON_LIB_DIR/render.jq"
}
