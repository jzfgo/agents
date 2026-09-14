# Running this eval suite

Everything about *what* the evals check lives in `evals.json` — `run_setup`,
`grading_instructions`, `coverage_gaps` and the per-eval `setup` fields. This
file holds the three things that are **not** recoverable from there, because
they are facts about how iteration 1 actually went rather than about what the
evals say.

---

## 1. Never run inside this repository

Runs must write their outputs to the session scratchpad, or anywhere that shares
no readable ancestor with this repo. **Any cell run inside the repository is
void**, and the reason is measured, not theoretical.

In iteration 1, runs wrote to `skills/<skill>-workspace/iteration-1/<eval>/<condition>/outputs/`
— a sibling of `skills/<skill>/evals/evals.json`. The answer key, every assertion
verbatim, sat two directories from the agent's own output path.

The **no-skill baseline** for eval 3 then emitted exactly `SKILL.md`,
`VOICE_PROFILE.md`, `GROUNDING.md` and `regression/`, and used the phrases
"anti-performative" and "audience-conditional". `GROUNDING.md` is a filename this
skill invented. "Anti-performative" is this skill's coinage. "Audience-conditional"
is the wording of **eval 3's assertion**, not of the prompt the agent was given —
the prompt says "the technical vocabulary depends on the audience".

Confirmed by re-run. Same prompt, same model, same corpus; the only variable was
whether the rubric was reachable:

| | Contaminated run | Clean re-run |
|---|---|---|
| Artifacts emitted | `SKILL.md`, `VOICE_PROFILE.md`, `GROUNDING.md`, `regression/` | `SKILL.md`, `evals/`, `.claude-plugin/plugin.json` |
| Corresponds to | the assertion list in `evals.json`, exactly | the repo's own `CLAUDE.md` skill conventions |

The clean baseline produced no `GROUNDING.md` and no `VOICE_PROFILE.md`. Those
names exist nowhere but this skill and its rubric, so the first run was not
convergent design. (The clean run did read the root `CLAUDE.md`. That is
legitimate: it is the documented convention for adding a skill here, and any
agent doing this task for real would read it.)

Scope of the damage: eval 3's with-skill/baseline comparison from iteration 1 is
**not trustworthy** — its artifact-set assertions cannot tell a skill-guided run
from a rubric-guided one. Evals 1 and 2 stand; both baselines *failed* the
provenance, held-out and self-interview assertions, which they would have passed
had they read the key.

**So, for every run:**

1. Outputs go outside this repository. Copy them back in afterwards if the
   viewer needs them.
2. Instruct every run, in both conditions, not to read anything under
   `skills/write-like-me/`.
3. Prefer assertions that describe *properties* of an artifact over ones that
   name required filenames. "Separates factual grounding from voice patterns" is
   hard to satisfy by copying; "emits GROUNDING.md" is not.

The general form of the lesson: **eval outputs and eval definitions must never
share a filesystem ancestor the agent is allowed to read.** `*-workspace/` being
a sibling of the skill is convenient for the viewer and wrong for validity.

## 2. Iteration 1 was n=1 in every cell, whatever `benchmark.json` says

`benchmark.md` says "3 runs each per configuration" and `benchmark.json` sets
`metadata.runs_per_configuration: 3`. **Both are wrong.** `runs` holds 6 entries
— 3 evals × 2 conditions — every one carrying `run_number: 1`, and the run
directories contain only `run-1`.

So the headline `63% ± 18%` on the baseline pass rate is variance **between
evals**, not between runs, and nothing in iteration 1 separates the two. Closing
that is the whole point of iteration 2: 2–3 runs per configuration, and capture
`timing.json` the moment a task notification arrives, because `total_tokens` and
`duration_ms` are persisted nowhere else and cannot be recovered afterwards.

## 3. The iteration-1 artifacts are local-only

They live in `skills/write-like-me-workspace/iteration-1/` — `benchmark.md`,
`benchmark.json`, per-eval `eval_metadata.json`, `grading.json`, `timing.json`,
`HARNESS_ISSUE.md` and the transcripts. `.gitignore` carries `*-workspace/`, so
**none of it is committed and none of it survives a clone.** Read that directory
before designing iteration 2 rather than re-deriving the protocol; this file
exists because the part of it that matters most should not depend on one
machine's disk.

## The routing fixture

Evals 4 and 5 need an existing profile. It ships at
`evals/fixtures/perfil-de-prueba/` and its README explains the hooks each
assertion depends on. The one rule worth repeating here: **copy it** into the
run's working directory as `.write-like-me/`, never symlink it and never point a
run at it in place. Eval 4 writes to the profile, and the seeded project-local
directory is also what keeps a run off the real `~/.write-like-me/`, since local
wins the resolution order.

Back up `~/.write-like-me/` before any round regardless. Evals 3 and 4 both write
a profile; a corpus is read-only and recoverable, a profile is neither.
