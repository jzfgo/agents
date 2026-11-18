---
name: cdmon
description: >-
  Manage domains and DNS records hosted at cdmon through its Domains and DNS
  API: list the account's domains and all their records, add / change /
  delete A, CNAME and TXT records with a diff-and-confirm step before every
  write, and check propagation with dig. Invoke with /cdmon. Needs
  CDMON_API_KEY. Not for AAAA or MX changes (the API cannot write them), not
  for registering, renewing or transferring domains, not for nameserver or
  DNSSEC changes, and not for DNS hosted anywhere other than cdmon.
disable-model-invocation: true
---

# cdmon DNS

Manage DNS zones hosted at cdmon with the scripts in `scripts/`. They need
`bash`, `curl`, `jq` and, for propagation, `dig`. Run them by path from this
skill's directory; every script prints its usage and an example in its header.

## Secrets

- Read the key only from `CDMON_API_KEY`. If it is unset, stop and ask the user
  to export it; do not look for it in files unless the user tells you where it
  is, and then load it into the environment without printing it
  (`set -a; . path/.env >/dev/null; set +a`).
- Never print, echo, log, paste or interpolate the key into a command line.
  Never run the scripts with `bash -x` or `set -x`. The scripts pass the key to
  curl through a process-substitution header, and redact it from error bodies;
  do not bypass them with hand-written curl calls that put it in argv.

## The cdmon model you must keep in mind

cdmon addresses records by **(host, type)**, not by record. Verified against
the live API:

- The API writes only **A, CNAME and TXT**. AAAA and MX are listed but
  `create` answers `DNS record type not supported`; NS and SOA are never
  written. For AAAA or MX changes, tell the user to use the cdmon panel, and
  offer `propagation.sh` to check the result afterwards.
- TXT: `create` **adds** to the set; exact duplicates are rejected
  (`TXT record already exists`).
- A: `create` **replaces** the set — the API holds one A record per host. A
  host with several A records (made in the panel) can
  be shrunk to one or deleted, never kept at several. `plan.sh` refuses
  anything that would need more than one.
- `dnsrecords/edit` and `dnsrecords/delete` act on the **whole set** sharing
  host and type, and ignore the value. Editing one of three TXT records at `@`
  collapses all three into one; deleting one deletes all three.

So never call `edit` or `delete` yourself. Express what you want as ops in a
changes file and let `plan.sh` / `apply.sh` decide: they compute the final set
and, when a set has several records and only some change, rebuild it (the plan
says so as `replace`): one `edit` collapses the set to its first final record —
so the name is never left empty — and `create` adds back the rest. If a later
create fails, the siblings not yet recreated are missing until restored from
the backup; that is why every `replace` needs explicit approval.

Hosts are relative to the zone: `@` is the apex, `www`, `send`, `_dmarc`.

## Read

```sh
scripts/domains.sh                       # domains, expiry, auto-renew, nameservers
scripts/records.sh example.com           # all records
scripts/records.sh example.com --type TXT --host @
scripts/records.sh example.com --json    # for further processing
```

`domains.sh` never shows registrant contacts; do not fetch them unless asked.

## Change records — always in this order

1. **Show the current state.** Run `records.sh` for the domain (filtered to the
   hosts involved) and show it to the user.
2. **Write a changes file** — a JSON array of ops, in a scratch location, not in
   the user's project:

   ```json
   [
     {"op": "add",    "type": "A",     "host": "app", "value": "192.0.2.10", "ttl": 900},
     {"op": "add",    "type": "CNAME", "host": "www", "value": "example.com"},
     {"op": "add",    "type": "TXT",   "host": "@",   "value": "site-verification=abc"},
     {"op": "set",    "type": "A",     "host": "@",   "values": ["192.0.2.1"]},
     {"op": "upsert", "type": "TXT",   "host": "@",   "match": "^v=spf1", "value": "v=spf1 include:_spf.example.net ~all"},
     {"op": "remove", "type": "TXT",   "host": "@",   "value": "old-verification=xyz"},
     {"op": "delete", "type": "CNAME", "host": "old"}
   ]
   ```

   | op | meaning |
   |---|---|
   | `add` | add a record to the set; no-op if it is already there |
   | `set` | the set becomes exactly these values (`values`, or `records` with per-record `ttl`) |
   | `upsert` | drop the values matching the `match` regex, then add `value` — for "the one SPF record" |
   | `remove` | drop one value, keep the rest |
   | `delete` | remove the whole set |

   `ttl` defaults to 900. Use `add` unless the user asked to replace or remove
   something. For A, `add` on a host that already has an A record is an error:
   say so and offer `set` (which replaces it, and is destructive).
3. **Show the diff.** Run `plan.sh DOMAIN changes.json` and show its output to
   the user verbatim. It marks `+` added, `-` removed, `~` TTL change, `=`
   kept but rebuilt, and labels each set `create`, `edit`, `delete` or
   `replace`. It also prints warnings (two SPF records, a replace) and errors
   (AAAA or MX, more than one A per host, CNAME next to other records).
   If there are errors, fix the changes file; nothing can be applied.
4. **Get confirmation.**
   - Only additions (`create`): ask "apply?" and wait for a yes.
   - Anything `edit`, `delete` or `replace`: name each existing record that will
     be overwritten or removed, and ask for explicit approval of exactly those.
     A general "go ahead" given earlier, before the user saw this diff, does not
     count.
5. **Apply.** `apply.sh DOMAIN changes.json --yes`, adding `--allow-destructive`
   only after the approval in step 4. It re-reads the live zone, re-plans (so a
   stale diff cannot be applied), saves a backup of the zone to `~/.cdmon/backups/`
   and refuses to write unless it reads back identical, runs the calls, and then
   verifies that re-planning against the live zone comes back empty. Before a
   `replace` at `@` or any other set with several records, confirm the
   "Backup … (verified)" line appeared and report its path. If it stops
   part-way, it prints the affected set as it was before the run: show that to
   the user, offer an `add`-op changes file to restore the missing records, and
   do not retry blindly.
6. **Check propagation** for each changed name (below).

Never pass `--yes` to `apply.sh` in the same turn you first show the diff.

## Propagation

```sh
scripts/propagation.sh example.com www CNAME example.com
scripts/propagation.sh example.com _dmarc TXT v=DMARC1
```

It queries the zone's authoritative nameservers and 1.1.1.1, 8.8.8.8 and
9.9.9.9, and only counts answers whose owner and type match — a wildcard CNAME
answering a TXT query shows as `missing`, not as a false `ok`. Authoritative
servers update within a minute or two; public resolvers can keep the old answer
for the previous TTL. If authoritative is `ok` and resolvers are not, tell the
user it is caching and how long the old TTL was; do not change anything.

## When something fails

- Errors come back as `cdmon: <endpoint>: HTTP <code>: <message>`. Common ones
  are in [references/api.md](references/api.md#errors).
- The API allows 3 requests per second and 10,000 per day; the scripts pace
  themselves. Do not loop over domains in parallel.
- If a response does not match what the scripts expect, check the OpenAPI spec:
  `https://api-domains-docs.cdmon.com/openapi/reseller-tool/en/openapi.yaml`
  (human docs: <https://api-domains-docs.cdmon.com/en/description/introduction>).
  [references/api.md](references/api.md) lists which behaviours were verified
  against the live API and which only come from the spec.
