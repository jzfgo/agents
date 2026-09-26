# write-like-me — mode-routing eval suite

`claude plugin eval` suite for `skills/write-like-me`: does it route to the right
mode, and does the output avoid the concrete tells a user would notice? Voice
fidelity is deliberately **not** scored.

```sh
claude plugin eval . --ablation with-without --scaffold --allow-tools Write Edit --judge-model sonnet
```

- `--scaffold` — cases 01–05 stage the fictional fixture profile (Nuria Beltrán,
  `skills/write-like-me/evals/fixtures/perfil-de-prueba/`) into the sandbox cwd
  as `.write-like-me/` via `context.scaffold_script`. The script is
  self-contained and strips the fixture's "PERFIL DE PRUEBA" banners: with them
  the skill (correctly) refuses to write for a made-up author.
- `--allow-tools Write Edit` — case 04 (`update`) edits the staged profile.
- `--judge-model sonnet` — the default judge (haiku) is too small for these rubrics.
- Each case declares `plugins: [../../skills/write-like-me]`: the repo root is a
  marketplace, not a plugin, so auto-detection finds nothing.
- The sandbox has its own HOME; `~/.write-like-me` is not readable from a run.

Headline number: **Δ** (with-plugin score minus without-plugin score).

## Cases

| case | route under test | Δ source |
|---|---|---|
| 01-write-es-client-email | bare write | no `nosotros`, opens with a fact, closes on a decision/question |
| 02-rewrite-es-robotic-post | rewrite | no summarising close; placeholders instead of invented facts |
| 03-review-es-group-message | review | flags the plural in a signed piece; no rewritten wording |
| 04-complaint-is-update | update | **none by design** — the staged profile explains itself, so the baseline also edits it. Kept as a guard: it drops if `update` breaks |
| 05-no-init-on-inference | complaint ≠ init | fails today: the skill routes "start over from my blog" to `init` |
| 06-no-profile-stops | missing-profile guard | stops and points to `/write-like-me init` |
| 07-neg-cofounder-voice | should NOT fire | someone else's voice |
| 08-neg-tighten-scratch | should NOT fire | generic editing |

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

## Results

First full run (2026-09-26, 3 runs × 2 arms): mean Δ +0.20, $6.19, ~20 min.
Case 03 re-run after the grader split: with 1.00, without 0.42, Δ +0.58.
Case 05 fails with the plugin in 3/3 runs (routes to `init`).
