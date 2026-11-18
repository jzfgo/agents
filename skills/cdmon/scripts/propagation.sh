#!/usr/bin/env bash
# Check a record on the zone's authoritative nameservers and on public resolvers.
#   propagation.sh DOMAIN HOST TYPE [EXPECTED]
# HOST is relative to the zone ("@" for the apex). EXPECTED, if given, must
# appear in one of the answers (case-insensitive substring).
# Only answers whose owner and type match are counted, so a wildcard CNAME
# answering a TXT query shows as "missing", not as a false "ok".
# Needs dig, no API key. Exit 0 when every server answers (and matches).
# Example: ./propagation.sh example.com _dmarc TXT v=DMARC1
set -euo pipefail

[ $# -ge 3 ] || { echo "usage: propagation.sh DOMAIN HOST TYPE [EXPECTED]" >&2; exit 1; }
domain="$1" host="$2" type="$(printf '%s' "$3" | tr '[:lower:]' '[:upper:]')" expected="${4:-}"
command -v dig >/dev/null || { echo "dig is required" >&2; exit 1; }

if [ "$host" = "@" ]; then fqdn="$domain"; else fqdn="$host.$domain"; fi
fqdn="$(printf '%s' "$fqdn" | tr '[:upper:]' '[:lower:]')"

servers="$({ dig +short NS "$domain" @1.1.1.1 || true; } | sed 's/\.$//' | sort) 1.1.1.1 8.8.8.8 9.9.9.9"

fail=0
printf '%-26s %-8s %s\n' SERVER STATUS ANSWER
for s in $servers; do
  out="$(dig +noall +answer +time=3 +tries=1 "$fqdn" "$type" @"$s" 2>/dev/null || true)"
  # TXT answers come as one or more quoted chunks ("a" "b") with \", \\ and \DDD
  # escaped inside; join the chunks and unescape, so a value that contains
  # quotes or spaces is compared as published.
  answers="$(awk -v n="$fqdn." -v t="$type" 'tolower($1) == n && $4 == t {
      if (t != "TXT") {
        v = ""; for (i = 5; i <= NF; i++) v = v (i > 5 ? " " : "") $i; print v; next }
      v = $0; for (k = 1; k <= 4; k++) sub(/^[ \t]*[^ \t]+[ \t]+/, "", v)
      r = ""; q = 0
      for (i = 1; i <= length(v); i++) {
        c = substr(v, i, 1)
        if (q && c == "\\" && substr(v, i + 1, 3) ~ /^[0-9][0-9][0-9]$/) {
          r = r sprintf("%c", substr(v, i + 1, 3) + 0); i += 3 }
        else if (q && c == "\\") { i++; r = r substr(v, i, 1) }
        else if (c == "\"") q = !q
        else if (q) r = r c
      }
      print r }' <<<"$out")"
  if [ -z "$answers" ]; then
    other="$(awk -v n="$fqdn." 'tolower($1) == n && $4 == "CNAME" { print $5 }' <<<"$out" | head -1)"
    status=missing; shown="${other:+(only CNAME $other — wildcard?)}"
  elif [ -n "$expected" ] && ! grep -qiF -- "$expected" <<<"$answers"; then
    status=mismatch; shown="$(paste -sd '|' - <<<"$answers")"
  else
    status=ok; shown="$(paste -sd '|' - <<<"$answers")"
  fi
  [ "$status" = ok ] || fail=1
  printf '%-26s %-8s %s\n' "$s" "$status" "$(cut -c1-110 <<<"$shown")"
done
exit "$fail"
