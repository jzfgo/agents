# Compute a change plan for one cdmon zone.
#
# Inputs (jq --arg/--argjson/--slurpfile):
#   $domain   zone name, e.g. example.com
#   $types    space-separated list of writable record types
#   $cur      current records, normalized by cdmon_records
#   $changes  [ changes array ] (slurped)
#
# cdmon's edit and delete endpoints act on the WHOLE set of records sharing
# (host, type) — the record value is ignored. create adds to a TXT set but
# replaces an A set, and the API cannot write AAAA or MX at all. So the unit of change here is
# the RRset: every op is folded into a final RRset, and the plan says how to
# get from the current RRset to it.

def nhost:
  (. // "@") | tostring | ascii_downcase | rtrimstr(".")
  | if . == "" or . == $domain then "@"
    elif endswith("." + $domain) then rtrimstr("." + $domain)
    else . end;

def ntype: tostring | ascii_upcase;

# MX is never written (the API rejects it), but records read from the zone are
# normalized too, so the comparison stays case- and dot-insensitive.
def nvalue($t):
  tostring
  | if ($t == "CNAME" or $t == "MX") then ascii_downcase | rtrimstr(".") else . end;

def nprio: if . == null then null else (tonumber? // .) end;

def id: "\(.value)|\(.priority)";

def norm($t):
  { value: (.value | nvalue($t)),
    priority: (.priority | nprio),
    ttl: ((.ttl // 900) | tonumber? // 900) };

def oprecords($op):
  ($op.type | ntype) as $t
  | if $op.records then $op.records
    elif $op.values then $op.values | map({value: .})
    else [{value: $op.value}] end
  | map(.priority = (.priority // $op.priority) | .ttl = (.ttl // $op.ttl)
        | (.ttl != null) as $given | norm($t) | .given = $given);

# A record already in the set keeps its TTL unless the op names one, so
# re-adding an existing value is a no-op rather than a TTL rewrite to 900.
def keepttl($c):
  . as $r
  | if $r.given then $r
    else ([$c[] | select(id == ($r | id))] | first) // $r end;

def addrec($r):
  if any(.[]; id == ($r | id)) then map(if id == ($r | id) then (. as $e | $r | keepttl([$e])) else . end)
  else . + [$r] end;

def dropmatch($op; $t):
  # try: an invalid regex is reported in $operrors (exit 2); it must not abort jq here.
  if $op.match then map(select(.value | try test($op.match) catch false | not))
  elif $op.value then ($op.value | nvalue($t)) as $v | map(select(.value != $v))
  else . end;

def apply($op):
  ($op.type | ntype) as $t
  | if $op.op == "add" then reduce oprecords($op)[] as $r (.; addrec($r))
    elif $op.op == "set" then . as $c | oprecords($op) | map(keepttl($c))
    elif $op.op == "remove" then dropmatch($op; $t)
    elif $op.op == "upsert" then . as $c | dropmatch($op; $t) | reduce oprecords($op)[] as $r (.; addrec($r | keepttl($c)))
    elif $op.op == "delete" then []
    else . end;

def minus($b): ($b | map(id)) as $ids | map(select(id as $i | $ids | index($i) | not));

($types | split(" ")) as $allowed
| ($changes[0] | map(.type = (.type | ntype) | .host = (.host | nhost))) as $ops
| ($cur | map(.host = (.host | nhost) | . as $r | .type as $t | $r + ($r | norm($t)))) as $current

# Per-op validation.
| [ $ops[]
    | if (.op | IN("add", "set", "remove", "upsert", "delete") | not)
        then "unknown op \(.op | tojson) for \(.type) \(.host)"
      elif .type == "AAAA" or .type == "MX"
        then "\(.type) \(.host): cdmon's API cannot write \(.type) records (it answers \"DNS record type not supported\"); change it in the cdmon panel"
      elif (.type | IN($allowed[]) | not)
        then "type \(.type) is not writable by this skill (allowed: \($types))"
      elif (.op | IN("add", "upsert", "set")) and ((.records // .values // [.value // empty]) | length == 0)
        then "\(.op) \(.type) \(.host): no value given (use delete to empty a set)"
      elif .op == "remove" and .value == null and .match == null
        then "remove \(.type) \(.host): needs a \"value\" or a \"match\" regex"
      elif .op == "upsert" and .match == null
        then "upsert \(.type) \(.host): needs a \"match\" regex"
      elif .match != null and ((.match | type) != "string"
                               or (.match as $m | try ("" | test($m) | false) catch true))
        then "\(.op) \(.type) \(.host): invalid match regex \(.match | tojson)"
      elif .type == "CNAME" and .host == "@" and (.op | IN("add", "set", "upsert"))
        then "CNAME at the zone apex is not allowed"
      else empty end ] as $operrors

| ($ops | map({type, host}) | unique) as $keys
| [ $keys[] as $k
    | ($current | map(select(.type == $k.type and .host == $k.host)) | map(del(.type, .host))) as $c
    | (reduce ($ops[] | select(.type == $k.type and .host == $k.host)) as $op ($c; apply($op))
       | map(del(.given))) as $f
    | ($f | minus($c)) as $added
    | ($c | minus($f)) as $removed
    | [ $f[] as $r | $c[] | select(id == ($r | id) and .ttl != $r.ttl) | {from: ., to: $r} ] as $ttl
    | (if ($added + $removed + $ttl | length) == 0 then "noop"
       elif ($removed + $ttl | length) == 0 then "create"
       elif ($c | length) == 1 and ($f | length) == 1 then "edit"
       elif ($f | length) == 0 then "delete"
       else "replace" end) as $strategy
    | { type: $k.type, host: $k.host, strategy: $strategy,
        destructive: ($strategy | IN("edit", "delete", "replace")),
        current: $c, final: $f, added: $added, removed: $removed, ttl_changes: $ttl } ] as $rrsets

# Zone-level checks on the hosts this plan touches.
| [ $rrsets[] | select(.strategy != "noop") | .host ] as $touched
# Every type counts here, not only the writable ones: a CNAME next to an MX,
# AAAA or NS record is just as invalid.
| ([ $current[] | {type, host} ]
   | map(select(. as $x | $rrsets | any(.type == $x.type and .host == $x.host) | not))
   | . + [ $rrsets[] | select(.final | length > 0) | {type, host} ]) as $finalsets
| [ $touched | unique[] as $h
    | ($finalsets | map(select(.host == $h)) | map(.type) | unique) as $ts
    | if ($ts | index("CNAME")) and ($ts | length) > 1
      then "\($h): a CNAME cannot coexist with other records (\($ts | join(", ")))" else empty end ] as $zoneerrors
| [ $rrsets[] | select(.type == "CNAME" and (.final | length) > 1)
    | "\(.host): more than one CNAME value" ] as $cnameerrors
# The API holds one A record per host: create replaces the set instead of
# adding to it. So the API can shrink a set of several A records (made in the
# panel) to one or none, but never leave more than one.
| [ $rrsets[] | select(.type == "A" and .strategy != "noop" and (.final | length) > 1)
    | "A \(.host): would end with \(.final | length) A records, but the API keeps one per host (a second create replaces the first); several A records need the cdmon panel" ] as $aerrors

| ([ $rrsets[] | select(.type == "TXT" and ([.final[] | select(.value | test("^v=spf1"; "i"))] | length) > 1)
     | "TXT \(.host): more than one SPF record makes SPF fail (permerror)" ]
   + [ $rrsets[] | select(.strategy == "replace")
     | "\(.type) \(.host): cdmon cannot change one record of a set, so the set is collapsed to one record and \(.final | length - 1) more are recreated; if a step fails, the backup holds the originals" ]
  ) as $warnings

| { domain: $domain,
    errors: ($operrors + $zoneerrors + $cnameerrors + $aerrors),
    warnings: $warnings,
    summary: { changed: ([$rrsets[] | select(.strategy != "noop")] | length),
               destructive: ([$rrsets[] | select(.destructive)] | length) },
    rrsets: $rrsets }
