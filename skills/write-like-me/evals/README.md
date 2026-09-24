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

### Replicated in iteration 2

Iteration 2's clean eval-3 baseline is a second, independent confirmation. Three
runs of the same eval now exist:

| Condition | Artifacts emitted |
|---|---|
| Iteration 1, rubric reachable | `SKILL.md`, `VOICE_PROFILE.md`, `GROUNDING.md`, `regression/` — the assertion list, exactly |
| Iteration 1, clean re-run | `javi-voice-es/SKILL.md`, `evals/`, `.claude-plugin/` — the repo's own CLAUDE.md conventions |
| Iteration 2, clean baseline | `profile.md`, `calibration.md` — names of its own invention |

The two clean runs disagree with each other, and that is what makes the case
rather than weakening it. Each invented its own vocabulary — one followed the
repo's skill conventions, the other named files after the task — and **neither
produced `GROUNDING.md` or `VOICE_PROFILE.md`**. Those two names exist nowhere
but this skill and its rubric. Two baselines diverging freely and still avoiding
exactly the two answer-key names is stronger evidence than agreement would have
been: the contaminated run's convergence was reading, not convergent design.

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

## 4. Rate limits will eat a batch; plan the round around that

Iteration 1 lost two of three with-skill timings to rate limits. Iteration 2 lost
an entire wave: six cells launched at once (evals 1-3, both conditions) all died
mid-run on a session limit, HTTP 429, minutes apart. Not one had saved a
deliverable, so all six were discarded and re-run from scratch.

What that costs is not the tokens, it is the *measurements*: a cell killed
mid-flight produces no task notification with `total_tokens` and `duration_ms`,
so even a run whose response file survived contributes nothing to the efficiency
half of the benchmark. A partial cell is not a weak data point, it is zero.

Three things follow, and they are cheap:

1. **Launch in small waves, not one big fan-out.** The limit is a budget over a
   window, not a concurrency cap, so a wide fan-out does not spend less — it just
   loses more when the budget runs out mid-flight. Pair each eval's two
   conditions in the same wave (that is what keeps the comparison fair) and keep
   waves to about four cells. Put eval 3 in a wave of its own: at ~213k tokens
   for the with-skill cell it is the single most expensive thing in the suite.
2. **Tell every run to save its deliverables early and append to the transcript
   as it goes.** The default behaviour is to compose both files at the end, which
   is precisely when the run is most likely to be killed. This is one paragraph
   in the run prompt and it converts a total loss into a partial one.
3. **Quarantine partials; never grade them.** Move them somewhere named for what
   happened (`descartados-rate-limit/`) and empty the cell. A half-finished
   `response.md` sitting in a run directory is indistinguishable, three hours
   later, from a finished one.

### Grading gets eaten too, and the order of operations is the whole defence

Both grading batches of iteration 2 were killed mid-flight, and the two came out
differently for one reason:

- **Eval 1's six graders all died at the 429** — and all six `grading.json` files
  survived intact, because the prompt told them to write the file before
  composing any summary. The kill landed on the report, which is worthless.
- **Eval 2's six graders all died too**, and lost everything, because eval 2's
  assertion 8 makes them verify every citation against the corpus before they
  can rule on it. There was nothing written yet to save.

So: **tell every grader to write its file before it writes its report**, and for
an eval with one expensive assertion, tell it to write the file twice — a first
pass with the cheap assertions graded and the expensive one marked
`PENDIENTE`, then a rewrite once that one is done. A kill then leaves a file that
names what is missing, instead of a gap you have to rediscover.

Second lesson from the same batch: six graders re-deriving the same corpus
inventory is six times the burn for one number. Compute the shared facts once
into a fact sheet (`guards/corpus-hechos.md`) and hand it to all of them. Keep
per-cell verification — each cell's citations differ — but never the shared part.

### Two traps in the timing numbers themselves

**Watch for re-notifications.** A cell can notify twice: once when the agent
finishes, and again later when a stray background child of its shell is reaped.
The second notification carries the same run's final token count but the *child's*
wall clock. In iteration 2 three cells re-notified with `duration_ms` around
46,900,000 — thirteen hours — for runs that took five to eleven minutes. Taking
that figure would have inflated the round's mean by an order of magnitude. Keep
the duration from the first notification and the token count from the last, and
record which is which in `timing.json`.

**And note what caused those strays**, because it is this README's own advice
backfiring: telling a run to "create `transcript.md` at the start" led three
separate cells to open with a heredoc bundled into a compound command, which hung
and was killed for memory. The instruction is still right — it is what turned a
rate-limit kill from a total loss into a partial one — but say *write the file*
rather than implying a shell heredoc, and tell runs to keep the first command
simple.

Budget realistically before starting: the full suite at n=3 is 30 cells and
roughly 2.5-3M tokens. That does not fit in one window, so expect the round to
span several and to be interrupted. Capture each `timing.json` the moment its
notification arrives rather than at the end of a wave — an interrupted wave takes
the uncaptured numbers with it.

