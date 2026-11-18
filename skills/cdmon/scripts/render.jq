# Render a plan (from plan.jq) as a human-readable diff.
#   +  record added        -  record removed
#   ~  TTL change          =  unchanged, but deleted and recreated (replace)
#      (blank) existing record in the set, left untouched

def fqdn($d): if .host == "@" then $d else "\(.host).\($d)" end;
def show($t):
  (if $t == "TXT" then (.value | tojson) else .value end) as $v
  | if .priority != null then "\(.ttl)  \(.priority) \($v)" else "\(.ttl)  \($v)" end;
def headline:
  { noop: "no change", create: "create",
    edit: "edit — OVERWRITES the existing record",
    delete: "delete — REMOVES every record in this set",
    replace: "replace — collapses the whole set and recreates it" }[.strategy];

.domain as $d
| ["Plan for \($d): \(.summary.changed) record set(s) change, \(.summary.destructive) destructive", ""]
  + ([ .rrsets[]
       | .type as $t
       | (.added | map(.value)) as $addv
       | ["  \(.type) \(fqdn($d))  [\(headline)]"]
         + [ .removed[] | "    - \(show($t))" ]
         + [ .ttl_changes[] | "    ~ \(.from | show($t))  ->  ttl \(.to.ttl)" ]
         + (if .strategy == "replace"
              then [ .final[] | select(.value as $v | ($addv | index($v)) | not) | "    = \(show($t))" ]
            elif .strategy == "create"
              then [ .current[] | "      \(show($t))" ]
              else [] end)
         + [ .added[] | "    + \(show($t))" ]
         + (if .strategy == "noop" then [ .final[] | "      \(show($t))" ] else [] end)
         + [""] ]
     | add // [])
  + (if (.warnings | length) > 0 then ["Warnings:"] + (.warnings | map("  ! " + .)) + [""] else [] end)
  + (if (.errors | length) > 0 then ["ERRORS (nothing will be applied):"] + (.errors | map("  x " + .)) + [""] else [] end)
| .[]
