# 1on1 — eval suite

`claude plugin eval` suite for `skills/1on1`. Each case in `evals.json` has a
numbered directory here whose `scaffold.sh` builds the starting repo (git
history, instructions files, earlier reviews), so the precondition each eval
describes is actually set up. Run from the repo root:

```sh
claude plugin eval skills/1on1 --ablation none --scaffold --judge-model sonnet --allow-tools Write Edit "Bash(git:*)" "Bash(ls:*)" "Bash(date:*)" "Bash(mkdir:*)" -j 6
```

- `--ablation none`: the skill is slash-only (`disable-model-invocation`), so a
  no-plugin arm has nothing to invoke.
- The interview is multi-turn, so each prompt tells the run to take every
  answer as "fine, nothing to add" and go straight to the report. That tests
  steps 1, 5 and 6, not the interview itself.
- The sandbox HOME is isolated: the general-session case never touches your
  real `~/.claude` or `~/.agents`.
- Report-path graders check the path the run tried to `Write`, not the file:
  the sandbox can deny writes under dot-directories, and a denied write would
  otherwise fail a compliant run.
- Results land in `evals/results/`, gitignored.

| case | checks |
|---|---|
| 01-weekly-project | project with `CLAUDE.md`: items there, no `AGENTS.md` created |
| 02-general-session | report under `~/.agents/1on1-reviews/`, items in `~/.claude/CLAUDE.md` |
| 03-past-reviews | reads the earlier review in `.agents/1on1-reviews/` |
| 04-agents-md-only | replaces the existing section in `AGENTS.md`, no `CLAUDE.md` |
| 05-claude-md-only | items in `CLAUDE.md`, no `AGENTS.md` |
| 06-agents-md-no-section | adds the section to `AGENTS.md`, no `CLAUDE.md` |
| 07-legacy-reviews | still reads reviews left in the old `.claude/reviews/` |
| 08-both-files | items go to `AGENTS.md`; `CLAUDE.md` untouched |
| 09-neither-file | creates `AGENTS.md`, not `CLAUDE.md` |
| 10-claude-md-symlink | `CLAUDE.md → AGENTS.md`: one section, in `AGENTS.md` |
