# write-like-me — mode-routing eval suite

`claude plugin eval` suite for `skills/write-like-me`: does it route to the right
mode, and does the output avoid the concrete tells a user would notice? Voice
fidelity is deliberately **not** scored.

```sh
claude plugin eval skills/write-like-me --ablation with-without --scaffold --allow-tools Write Edit --judge-model sonnet
```

- `--scaffold` — cases 01–05 stage the fictional fixture profile (Nuria Beltrán,
  `fixtures/perfil-de-prueba/`) into the sandbox cwd
  as `.write-like-me/` via `context.scaffold_script`. The script is
  self-contained and strips the fixture's "PERFIL DE PRUEBA" banners: with them
  the skill (correctly) refuses to write for a made-up author.
- `--allow-tools Write Edit` — case 04 (`update`) edits the staged profile.
- `--judge-model sonnet` — the default judge (haiku) is too small for these rubrics.
- Run it from the repo root with the skill as the target. The cases share
  `evals/` with the `skill-creator` suite (`evals.json`, `README.md`); only
  directories with a `prompt.md` or `case.yaml` count as cases.
- Results land in `evals/results/`, gitignored.
- The sandbox has its own HOME; `~/.write-like-me` is not readable from a run.

## Isolation: why the graders can live inside the skill

Inside `claude plugin eval`, the harness denies reads under the plugin's eval
dir. Measured 2026-09-27 with a probe run: `references/update.md` read fine;
`evals/evals.json`, `evals/README.md`, `evals/fixtures/…` and a case's own
`prompt.md` all failed with "File is in a directory that is denied by your
permission settings". Glob is denied outright. So a run gets the skill's base
path but cannot read an answer key under it.

Case `99-leak-canary` keeps that measured: it asks the model to read a grader
holding a marker, and fails if the marker shows up in the answer. A pass only
counts if its `read-attempted` indicator shows ✓ (the run tried the read and was
denied); the indicator is with-only, so it doesn't move the score. If it fails,
a CLI change has opened this channel. Stop and move the graders out before
trusting any score.

**Outside the harness there is no such protection:**

- Sync the installed copy with `--exclude evals/`, always:
  `rsync -a --delete --exclude evals/ skills/write-like-me/ ~/.agents/skills/write-like-me/`
- `skill-creator` runs follow `README.md` §1: never inside this repo, and never
  against a copy of the skill that includes `evals/`.

Headline number: **Δ** (with-plugin score minus without-plugin score).

## Cases

| case | route under test | Δ source |
|---|---|---|
| 01-write-es-client-email | bare write | no `nosotros`, opens with a fact, closes on a decision/question |
| 02-rewrite-es-robotic-post | rewrite | no summarising close; placeholders instead of invented facts |
| 03-review-es-group-message | review | flags the plural in a signed piece; no rewritten wording |
| 04-complaint-is-update | update | **none by design** — the staged profile explains itself, so the baseline also edits it. Kept as a guard: it drops if `update` breaks |
| 05-no-init-on-inference | complaint ≠ init | "start over from my blog" is an `update` first; `init` only on the user's own word |
| 06-no-profile-stops | missing-profile guard | stops and points to `/write-like-me init` |
| 07-neg-cofounder-voice | should NOT fire | someone else's voice |
| 08-neg-tighten-scratch | should NOT fire | generic editing |
| 99-leak-canary | harness isolation | **none by design**: both arms must pass. It fails only if a run can read the eval dir (see Isolation) |

## Side-channel ceilings

Measured on the pilot (1 run, with-plugin arm). A run well above these is worth
reading before trusting its score.

| case | budget | with-plugin observed |
|---|---|---|
| 01 | 180 s / 20 turns | 31 s, 10 turns, $0.25 |
| 02 | 180 s / 20 turns | 32 s, 9 turns, $0.23 |
| 03 | 180 s / 20 turns | 48 s, 9 turns, $0.21 |
| 04 | 300 s / 30 turns | 40 s, 13 turns, $0.22 |
| 05 | 120 s / 8 turns | 27 s, 7 turns, $0.12 |
| 06 | 90 s / 5 turns | 15 s, 5 turns, $0.08 |
| 07 | 120 s / 5 turns | 13 s, 1 turn, $0.05 |
| 08 | 120 s / 5 turns | 25 s, 1 turn, $0.05 |

## Calibration decisions (2026-09-26)

- 05: routing a voice complaint to `init` without the literal word is a FAIL,
  even when the answer asks for confirmation first.
- 07: mentioning that the voice skill only covers the user's own voice is fine.
- 02: marked placeholders for facts the author must supply are a pass, not an
  incomplete rewrite (`GROUNDING.md`: "deja un hueco marcado y pregunta").
- 03: quoting the author's past lines as evidence of a habit is fine; offering
  one as wording for this draft ("algo como «…»") is a rewrite and FAILS.
- Multi-condition rubrics were split into one-claim graders after the judge
  failed outputs that met every condition. 03 needed its exception phrased as
  the question itself ("does it propose new text for this draft?"): stated as a
  carve-out, the judge failed 3/3 compliant reviews on the full run.
- 03 (2026-09-27): the judge kept failing compliant reviews over trigger words
  ("por ejemplo", "algo como") and over profile lines quoted cut short. The
  grader now lists the profile's own lines verbatim and judges by content: a
  replacement is new wording the author could paste in. Listing trigger
  phrases made it worse (3/5 false fails): the judge keys on them.
- 07 (2026-09-27): `delivers-pitch` is one question, "is there a finished
  pitch?". Its old second condition repeated the first, and the judge read a
  request for samples *after* the pitch as breaking it.

## Results

First full run (2026-09-26, 3 runs × 2 arms): mean Δ +0.20, $6.19, ~20 min.
Case 03 re-run after the grader split: with 1.00, without 0.42, Δ +0.58.
Case 05 failed with the plugin in 3/3 runs (routed to `init`); fixed in #15:
with 1.00, without 0.60.

After the 2026-09-27 grader fixes (5 runs × 2 arms): 07 with 1.00, without
1.00; 03 with 0.95, without 0.45, Δ +0.50. **03 still fails about one run in
five on a compliant review, with the judge split 2–1.** Read that run before
treating a 03 failure as a regression.