## 5. The home profile is an answer key for evals 1-3 (and it is the READ that leaks)

Iteration 2's sharpest finding, and the one most likely to be re-introduced,
because everything about it looks safe. The rule that was written down was about
*writes*: evals 3 and 4 write a profile, so back up `~/.write-like-me/` and pin a
project-local one. Nobody considered that evals 1 and 2 **read** it.

Post-merge, the first thing the skill does is resolve a profile directory. On
this machine it finds the real one, which holds fifteen accumulated Pass 2/3
corrections, a named exclusion list and a corpus table — in other words, much of
what evals 1 and 2 ask a run to work out from the corpus. Both with-skill runs
duly resolved it: eval 2's quoted the corpus table and the exclusions and
concluded the task was not an `init` at all because a profile already exists, so
it never reached the provenance-and-Pass-1 stage the eval grades. Eval 1's read
`VOICE_PROFILE.md` and `GROUNDING.md` and recommended `update` instead of
extracting. Neither wrote a byte; the profile was verified intact afterwards.

Note what kind of failure that is. The runs behaved correctly — better than
correctly — and the evals still measured nothing, because evals 1-3 were written
before the 2026-09-03 merge, for a skill that emitted a second skill and had no
notion of a profile that already exists. The stage they grade is a stage the
skill now, rightly, declines to reach.

The decisive argument is fairness, not leakage: **the baseline has no skill, so
it resolves no profile and triages from scratch.** Leave the home profile
readable and the two conditions are answering different questions, so the delta
measures who had a profile in front of them.

So for evals 1 and 2, the harness must put `~/.write-like-me/` fully out of
bounds — unreadable, not merely unwritable — and say so in the run prompt as a
benchmark constraint. Eval 3 needs nothing: its prompt pins a project-local
`.write-like-me/`, which wins the resolution order. Evals 1 and 2 lacked the
protection precisely because their prompts say nothing about where a profile
lives, which they have no reason to — they do not write one.

The general form, which is worth keeping separate from §1: a benchmark leaks
through **anything the run may read**, and the author's real working state is as
much an answer key as the rubric is. §1 says keep the run away from the answers;
this says remember that the author's own accumulated work *is* answers.

### A smaller leak, logged for honesty

Two runs reported, unprompted, that they had listed the off-limits `evals/`
subtree while hunting for candidate profile paths — filenames only, no file
opened. Judged non-invalidating: the visible names (`evals.json`, `README.md`,
`fixtures/`) carry no assertion content. Fixed in the run prompt anyway, by
asking runs to exclude that subtree from a search rather than filter its output
after the fact, which is what produced both leaks. Worth keeping the run's own
self-report habit: both were caught because the runs volunteered them.

## 6. The agent's own memory directory is the fourth leak channel

Found late in iteration 2, and the hardest of the three to see. The eval-2
baseline read
`~/.claude/projects/-Users-javi-Projects-personal-agents/memory/voice-skill-corpus-provenance.md`
and described it, accurately, as "my own prior note on this corpus". That note's
own one-line summary is *"which of Javi's writing counts as native-voice evidence
for the voice-extractor skill, and which is contaminated"* — eval 2's task
statement, with the answer.

The run declared a mitigation: it re-verified every claim in the note against git
rather than trusting it. That is good practice and it does not save the cell.
Knowing where to look and what you expect to find is most of provenance triage,
which is the thing being measured.

Only one of sixteen executed cells touched it, so the fix is cheap: name the
memory directory in the off-limits list, in both conditions, alongside the skill's
`evals/` and the home profile. Note that a *with-skill* run is just as exposed —
nothing about having the skill stops an agent consulting its notes.

### The channels, and the rule that covers the first four

| Channel | What leaked | Found |
|---|---|---|
| Eval definitions beside the outputs | the rubric | iteration 1 |
| The fixture's own README, copied into the run | two assertions' answers | iteration 2, before measuring |
| `~/.write-like-me/` | the corpus table, exclusions, fifteen corrections | iteration 2, cells 7-8 |
| The agent's memory directory | a prior session's provenance conclusions | iteration 2, cell 16 |
| `regression/casos.md`, inside the seeded profile | the output FORMAT assertion 2 rewards | iteration 2, while grading (§7) |

Each was invisible from the defence written for the previous one, because each
arrived by a different route: beside the output, inside the seeded input, through
the skill's own resolution order, and through the agent's private notes. The
formulation that covers all four, and the one to carry into iteration 3:

> **A benchmark leaks through anything the run is able to read — and the author's
> own accumulated work is the answer key.** The rubric is the obvious form of it.
> The profile, the fixture's documentation and the agent's memory are the
> non-obvious forms, and they are non-obvious precisely because each of them is
> legitimate, useful, and somebody's deliberate work product.

The practical consequence: an off-limits list built by asking "where is the
rubric?" will keep missing. Build it by asking **"what has anyone already
concluded about this task, and where did they write it down?"**

