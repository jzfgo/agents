#!/bin/sh
input=$(cat)

# --- icons ---
# Written as \NNN octal UTF-8 escapes, never as literal glyphs: most of these live
# in the Private Use Area (U+E000-U+F8FF) and get silently stripped by editors,
# linters and anything that sanitises unknown codepoints. Octal (not \xHH) because
# only octal is POSIX: dash — /bin/sh on Debian and Ubuntu — prints "\xe2\xa7\x97"
# literally, so hex escapes would show as raw text on the platforms we support.
ICON_ZMX=$(printf '\342\247\227')          # U+29D7  matches [env_var.ZMX_SESSION] in starship.toml
ICON_GIT=$(printf '\363\260\212\242')      # U+F02A2 nf-md-git
ICON_SVN=$(printf '\356\242\265')          # U+E8B5  nf-dev-subversion
# Nerd Fonts ships logos for git and subversion only — there is no mercurial,
# fossil, jujutsu or bazaar glyph in the set, so those share a generic marker.
ICON_SCM=$(printf '\363\260\263\217')      # U+F0CCF nf-md-source_repository
ICON_FOLDER=$(printf '\363\260\211\213')   # U+F024B nf-md-folder
ICON_WORKTREE=$(printf '\363\260\231\205') # U+F0645 nf-md-file_tree
ICON_BRANCH=$(printf '\356\202\240')       # U+E0A0  matches [git_branch].symbol in starship.toml

# --- platform icon + hostname ---
os_type=$(uname -s 2>/dev/null)
case "$os_type" in
  Darwin)  platform_icon=$(printf '\357\205\271') ;;   # U+F179 nf-fa-apple
  Linux)
    if [ -f "/system/build.prop" ] || [ -n "$ANDROID_ROOT" ]; then
      platform_icon=$(printf '\357\205\273')            # U+F17B nf-fa-android
    else
      platform_icon=$(printf '\357\205\274')            # U+F17C nf-fa-linux
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*) platform_icon=$(printf '\357\205\272') ;;  # U+F17A nf-fa-windows
  *)                     platform_icon=$(printf '\357\204\211') ;;  # U+F109 nf-fa-laptop
esac
host_name=$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo "unknown")

# --- zmx session (only when zmx is installed *and* we are inside a session) ---
zmx_session=""
if command -v zmx > /dev/null 2>&1 && [ -n "$ZMX_SESSION" ]; then
  zmx_session="$ZMX_SESSION"
fi

# --- model + reasoning effort ---
# Antigravity provides .model.effort (e.g. "medium") and sometimes appends "(Medium)"
# to .model.display_name (e.g. "Gemini 4 Argon (Medium)"). Strip any trailing
# parenthetical effort or "(1M context)" from the display name and rebuild a unified
# dim suffix like "(1M medium)" so it matches claude-watch's layout.
model=$(echo "$input" | jq -r '.model.display_name // .model.name // .model.id // ""')
effort=$(echo "$input" | jq -r '.model.effort // .effort.level // ""')
ctx_total=$(echo "$input" | jq -r '.context_window.context_window_size // .context.context_window_size // empty' 2>/dev/null)

model_suffix=""
case "$model" in
  *"(1M context)"*)
    model=$(printf '%s' "$model" | sed 's/ *(1M context)//')
    model_suffix="1M"
    ;;
esac

# Strip trailing "(Low)", "(Medium)", "(High)", "(Max)" from display_name when effort is present
model=$(printf '%s' "$model" | sed -E 's/ *\((Low|Medium|High|Max|low|medium|high|max)\)$//')

if [ -z "$model_suffix" ] && [ -n "$ctx_total" ] && [ "$ctx_total" -ge 1000000 ] 2>/dev/null; then
  model_suffix="1M"
fi
[ -n "$effort" ] && model_suffix="${model_suffix:+$model_suffix }$effort"

# --- leading segment: the repo, or a plain directory when outside one ---
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir_name=$(basename "$dir")
dir_icon="$ICON_FOLDER"
subdir=""

