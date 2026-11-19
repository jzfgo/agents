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
# Both reads go through jq's "//" alternative: .effort is absent on models that
# have no reasoning parameter, and jq -r renders a missing key as the literal
# string "null", which would otherwise land in the statusline verbatim.
model=$(echo "$input" | jq -r '.model.display_name // ""')
effort=$(echo "$input" | jq -r '.effort.level // ""')

# The suffix stays separate from $model so the two can carry different SGR
# attributes — bold orange for the name, dim grey for the parenthetical, the same
# split the ctx and reset-delta segments use. Concatenating loses that seam.
# "(1M context)" is a context-size marker rather than part of the name, so it
# moves into the suffix instead of leaving two parentheticals side by side.
model_suffix=""
case "$model" in
  *"(1M context)"*)
    # printf '%s', not echo: this is a /bin/sh script, and dash's echo expands
    # backslash escapes in its argument, so a display name is not safe to echo.
    model=$(printf '%s' "$model" | sed 's/ *(1M context)//')
    model_suffix="1M"
    ;;
esac
[ -n "$effort" ] && model_suffix="${model_suffix:+$model_suffix }$effort"

# --- leading segment: the repo, or a plain directory when outside one ---
# Name and icon start as the plain-directory case; whichever SCM block matches
# below swaps in the project name and that SCM's glyph. Keeping the folder glyph
# here is what lets it mean "subdirectory" in the trailing segment.
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir_name=$(basename "$dir")
dir_icon="$ICON_FOLDER"
subdir=""

# --- git branch + worktree name ---
branch=""
worktree_name=""
if git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
  dir_icon="$ICON_GIT"

  # Path from the worktree root to the cwd, with a trailing slash and empty at the
  # root — so "are we in a subdirectory" needs no path arithmetic, and git has
  # already resolved symlinks that a manual prefix strip would trip over.
  prefix=$(git -C "$dir" rev-parse --show-prefix 2>/dev/null)
  [ -n "$prefix" ] && subdir=$(basename "$prefix")

  branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null)

  # Resolve the canonical path of the current worktree dir
  current_worktree=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)

  if [ -n "$current_worktree" ]; then
    # Find the main worktree path (always listed first by git worktree list)
    # sub() rather than $2 so a repo path containing spaces is not truncated
    main_worktree=$(git -C "$dir" worktree list --porcelain 2>/dev/null | awk '/^worktree / { sub(/^worktree /, ""); print; exit }')

    if [ -n "$main_worktree" ]; then
      main_basename=$(basename "$main_worktree")
      current_basename=$(basename "$current_worktree")

      # The folder segment names the *project*, never the cwd. Inside a worktree
      # the cwd basename is the worktree name, which would duplicate the next
      # segment and hide which repo we are actually in.
      dir_name="$main_basename"

      if [ "$current_worktree" = "$main_worktree" ]; then
        # We are on the main worktree — name it "main"
        worktree_name="main"
      else
        # Strip the main repo basename prefix and the leading dot/separator
        # e.g. "carroquesi.feat-list-route" → "feat-list-route"
        # Inner quotes keep glob characters in the repo name literal
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
  # Detection is a filesystem test rather than a call to each tool, so it costs one
  # stat per level and works even when the SCM itself is not installed. Only the
  # repo name and subdirectory are derived here; branch and worktree stay git-only.
  probe="$dir"
  scm=""
  # "." terminates too: dirname "." is "." forever, so a relative cwd would spin here.
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
    # Same trailing-segment rule as git, minus git's symlink normalisation: empty
    # when the cwd *is* the repo root, otherwise the innermost component.
    rel="${dir#"$probe"}"
    [ -n "$rel" ] && [ "$rel" != "$dir" ] && subdir=$(basename "$rel")
  fi
fi