That question catches the first four. It does not catch the fifth, which is why
§7 exists: the fifth channel carries no conclusion at all.

## 7. The fifth channel leaks the FORM of the answer, and it leaks from a file the run must read

Found while grading iteration 2, not while running it, and it is the one the rule
above does not catch.

Eval 5's assertion 2 wants line-level findings that each carry a taxonomy label
and a `VOICE.md` section pointer. The fixture's `regression/casos.md` — part of
the profile, so every run opens it — displays worked findings in exactly that
shape:

    - Línea 1 `NOT_ME` — «En el vertiginoso mundo de las herramientas SaaS…».
      Abre por marco de sector; ella abre por dato. → `VOICE.md` §4 Aperturas.

The only two labels it shows are `NOT_ME` and `TOO_FORMAL`. Here is what each
cell actually emitted, counted with grep over the deliverables:

| cell | labels used |
|---|---|
| baseline run 1 | `NOT_ME` ×3, `TOO_FORMAL` ×1 |
| baseline run 2 | none |
| baseline run 3 | `TOO_FORMAL` ×1 |
| with skill run 1 | `LLM_ISM`, `MISSING_PATTERN`, `WRONG_WORD`, `NOT_ME` |
| with skill run 2 | `LLM_ISM`, `TOO_CASUAL`, `WRONG_WORD`, `NOT_ME` |
| with skill run 3 | `LLM_ISM`, `MISSING_PATTERN`, `NOT_ME` |

The baselines use the two labels the fixture teaches them and **not one other**.
The skill runs use four that appear nowhere in the fixture. The imitation has a
ceiling and the ceiling is visible in the data.

This channel is different in kind from the four above. Those were things a run
should not have read. This is a file a run **must** read, which happens to
demonstrate the graded output format alongside its content. Asking "what has
anyone already concluded about this task?" does not catch it, because
`casos.md` holds no conclusion about the piece under review. It holds the
**shape** of the answer.

> **A fixture that demonstrates the output format is grading the evaluator, not
> the evaluated.** If an assertion rewards a format, that format must not appear
> already-solved in any file the run opens.

Cheapest fix, and it works on the data already collected: score only the labels
the fixture does not show. That separates 0/0/0 from 4/4/3 with no re-runs. The
thorough fix is to strip the labels out of `casos.md` and leave the cases in
prose, which changes the fixture and costs all six eval-5 cells.

## 8. For anything under version control, git is the guard — not a manifest you took yourself

A grader objected, correctly, that `guards/fixture.sha256` was written at 10:24
when one routing cell had already run: the manifest can only prove the fixture
was intact *afterwards*.

Git closes that gap, and it closes it better than diligence does:

- the four profile files were committed at 10:08 (`5c670fc`) and `git status`
  reports no uncommitted change to any of them;
- their mtimes are 09:29-09:30, before both the manifest and every routing cell;
- the only change under `fixtures/` is a `README.md` deliberately moved out.

**A hand-taken manifest depends on remembering to take it before the round, which
is exactly the guarantee that fails under time pressure. A committed tree does
not.** So `check_integrity.py` should check the repo fixture with
`git status --porcelain -- <path>` rather than sha256 against a file the runner
generated. Keep the manifests only for what git does not cover — here, that is
`~/.write-like-me/`.

## The routing fixture

Evals 4 and 5 need an existing profile. It ships at
`evals/fixtures/perfil-de-prueba/`, and the sibling `evals/fixtures/perfil-de-prueba.md`
explains the hooks each assertion depends on. That documentation is a sibling and
not a README inside the profile on purpose: the hook table is the answer key to two
assertions, and while it sat inside, `cp -R` carried it into the run's working
directory inside the very file the run must open. Same lesson as §1, one directory
further in. The one rule worth repeating here: **copy it** into the
run's working directory as `.write-like-me/`, never symlink it and never point a
run at it in place. Eval 4 writes to the profile, and the seeded project-local
directory is also what keeps a run off the real `~/.write-like-me/`, since local
wins the resolution order.

Back up `~/.write-like-me/` before any round regardless. Evals 3 and 4 both write
a profile; a corpus is read-only and recoverable, a profile is neither.

## 8. Eval 5 was replaced, not rewritten

After review, the iteration-2 eval 5 turned out to discriminate the wrong way.
Its one win for the skill (assertion 2) rewarded printing the taxonomy codes,
and the author found those cryptic. Its one loss (assertion 8) asked for a code
by name. On the nine assertions that measured the critique itself, baseline and
skill tied. Nothing was left for it to measure.

It now tests the branch nobody had tested: **asking when `review` and `rewrite`
tie**. The draft and the plants are unchanged, so the notes on the fixture
(`potente` as decoy, the four planted violations) describe what a run would
find if it skipped the question. They no longer describe what the eval rewards.

The fixture's `regression/casos.md` still shows findings with codes. That is
correct for a profile, where the codes route `update`. It now works as a lure:
a run that copies that shape into its question to the author fails assertion 5.
