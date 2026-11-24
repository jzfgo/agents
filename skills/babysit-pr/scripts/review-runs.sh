#!/usr/bin/env bash
# List every review comment the bot left on a PR, paired with the workflow run
# that comment belongs to and that run's status.
#
# Usage:   review-runs.sh <pr-number> [bot-login] [automatic-review-workflow]
# Example: review-runs.sh 42
#          review-runs.sh 42 'claude[bot]' claude.yml
#          GH_REPO=owner/repo review-runs.sh 42
#
# Output (TSV, one row per bot comment, in comment order):
#   comment_id  run_id  via  status  conclusion  created_at  updated_at  reviewed_sha  written
#
# via says where run_id came from: "link" (the comment's [View job] link),
# "auto" (that link, to an automatic pull_request run in tag mode), "time"
# (matched to an automatic pull_request run without a link, see below) or "-"
# (no run found). status/conclusion are "-" when there is no run to look up,
# and status is "unreadable" when gh cannot read the run.
#
# A "link" or "auto" review counts as finished only with status "completed",
# conclusion "success" AND updated_at later than created_at (the placeholder
# was edited).
# A "time" review counts as finished with status "completed" and conclusion
# "success"; it posts once, with no placeholder, so it is never edited.
# reviewed_sha is the PR head commit an "auto" or "time" run was started for,
# and "-" for "link" rows: an issue_comment run reports the default branch's
# commit, not the one it reviewed.
#
# written is "no" when the body still holds the action's spinner image or its
# untouched placeholder line ("I'll analyze this and get back to you."), and
# "yes" otherwise. The agent's first edit of a tag-mode comment is its
# progress checklist, with the spinner, so an edit alone does not mean the
# review was written. When the run ends, the action strips only its own
# "Claude Code is working…" line and keeps the rest, so a run that ended green
# without the agent finishing still shows the spinner or the placeholder line.
# A "link" or "auto" review counts only with written "yes" as well.
# The test can be wrong both ways. A finished review that quotes the spinner's
# asset id or the placeholder line reads "no", which costs only a needless
# re-request. An agent that ignored the prompt's request to use the spinner,
# wrote its checklist without it and then stopped, reads "yes"; that takes two
# slips at once, and the body is still read for findings before it counts.
#
# Both strings are copied from the action's src/github/operations/comments/
# common.ts (SPINNER_HTML and the placeholder body) at v1.0.276. The agent
# copies the spinner from the tag-mode prompt in src/create-prompt/index.ts,
# which repeats the same image. If a later version changes either string in
# either file, the test fails open: every row reads "yes" and nothing errors.
# Whenever a repo using this script bumps claude-code-action, compare both
# files at the new version with the strings below.
#
# Why this exists: the action posts a placeholder comment within seconds and
# edits it in place when the review finishes, so neither the comment's presence,
# its wording nor its created_at says whether the review is done. The run status
# does. The run id is taken ONLY from the [View job] link: a finished review also
# links the CI run it reports on, and that one finishes minutes earlier.
#
# An automatic review on `pull_request` that runs the code-review plugin
# (posting with `gh pr comment`) leaves no [View job] link. This repo's own
# workflow has run in tag mode since, so "time" rows now come only from PRs
# reviewed before that switch, or from repos still running the plugin. Given
# the workflow file that runs it as the third argument, a comment without a
# link is matched to that workflow's pull_request run on the PR's head branch
# that was running when the comment was posted. Only a comment that opens
# with the plugin's summary heading ("## Code review") is matched: any other
# linkless comment (a placeholder from another workflow, say) is no review and
# keeps "-". Exactly one such run must match, or the row keeps "-".
#
# Needs gh (authenticated) and jq. Uses the current repo, or GH_REPO if set.

set -euo pipefail

