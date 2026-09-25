# Template — the profile's `VOICE.md`

Skeleton for the file `init` writes into the profile directory. This is **not** a
skill: it has no frontmatter, no `description:` and no mode table. Those belong
to `SKILL.md`, which is generic, ships with the skill, and is the same for every
author. What goes here is only what the corpus told you about one person.

Fill every `{{...}}`. Delete sections the corpus gave you no evidence for rather
than padding them with plausible guesses, and record in `VOICE_PROFILE.md` which
ones you dropped and why.

Section order below is by descending impact on the output, not by tidiness. The
applying agent reads top-down and its attention decays, so the deltas that change
word choice come before the descriptions of tendencies.

Write it in the language the author writes in. A profile for a Spanish author
reads better in Spanish, and the agent applying it is working in Spanish anyway.

---

```markdown
# Voice — {{author}}

Evidence and corpus notes in `VOICE_PROFILE.md`. What may be asserted as fact
about {{author}}, in `GROUNDING.md`.

## Before you write

Find the closest same-format sample in `VOICE_PROFILE.md` and mirror its
structure, paragraphing and rhythm. Mirroring a real piece gets you closer than
any rule below — the rules are guardrails for what mirroring misses, not a
template to fill in.

## 1. Ban-list deltas

The skill loads the generic lists from its own `assets/` — this file cannot reach
them by path and must not try. This section is only what the corpus changed.

### Also never, for this author
{{banned words and turns verified absent from the corpus, or present only in
material the author disowned, that are NOT already on the generic lists. An
item the generic lists already ban does not go here because the corpus lacks it
too: that absence confirms the list, it doesn't change it.}}

### Exceptions — words the generic lists ban that are THEIRS
{{Do not strip these. One row per word. Admit a word by dispersion across pieces,
not by count, and hold structural connectives to a higher bar than content
words. A word common in AI prose that appears in only one piece stays banned.}}

| Word | Register | Appears in | Proof |
|---|---|---|---|
| {{word}} | {{all / personal / professional}} | {{a.md, b.md, c.md}} | {{quote}} ({{source, year}}) |

### Capped, not banned
{{items allowed at most {{n}} times per piece, with the author's real
alternatives and their counts}}

### Stacking, not banning
{{patterns that are both signature and tell. Give the count: one use is voice,
{{n}} in a piece is a tell.}}

## 2. Don't perform the voice

Patterns here describe tendencies, not obligations.

- A phrase used once in the corpus is not a catchphrase. Don't build a running
  bit out of it. {{the specific one, and where it really came from}}
- An occasional habit is not a signature. {{author}} does {{x}} sometimes; every
  paragraph is a caricature.
- Don't manufacture roughness. Inserting deliberate errors or forced asides to
  seem human reads worse than clean prose. {{whether the author wants their real
  typos preserved — ask; most do not}}
- Don't turn any finding in this file into a tic. One observed use is a use.

## 3. Core patterns

**Correction direction: {{toward what}}.** {{The author's characteristic failure,
in their own corrections from Pass 3. Do not assume the usual "too tidy, too
neutral" — some authors' corrections pull the other way, and a rule written
backwards makes every draft worse.}}

{{3-6 patterns, each: the rule, then a wrong/right pair drawn from real corpus
text or from the author's own Pass 3 markings. The contrast carries the voice;
the prose around it is scaffolding.}}

**{{Pattern name}}**
{{one-line rule, with a count attached if one applies}}

| ❌ | ✅ |
|---|---|
| {{generic version}} | {{quoted or closely-modelled real line}} |

## 4. Registers

Called registers, not modes: `rewrite` and `edit` are modes, and reusing the word
for `formal`/`personal` guarantees a confusion that costs a whole draft.

Default: **{{register}}** — assume it unless the task says otherwise.

| Register | Address | Person | When |
|---|---|---|---|
| {{name}} | {{tú/usted/…}} | {{I/we}} | {{formats}} |

{{Mark any register the corpus does not evidence with ⚠️ and say so in the rule
itself, so the applying agent warns the author instead of inventing one.}}

### Formatting, by job
{{What each device DOES for this author, not how often it appears: which lines
get bold (labels in key-value lines? the conclusion of a block? names of
products and tools?), whether headings carry bold on top of their size, where
lists appear. Give the density range by structure, never one global cap —
listy text and running prose differ several-fold. Mark which of these are added
at revision, so the applying agent does the revision pass.}}

### Openings
{{how {{author}} actually starts, with real examples. Highest-tell region of any
text — be specific and concrete. Say what they do; don't list the generic
openers they avoid, the skill already bans those.}}

### Closings
{{how they actually end. Generated text defaults to restating the argument and
turning outward on an uplift; say what {{author}} does instead, with real
examples, not which generic closers they avoid.}}

## 5. What the sweeps check here

The skill owns the two-sweep structure. This says which sections each one walks.

**Sweep 1 — LLM-isms:** {{sections}}. {{author}}-specific things to count:
{{items}}.

**Sweep 2 — performance:** {{sections}}. The question that catches most of it for
{{author}}: {{the specific one}}.
```

---

## Notes for `init`

**On what belongs here** — apply the stranger test to every line. If it would be
identical for another author, it is method, it already lives in `SKILL.md` or
`assets/`, and repeating it here only costs context on every write.

**On sections you drop** — a section with `{{...}}` left in it, or filled with
confident-sounding filler, is worse than an absent one. Absence is honest and the
author can see the gap. Filler is invisible and gets applied.

**On length** — `VOICE.md` loads on every write, so it has to stay comfortably
promptable. Push evidence, counts, corpus notes and the reasoning behind each
rule into `VOICE_PROFILE.md`; keep this file to the rules and the samples they
hang on.

**On the unverified register** — the temptation is to fill the table row anyway
because a gap looks unfinished. Don't. A register with no corpus behind it is the
one place the profile can produce confident nonsense, and the ⚠️ is what makes
the applying agent say so out loud.
