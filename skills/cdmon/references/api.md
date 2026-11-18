# cdmon Domains and DNS API — reference

- OpenAPI spec (source of truth): <https://api-domains-docs.cdmon.com/openapi/reseller-tool/en/openapi.yaml>
  (also `/es/` and `/ca/`). The docs site is a Scalar page that loads it via
  `/configuration.json`.
- Base URL: `https://api-domains.cdmon.services/api-domains`
- Auth: header `apikey: <key>`. The key is created in the cdmon panel under
  *User and security → API Key management*.
- Every endpoint is `POST` with a JSON body `{"data": {...}}`.
- Limits: 3 requests/second, 10,000 requests/day.

## Endpoints this skill uses

| endpoint | body `data` | notes |
|---|---|---|
| `domains/list` | `{extended_info: 1}` | with 1: `dns_zones` (nameservers), dates, `autorenew`, and registrant **contacts** (personal data — drop them) |
| `getDnsRecords` | `{domain}` | `result[]` of `{type, host, ttl, value, priority?}`; `priority` is a string; includes SOA (`host: "-"`) and NS |
| `dnsrecords/create` | `{domain, type, host, ttl, destination \| value}` | TXT: adds to the set; A: replaces the set; AAAA, MX: not supported |
| `dnsrecords/edit` | `{domain, current: {host, type}, new: {destination \| value, ttl}}` | replaces the **whole (host, type) set** with one record |
| `dnsrecords/delete` | `{domain, host, type}` | deletes the **whole (host, type) set** |
| `status` | `{action: "getdnsrecords"}` | is an endpoint up (maintenance) |

Out of scope here, but in the spec: `info`, `dns` (nameservers), `dnssec`,
`dnskey/add`, `block`, `whoisprivate`, `autorenewal`, `balance`, and the paid
ones — `create`, `renew`, `transfer`, `restore`.

## Verified against the live API (2026-11-18)

- `create` TXT with `value` adds to the set; a second TXT with another value
  at the same host coexists; an exact duplicate fails with
  `TXT record already exists` (HTTP 500).
- `edit` with `current: {host, type, value}` on a set of two TXT records left
  **one** record (the new one): the value in `current` is ignored and the set
  collapses. `new.value` and `new.ttl` are applied.
- `delete` with `{host, type, value}` on a set of two deleted **both**.
- So a `replace` is built as one `edit` (atomic: the set becomes one record)
  followed by `create` for the others, never `delete` + `create`, which would
  leave the name empty in between.
- Listing right after a write reflects it; authoritative nameservers answered
  within seconds.
- Wrong or missing key: HTTP 401 from the gateway,
  `{"message": "Unauthorized" | "No API key found in request", "request_id"}`.
  The key is not echoed.

## Write support by type (verified 2026-11-18, on a throwaway host)

| type | create | edit | value field |
|---|---|---|---|
| TXT | adds to the set | collapses the set to one | `value` |
| A | **replaces** the set (one A per host) | collapses the set to one | `destination` (`value` → `Destination to redirect not valid`) |
| CNAME | creates | replaces | `destination` |
| AAAA | `DNS record type not supported` with `destination`, `value`, or both, any case | — | — |
| MX | `DNS record type not supported` with `destination` or `value`, with `priority` | — | — |

`delete` removed the whole set for A, TXT and CNAME. The spec only shows
create examples for A, CNAME and TXT, which matches. If cdmon adds types, the
error will change: try one create on a throwaway host, update this table and
`CDMON_TYPES` in `scripts/_lib.sh`.

## Errors

API errors: `{"status": "ko", "data": "<message>"}`, usually HTTP 500 (the
spec also lists 403). Gateway errors: HTTP 401 as above.

| message | meaning |
|---|---|
| `No API key found in request` | header missing — `CDMON_API_KEY` empty |
| `Unauthorized` / `Invalid authentication credentials` | wrong key |
| `You cannot consume this service` | endpoint under maintenance; check `status` |
| `The domain '<d>' is NOT registered in CDmon.` | typo, or a domain in another account |
| `Specified user is not the domain owner` | the key belongs to another account |
| `Parameter 'domain' not defined in the request` | malformed body |
| `TXT record already exists` | exact duplicate on create |
| `DNS record type not supported` | AAAA, MX (and anything other than A, CNAME, TXT) |
| `Destination to redirect not valid` | A/CNAME sent with `value` instead of `destination`, or a bad target |
| `DOMAIN BLOCKED` | the domain is locked in the panel |