# --- git branch + worktree name ---
branch=""
worktree_name=""
if git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
  dir_icon="$ICON_GIT"

  prefix=$(git -C "$dir" rev-parse --show-prefix 2>/dev/null)
  [ -n "$prefix" ] && subdir=$(basename "$prefix")

  branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null)

  current_worktree=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)

  if [ -n "$current_worktree" ]; then
    main_worktree=$(git -C "$dir" worktree list --porcelain 2>/dev/null | awk '/^worktree / { sub(/^worktree /, ""); print; exit }')

    if [ -n "$main_worktree" ]; then
      main_basename=$(basename "$main_worktree")
      current_basename=$(basename "$current_worktree")

      dir_name="$main_basename"

      if [ "$current_worktree" = "$main_worktree" ]; then
        worktree_name="main"
      else
        suffix="${current_basename#"${main_basename}."}"
        if [ "$suffix" != "$current_basename" ]; then
          worktree_name="$suffix"
        else
          worktree_name="$current_basename"
        fi
      fi
    fi
  fi
else
  # --- other SCMs: walk up for a marker directory, innermost wins ---
  probe="$dir"
  scm=""
  while [ -n "$probe" ] && [ "$probe" != "/" ] && [ "$probe" != "." ] && [ -z "$scm" ]; do
    if [ -d "$probe/.hg" ]; then
      scm="hg"
    elif [ -d "$probe/.svn" ]; then
      scm="svn"
    elif [ -d "$probe/.jj" ]; then
      scm="jj"
    elif [ -e "$probe/.fslckout" ] || [ -e "$probe/_FOSSIL_" ]; then
      scm="fossil"
    elif [ -d "$probe/.bzr" ]; then
      scm="bzr"
    else
      probe=$(dirname "$probe")
    fi
  done

  if [ -n "$scm" ]; then
    dir_name=$(basename "$probe")
    case "$scm" in
      svn) dir_icon="$ICON_SVN" ;;
      *) dir_icon="$ICON_SCM" ;;
    esac
    rel="${dir#"$probe"}"
    [ -n "$rel" ] && [ "$rel" != "$dir" ] && subdir=$(basename "$rel")
  fi
fi

# --- usage stats (5h / 7d) ---
# Antigravity hands quota buckets over on stdin under `.quota`:
#   - `gemini-5h` (or `3p-5h` for 3P models like Claude/GPT) for the 5h window
#   - For the weekly window (`7d`), if the selected model has its own dedicated
#     WTU weekly bucket (`gemini-argon-wtu-weekly`, `gemini-carbon-wtu-weekly`),
#     show that bucket; otherwise fall back to `gemini-weekly` / `3p-weekly`.
model_lc=$(printf '%s' "$model" | tr '[:upper:]' '[:lower:]')
case "$model_lc" in
  *claude*|*gpt*|*sonnet*|*opus*|*haiku*|*o1*|*o3*)
    five_h_key="3p-5h"
    weekly_key="3p-weekly"
    ;;
  *argon*)
    five_h_key="gemini-5h"
    weekly_key="gemini-argon-wtu-weekly"
    ;;
  *carbon*)
    five_h_key="gemini-5h"
    weekly_key="gemini-carbon-wtu-weekly"
    ;;
  *)
    five_h_key="gemini-5h"
    weekly_key="gemini-weekly"
    ;;
esac

# Fall back to gemini-weekly if the model-specific WTU bucket is absent in .quota
if [ "$(echo "$input" | jq -r --arg k "$weekly_key" '.quota[$k] // empty')" = "" ]; then
  weekly_key="gemini-weekly"
fi

five_h=$(echo "$input" | jq -r --arg k "$five_h_key" '(.quota[$k].remaining_fraction // empty) | ((1 - .) * 100) | round | if . < 0 then 0 elif . > 100 then 100 else . end')
five_h_sec=$(echo "$input" | jq -r --arg k "$five_h_key" '(.quota[$k].reset_in_seconds // empty) | floor')

seven_d=$(echo "$input" | jq -r --arg k "$weekly_key" '(.quota[$k].remaining_fraction // empty) | ((1 - .) * 100) | round | if . < 0 then 0 elif . > 100 then 100 else . end')
seven_d_sec=$(echo "$input" | jq -r --arg k "$weekly_key" '(.quota[$k].reset_in_seconds // empty) | floor')

# --- format_duration: given seconds until reset, returns human-readable countdown ---
format_duration() {
  diff="$1"
  case "$diff" in
    ''|*[!0-9-]*) return ;;
  esac
  if [ "$diff" -le 0 ]; then echo "now"; return; fi
  days=$(( diff / 86400 ))
  hours=$(( (diff % 86400) / 3600 ))
  minutes=$(( (diff % 3600) / 60 ))
  if [ "$days" -gt 0 ]; then
    echo "${days}d ${hours}h"
  elif [ "$hours" -gt 0 ]; then
    echo "${hours}h ${minutes}m"
  else
    echo "${minutes}m"
  fi
}

