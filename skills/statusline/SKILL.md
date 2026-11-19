---
name: statusline
description: >-
  Install or update a two-line statusline (host, zmx session, repo,
  worktree, branch, subdirectory, model and effort, 5h/7d usage with reset
  countdowns, context window) for Claude Code (`claude`), Antigravity CLI
  (`agy`) or Codex CLI (`codex`, native single-row items). Invoke with
  /statusline, optionally naming the harness. Shows a plan and asks before
  writing; never overwrites someone else's statusline without consent. Not for
  designing a new statusline, shell prompts such as starship, or tmux/zmx
  status bars.
disable-model-invocation: true
---

# Statusline

Install the statusline for one harness with `scripts/install.sh`, run by path
from this skill's directory. It needs `sh` and `jq`.

## 1. Pick the harness

- If the user named one (`claude`, `agy`, `codex`), use it.
- Otherwise use the harness you are running in. If you cannot tell, ask; do not
  guess.
- For "all of them", run the steps below once per harness, one plan at a time.

## 2. Plan

Run `scripts/install.sh <harness>` with no flags. It changes nothing and prints
one line per file (`+ create`, `~ update` with a diff, `= unchanged`).

- Output `already up to date`: tell the user and stop.
- Exit 3: a different statusline is already configured. Show the user the
  current value the script printed and ask whether to replace it. Only with an
  explicit yes, continue with `--replace` added in step 3.
- Exit 1: report the error verbatim (e.g. a settings file that is not valid
  JSON) and stop. Never repair a user's settings file by hand to get past it.

Show the plan to the user and ask for confirmation. Do not apply in the same
turn you first show the plan.

## 3. Apply

After a yes, run `scripts/install.sh <harness> --yes` (plus `--replace` if
agreed). Settings files are backed up to `<file>.bak` before being written.
Report what changed and tell the user to restart the harness (or, for Claude
Code, that the statusline refreshes on the next message).

## What each harness gets

| Harness | Files written | Notes |
|---------|---------------|-------|
| `claude` | `~/.claude/statusline-command.sh`, `statusLine` in `~/.claude/settings.json` | Usage and context come from the JSON Claude Code pipes in |
| `agy` | `~/.gemini/statusline-command.sh`, `statusLine` in `~/.gemini/antigravity-cli/settings.json` | Picks the weekly quota bucket for the active model |
| `codex` | `status_line` in the `[tui]` table of `~/.codex/config.toml` | Native items only: one row, no glyphs, no zmx/worktree/subdirectory |

An existing entry that already points at this statusline is left as it is,
extra keys (such as Antigravity's `"enabled": true`) included; only the script
is refreshed. See `README.md` for what each segment shows.

## Upgrading from claude-watch

Old claude-watch installs may still have `~/.claude/fetch-usage.sh` and a
`hooks` block calling it. If the plan's diff or the settings file shows either,
offer to remove them: `rm -f ~/.claude/fetch-usage.sh /tmp/.claude_usage_cache
/tmp/.claude_token_cache`, and drop that hooks entry, with the same
plan-and-confirm step as above.

## Rules

- Never edit the statusline scripts in the user's home directory; change
  `assets/` in this repo and reinstall.
- Optional runtime dependencies (`git`, `zmx`, a Nerd Font) are not installed by
  this skill. Mention a Nerd Font if the user reports boxes instead of icons.
