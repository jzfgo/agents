#!/bin/sh
# install.sh — install or update a statusline for one harness.
#
# Usage: install.sh <claude|agy|codex> [--yes] [--replace]
#
#   (no flags)  plan only: print what would change and touch nothing
#   --yes       apply the plan; settings files are backed up to <file>.bak first
#   --replace   allow overwriting a statusline that is not this one
#
# Exit codes: 0 done or nothing to do, 1 error, 2 usage,
#             3 a different statusline is already configured (rerun with --replace)
#
# Example: install.sh claude && install.sh claude --yes
set -eu

usage() { sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

[ $# -ge 1 ] || usage
harness=$1; shift
yes=0; replace=0
for arg in "$@"; do
  case "$arg" in
    --yes) yes=1 ;;
    --replace) replace=1 ;;
    *) usage ;;
  esac
done

here=$(cd "$(dirname "$0")/.." && pwd)
assets="$here/assets/$harness"
[ -d "$assets" ] || { echo "unknown harness: $harness (expected claude, agy or codex)" >&2; exit 2; }
command -v jq > /dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
changes=0

# plan_file <label> <current file> <proposed file> <show diff: 1|0>
plan_file() {
  if [ ! -e "$2" ]; then
    echo "+ create $1: $2"; changes=$((changes + 1))
  elif cmp -s "$2" "$3"; then
    echo "= unchanged $1: $2"
  else
    echo "~ update $1: $2"; changes=$((changes + 1))
    [ "$4" -eq 1 ] && diff -u "$2" "$3" | sed '1,2d' || true
  fi
}

# write_file <current file> <proposed file> <mode>: back up, then write in place
# so that permissions and symlinks on the current file survive.
write_file() {
  cmp -s "$1" "$2" 2>/dev/null && return 0
  mkdir -p "$(dirname "$1")"
  [ -e "$1" ] && cp -p "$1" "$1.bak"
  cat "$2" > "$1"
  chmod "$3" "$1"
}

conflict() {
  echo "! a different statusline is already configured in $1:" >&2
  printf '%s\n' "$2" | sed 's/^/    /' >&2
  echo "  rerun with --replace to overwrite it (the file is backed up first)" >&2
  exit 3
}

case "$harness" in
  claude|agy)
    if [ "$harness" = claude ]; then
      script="$HOME/.claude/statusline-command.sh"
      settings="$HOME/.claude/settings.json"
      cmd="bash ~/.claude/statusline-command.sh"
    else
      script="$HOME/.gemini/statusline-command.sh"
      settings="$HOME/.gemini/antigravity-cli/settings.json"
      cmd="bash ~/.gemini/statusline-command.sh"
    fi

    if [ -e "$settings" ]; then
      jq -e 'type == "object"' "$settings" > /dev/null 2>&1 \
        || { echo "$settings is not a JSON object; fix it by hand first" >&2; exit 1; }
      cp "$settings" "$tmp/settings.json"
    else
      echo '{}' > "$tmp/settings.json"
    fi

    current=$(jq -r '.statusLine.command // empty' "$tmp/settings.json")
    # Ours whether written with ~ or an absolute path; extra keys such as
    # "enabled" are then kept, since only a missing or foreign entry is rewritten.
    case "$current" in
      *"$script"|*"~/${script#"$HOME"/}") ;;
      "")
        jq --arg c "$cmd" '.statusLine = {type: "command", command: $c}' \
          "$tmp/settings.json" > "$tmp/new.json" ;;
      *)
        [ "$replace" -eq 1 ] || conflict "$settings" "$(jq '.statusLine' "$tmp/settings.json")"
        jq --arg c "$cmd" '.statusLine = {type: "command", command: $c}' \
          "$tmp/settings.json" > "$tmp/new.json" ;;
    esac
    [ -e "$tmp/new.json" ] || cp "$tmp/settings.json" "$tmp/new.json"

    plan_file script "$script" "$assets/statusline-command.sh" 0
    plan_file settings "$settings" "$tmp/new.json" 1

    if [ "$yes" -eq 1 ] && [ "$changes" -gt 0 ]; then
      write_file "$script" "$assets/statusline-command.sh" 755
      write_file "$settings" "$tmp/new.json" 644
    fi
    ;;

  codex)
    config="$HOME/.codex/config.toml"
    [ -e "$config" ] && cp "$config" "$tmp/config.toml" || : > "$tmp/config.toml"
    # The status_line array from the shipped snippet, header line excluded.
    sed -n '/^status_line/,/^]/p' "$assets/config.toml" > "$tmp/snippet"

    # Locate status_line inside the [tui] table only: [tui.model_availability_nux]
    # and other subtables are different tables in TOML.
    awk '
      /^[[:space:]]*\[/ { in_tui = ($0 ~ /^[[:space:]]*\[tui\][[:space:]]*(#.*)?$/) }
      in_tui && /^[[:space:]]*status_line[[:space:]]*=/ { grab = 1 }
      grab { print; if ($0 ~ /\]/) exit }
    ' "$tmp/config.toml" > "$tmp/current"

    items() { grep -o '"[^"]*"' "$1" | tr '\n' ' '; }

    if [ ! -s "$tmp/current" ]; then
      if grep -Eq '^[[:space:]]*\[tui\][[:space:]]*(#.*)?$' "$tmp/config.toml"; then
        awk -v f="$tmp/snippet" '
          { print }
          !done && /^[[:space:]]*\[tui\][[:space:]]*(#.*)?$/ {
            while ((getline line < f) > 0) print line; done = 1 }
        ' "$tmp/config.toml" > "$tmp/new.toml"
      else
        cp "$tmp/config.toml" "$tmp/new.toml"
        [ -s "$tmp/new.toml" ] && printf '\n' >> "$tmp/new.toml"
        { echo '[tui]'; cat "$tmp/snippet"; } >> "$tmp/new.toml"
      fi
    elif [ "$(items "$tmp/current")" = "$(items "$tmp/snippet")" ]; then
      cp "$tmp/config.toml" "$tmp/new.toml"
    else
      [ "$replace" -eq 1 ] || conflict "$config" "$(cat "$tmp/current")"
      awk -v f="$tmp/snippet" '
        /^[[:space:]]*\[/ { in_tui = ($0 ~ /^[[:space:]]*\[tui\][[:space:]]*(#.*)?$/) }
        in_tui && !done && /^[[:space:]]*status_line[[:space:]]*=/ { skip = 1 }
        skip { if ($0 ~ /\]/) { skip = 0; done = 1; while ((getline line < f) > 0) print line } ; next }
        { print }
      ' "$tmp/config.toml" > "$tmp/new.toml"
    fi

    plan_file config "$config" "$tmp/new.toml" 1
    [ "$yes" -eq 1 ] && [ "$changes" -gt 0 ] && write_file "$config" "$tmp/new.toml" 600
    ;;
esac

if [ "$changes" -eq 0 ]; then
  echo "already up to date"
elif [ "$yes" -eq 1 ]; then
  echo "applied $changes change(s); restart the harness to see the statusline"
else
  echo "plan only: rerun with --yes to apply"
fi
