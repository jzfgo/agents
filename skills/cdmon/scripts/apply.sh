#!/usr/bin/env bash
# Apply a changes file to a domain. Re-reads the live zone, prints the plan,
# and only writes when told to.
#   apply.sh DOMAIN CHANGES.json                         dry run: plan only (exit 3)
#   apply.sh DOMAIN CHANGES.json --yes                   apply additions only
#   apply.sh DOMAIN CHANGES.json --yes --allow-destructive
#                                                        also edit / delete / replace
# Before writing, the current zone is saved to $CDMON_BACKUP_DIR
# (default ~/.cdmon/backups). After writing, the plan is recomputed against the
# live zone and must come back empty.
# Exit: 0 applied and verified, 1 API/verify failure, 2 plan errors,
#       3 dry run, 4 destructive change without --allow-destructive.
# Example: ./apply.sh example.com changes.json --yes
. "$(dirname "$0")/_lib.sh"

[ $# -ge 2 ] || cdmon_die "usage: apply.sh DOMAIN CHANGES.json [--yes] [--allow-destructive]"
domain="$1" changes="$2"; shift 2
yes=0 destructive_ok=0
for a in "$@"; do
  case "$a" in
    --yes) yes=1 ;;
    --allow-destructive) destructive_ok=1 ;;
    *) cdmon_die "unknown argument: $a" ;;
  esac
done

current="$(cdmon_records "$domain")"
plan="$(cdmon_plan "$domain" "$current" "$changes")"
cdmon_render <<<"$plan"

jq -e '.errors | length == 0' >/dev/null <<<"$plan" || exit 2
if jq -e '.summary.changed == 0' >/dev/null <<<"$plan"; then
  echo "Nothing to do."
  exit 0
fi
if [ "$yes" != 1 ]; then
  echo "Dry run. Re-run with --yes to apply."
  exit 3
fi
if jq -e '.summary.destructive > 0' >/dev/null <<<"$plan" && [ "$destructive_ok" != 1 ]; then
  echo "This plan overwrites or deletes existing records. Re-run with --yes --allow-destructive" \
       "once the user has explicitly approved those changes." >&2
  exit 4
fi

backup_dir="${CDMON_BACKUP_DIR:-$HOME/.cdmon/backups}"
mkdir -p "$backup_dir"
backup="$backup_dir/$domain-$(date +%Y%m%dT%H%M%S).json"
jq . <<<"$current" >"$backup"
# Do not write anything unless the backup reads back identical to the zone.
if ! jq -e --argjson cur "$current" '. == $cur' "$backup" >/dev/null 2>&1; then
  cdmon_die "backup could not be verified at $backup; nothing was changed"
fi
echo "Backup of the current zone (verified, $(jq length "$backup") records): $backup"

steps="$(jq -c -f "$CDMON_LIB_DIR/steps.jq" <<<"$plan")"

total="$(jq length <<<"$steps")"
i=0
while [ "$i" -lt "$total" ]; do
  step="$(jq -c ".[$i]" <<<"$steps")"
  label="$(jq -r .label <<<"$step")"
  if cdmon_call "$(jq -r .endpoint <<<"$step")" "$(jq -c '{data: .data}' <<<"$step")" >/dev/null; then
    echo "  ok  $label"
  else
    echo "FAILED at step $((i + 1))/$total: $label" >&2
    echo "Steps not run:" >&2
    jq -r ".[$((i + 1)):][] | \"  \" + .label" <<<"$steps" >&2
    echo "The zone may be half-changed. Records of the affected set before this run:" >&2
    jq -r --argjson s "$step" '.[] | select(.type == $s.data.type and .host == ($s.data.host // $s.data.current.host))
      | "  \(.type) \(.host) \(.ttl) \(.priority // "") \(.value)"' "$backup" >&2
    echo "Full backup: $backup. Restore them with an add-op changes file; do not retry blindly." >&2
    echo "Live zone vs. the intended result now:" >&2
    if live="$(cdmon_records "$domain")"; then
      cdmon_plan "$domain" "$live" "$changes" | cdmon_render >&2 || true
    fi
    exit 1
  fi
  i=$((i + 1))
done

live="$(cdmon_records "$domain")" || cdmon_die "applied, but the zone could not be re-read to verify it"
after="$(cdmon_plan "$domain" "$live" "$changes")"
if jq -e '.summary.changed == 0' >/dev/null <<<"$after"; then
  echo "Applied and verified: the live zone matches the plan."
else
  echo "Applied, but the live zone does not match yet. Remaining differences:" >&2
  cdmon_render <<<"$after" >&2
  exit 1
fi