# --- context window ---
used=$(echo "$input" | jq -r '(.context_window.used_percentage // .context.used_percentage // empty) | round')
ctx_str=""
ctx_tokens_str=""
if [ -n "$used" ]; then
  ctx_str="${used}%"
  ctx_used=$(echo "$input" | jq -r '(.context_window.current_usage.cache_read_input_tokens + .context_window.current_usage.cache_creation_input_tokens + .context_window.current_usage.input_tokens + .context_window.current_usage.output_tokens) // (.context.current_usage.input_tokens + .context.current_usage.output_tokens) // empty' 2>/dev/null)
  if [ -n "$ctx_used" ] && [ -n "$ctx_total" ]; then
    ctx_used_k=$(( ctx_used / 1000 ))
    ctx_total_k=$(( ctx_total / 1000 ))
    ctx_tokens_str="${ctx_used_k}k/${ctx_total_k}k"
  fi
fi

# --- assemble output ---
# Uses the terminal's 16 ANSI colors so the statusline adapts automatically
# when the terminal switches between light and dark themes:
#   90 = bright black (muted grey)
#   33 = yellow
#   34 = blue / purple
#   35 = magenta
#   36 = cyan
SEP="\033[2m\033[90m • \033[0m"
BAR="\033[2m\033[90m | \033[0m"

# line 1:  host [• zmx]  |  repo [• worktree] [• branch] [• subdir]
printf "%s " "$platform_icon"
printf "\033[90m%s\033[0m" "$host_name"
if [ -n "$zmx_session" ]; then
  printf "%b" "$SEP"
  printf "\033[35m%s %s\033[0m" "$ICON_ZMX" "$zmx_session"
fi
if [ -n "$dir_name" ]; then
  printf "%b" "$BAR"
  printf "\033[1m\033[36m%s %s\033[22m\033[0m" "$dir_icon" "$dir_name"
fi
if [ -n "$worktree_name" ]; then
  printf "%b" "$SEP"
  printf "\033[1m\033[33m%s %s\033[22m\033[0m" "$ICON_WORKTREE" "$worktree_name"
fi
if [ -n "$branch" ] && [ "$branch" != "$worktree_name" ]; then
  printf "%b" "$SEP"
  printf "\033[1m\033[35m%s %s\033[22m\033[0m" "$ICON_BRANCH" "$branch"
fi
if [ -n "$subdir" ]; then
  printf "%b" "$SEP"
  printf "\033[1m\033[36m%s %s\033[22m\033[0m" "$ICON_FOLDER" "$subdir"
fi

# line 2: model | usage (5h • 7d) | ctx
printf "\n"
line2_empty=1
usage_started=0

if [ -n "$model" ]; then
  printf "\033[34m\033[1m%s\033[22m\033[0m" "$model"
  [ -n "$model_suffix" ] && printf " \033[2m\033[90m(%s)\033[0m" "$model_suffix"
  line2_empty=0
fi
if [ -n "$five_h" ]; then
  [ "$line2_empty" -eq 0 ] && printf "%b" "$BAR"
  printf "\033[90m5h %s%%\033[0m" "$five_h"
  if [ -n "$five_h_sec" ]; then
    delta=$(format_duration "$five_h_sec")
    [ -n "$delta" ] && printf " \033[2m\033[90m(%s)\033[0m" "$delta"
  fi
  line2_empty=0
  usage_started=1
fi
if [ -n "$seven_d" ]; then
  if [ "$usage_started" -eq 1 ]; then
    printf "%b" "$SEP"
  elif [ "$line2_empty" -eq 0 ]; then
    printf "%b" "$BAR"
  fi
  printf "\033[90m7d %s%%\033[0m" "$seven_d"
  if [ -n "$seven_d_sec" ]; then
    delta=$(format_duration "$seven_d_sec")
    [ -n "$delta" ] && printf " \033[2m\033[90m(%s)\033[0m" "$delta"
  fi
  line2_empty=0
  usage_started=1
fi
if [ -n "$ctx_str" ]; then
  [ "$line2_empty" -eq 0 ] && printf "%b" "$BAR"
  printf "\033[90mctx %s\033[0m" "$ctx_str"
  [ -n "$ctx_tokens_str" ] && printf " \033[2m\033[90m(%s)\033[0m" "$ctx_tokens_str"
  line2_empty=0
fi