if [[ $# -lt 1 || $# -gt 3 || ! $1 =~ ^[0-9]+$ ]]; then
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
fi

pr=$1
bot=${2:-claude[bot]}
workflow=${3:-}

# REST reports the bot as "claude[bot]"; GraphQL (gh pr view --json comments)
# reports the same account as "claude". This script uses REST.
# Fetch first, filter second: on an error gh prints the error body to stdout,
# and piping that into jq would bury the real message under a jq type error.
if ! comments=$(gh api "repos/{owner}/{repo}/issues/$pr/comments" --paginate); then
  echo "could not read the comments of #$pr (does the PR exist in this repo?)" >&2
  exit 1
fi

# The action's spinner image, as its src/github/operations/comments/common.ts
# and src/create-prompt/index.ts define it at the pinned v1.0.276.
spinner=5ac382c7-e004-429b-8e35-7feb3e8f9c6f

rows=$(
  jq -r --arg bot "$bot" --arg spinner "$spinner" '
      .[]
      | select(.user.login == $bot)
      | [ (.id | tostring),
          (first(.body | capture("\\[View job[^\\]]*\\]\\([^)]*/runs/(?<r>[0-9]+)") | .r) // "-"),
          .created_at,
          .updated_at,
          (if .body | test("^##[[:space:]]+Code review[[:space:]]*(\n|$)") then "summary" else "-" end),
          (if (.body | contains($spinner)) or (.body | contains("I'"'"'ll analyze this and get back to you."))
             then "no" else "yes" end) ]
      | @tsv' <<<"$comments"
)

if [[ -z $rows ]]; then
  echo "no comments by $bot on #$pr" >&2
  exit 0
fi

# pull_request runs carry the PR's head branch, unlike issue_comment runs, so a
# branch filter finds them. A branch name is not unique, though: a fork or an
# older PR may use the same one. So keep only runs that GitHub links to this PR
# and that came from the PR's own head repository. (GitHub leaves
# pull_requests empty on fork runs, so a fork PR's review stays unmatched.)
# Read once; a failure only disables the matching.
auto_runs='[]'
if [[ -n $workflow ]]; then
  if read -r head head_repo < <(gh pr view "$pr" --json headRefName,headRepository \
    --jq '"\(.headRefName) \(.headRepository.nameWithOwner)"' 2>/dev/null) &&
    runs=$(gh api -X GET "repos/{owner}/{repo}/actions/workflows/$workflow/runs" \
      -f event=pull_request -f branch="$head" -F per_page=50 2>/dev/null) &&
    runs=$(jq --argjson pr "$pr" --arg repo "$head_repo" '
        [ .workflow_runs[]
          | select(any(.pull_requests[]; .number == $pr) and .head_repository.full_name == $repo)
          | { databaseId: .id, status, conclusion: (.conclusion // ""),
              createdAt: .created_at, updatedAt: .updated_at, headSha: .head_sha } ]' <<<"$runs"); then
    auto_runs=$runs
  else
    echo "could not list $workflow's pull_request runs; automatic reviews stay unmatched" >&2
  fi
fi

printf 'comment_id\trun_id\tvia\tstatus\tconclusion\tcreated_at\tupdated_at\treviewed_sha\twritten\n'
while IFS=$'\t' read -r comment run created updated kind written; do
  via=- status=- conclusion=- sha=-
  if [[ $run != - ]]; then
    via="link"
    # A run can be deleted, expired or unreadable with this token. Report that
    # in the row instead of letting set -e end the table without a word.
    if run_info=$(gh run view "$run" --json status,conclusion,event,headSha \
      --jq '"\(.status) \(if .conclusion == "" then "-" else .conclusion end) \(.event) \(.headSha)"' 2>/dev/null); then
      read -r status conclusion event head_sha <<<"$run_info"
      # A pull_request run is the automatic review in tag mode: it reports
      # the PR head it reviewed. issue_comment runs report the default branch.
      if [[ $event == pull_request ]]; then
        via="auto" sha=$head_sha
      fi
    else
      status=unreadable conclusion=-
    fi
  elif [[ $kind == summary ]]; then
    # The run was going when the comment was posted: it started before, and it
    # either is still going or last changed (completed) after. ISO-8601 UTC
    # timestamps compare correctly as strings.
    match=$(jq -r --arg t "$created" '
        [ .[] | select(.createdAt <= $t and (.status != "completed" or .updatedAt >= $t)) ]
        | if length == 1 then .[0]
            | "\(.databaseId) \(.status) \(if .conclusion == "" then "-" else .conclusion end) \(.headSha)"
          else empty end' <<<"$auto_runs")
    if [[ -n $match ]]; then
      read -r run status conclusion sha <<<"$match"
      via="time"
    fi
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$comment" "$run" "$via" "$status" "$conclusion" "$created" "$updated" "$sha" "$written"
done <<<"$rows"