# --- usage stats (5h / 7d) ---
# Claude Code hands these over on stdin, so there is no token, no HTTP call and
# no cache file to keep warm. The whole rate_limits object is absent until the
# session's first API response, and each window can go missing independently, so
# every read is guarded with "// empty" and every segment below stays optional.
# The percentages are documented as 0-100 and not necessarily whole, so they are
# rounded — in jq, never with printf "%.0f". printf's float parsing honours
# LC_NUMERIC: under a comma-decimal locale (es_ES, de_DE, fr_FR...) bash's printf
# rejects "12.6", writes "invalid number" to stderr and yields 12 instead of 13.
# jq always parses and prints JSON numbers with a decimal point, locale or not.
# "// empty" comes first so a missing window stays empty rather than rounding null.
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty | round')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty | round')
# floor, not round: resets_at is documented as Unix epoch seconds, but a fractional
# value would otherwise reach compute_delta's digits-only guard and silently drop
# the countdown.
five_h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty | floor')
seven_d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty | floor')

# --- compute_delta: given Unix epoch seconds, returns human-readable time until reset ---
# resets_at arrives as an integer, which is why there is no date parsing here and
# no BSD-vs-GNU branch: only arithmetic, identical on every platform.
compute_delta() {
  reset_epoch="$1"
  # Anything non-numeric would make the $(( )) below a syntax error rather than a
  # bad result, so reject it up front instead of writing to stderr mid-render.
  case "$reset_epoch" in
    ''|*[!0-9]*) return ;;
  esac
  now_epoch=$(date -u "+%s")
  diff=$(( reset_epoch - now_epoch ))
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
# Rounded in jq for the same locale reason as the usage percentages above.
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty | round')
ctx_str=""
ctx_tokens_str=""
if [ -n "$used" ]; then
  ctx_str="${used}%"
  ctx_used=$(echo "$input" | jq -r '(.context_window.current_usage.cache_read_input_tokens + .context_window.current_usage.cache_creation_input_tokens + .context_window.current_usage.input_tokens + .context_window.current_usage.output_tokens) // empty' 2>/dev/null)
  ctx_total=$(echo "$input" | jq -r '.context_window.context_window_size // empty' 2>/dev/null)
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
#   35 = magenta
#   36 = cyan
SEP="\033[2m\033[90m • \033[0m"
BAR="\033[2m\033[90m | \033[0m"

# line 1:  host [• zmx]  |  repo [• worktree] [• branch] [• subdir]
# Segments run outermost to innermost, and every optional one sits at the tail, so
# the leading "repo • worktree" keeps the same shape and the line only grows right.
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
# Every segment is optional, so track whether anything has been emitted yet
# instead of hardcoding separators — otherwise a missing cache or model leaves
# a dangling " | " at the start of the line.
printf "\n"
line2_empty=1
usage_started=0

if [ -n "$model" ]; then
  printf "\033[33m\033[1m%s\033[22m\033[0m" "$model"
  [ -n "$model_suffix" ] && printf " \033[2m\033[90m(%s)\033[0m" "$model_suffix"
  line2_empty=0
fi
if [ -n "$five_h" ]; then
  [ "$line2_empty" -eq 0 ] && printf "%b" "$BAR"
  printf "\033[90m5h %s%%\033[0m" "$five_h"
  if [ -n "$five_h_reset" ]; then
    delta=$(compute_delta "$five_h_reset")
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
  if [ -n "$seven_d_reset" ]; then
    delta=$(compute_delta "$seven_d_reset")
    [ -n "$delta" ] && printf " \033[2m\033[90m(%s)\033[0m" "$delta"
  fi
  line2_empty=0
fi
if [ -n "$ctx_str" ]; then
  [ "$line2_empty" -eq 0 ] && printf "%b" "$BAR"
  printf "\033[90mctx %s\033[0m" "$ctx_str"
  [ -n "$ctx_tokens_str" ] && printf " \033[2m\033[90m(%s)\033[0m" "$ctx_tokens_str"
  line2_empty=0
fi
