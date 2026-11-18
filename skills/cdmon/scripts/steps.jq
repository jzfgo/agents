# Turn a plan (from plan.jq) into the ordered list of cdmon API calls.
# TXT carries its content in "value"; every other type uses "destination"
# (cdmon's naming; see the OpenAPI spec). edit and delete address the whole
# (host, type) set, so "replace" (only reachable for TXT; plan.jq keeps A and
# CNAME sets to one record) is: edit (collapses the set to its first final
# record in one call, so the name is never empty), then create the rest.
# Labels are progress lines; a DKIM key would make each one ~400 characters.
def short: if length > 60 then .[:57] + "..." else . end;
def field($t): if $t == "TXT" then "value" else "destination" end;
def rec($d; $t; $h): {domain: $d, type: $t, host: $h, ttl: .ttl, (field($t)): .value};

.domain as $d
| [ .rrsets[] | select(.strategy != "noop") | .type as $t | .host as $h
    | if .strategy == "create" then .added[] | {endpoint: "dnsrecords/create", data: rec($d; $t; $h)}
      elif .strategy == "edit" then
        .final[0] | {endpoint: "dnsrecords/edit",
                     data: {domain: $d, current: {host: $h, type: $t},
                            new: {ttl: .ttl, (field($t)): .value}}}
      elif .strategy == "delete" then {endpoint: "dnsrecords/delete", data: {domain: $d, host: $h, type: $t}}
      else (.final[0] | {endpoint: "dnsrecords/edit",
                         data: {domain: $d, current: {host: $h, type: $t},
                                new: {ttl: .ttl, (field($t)): .value}}}),
           (.final[1:][] | {endpoint: "dnsrecords/create", data: rec($d; $t; $h)})
      end
    | . + {label: "\(.endpoint | ltrimstr("dnsrecords/")) \($t) \($h) \(.data | .value // .destination // .new.value // .new.destination // "(whole set)" | short)"} ]
