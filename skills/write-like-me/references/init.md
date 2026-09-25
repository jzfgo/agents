# `init` — build the voice profile

This is the flow behind `init`. It runs once per author, is heavily interactive,
and is discarded when the run ends. Its output is the **profile**: a small set of
data files that every other mode of this skill reads afterwards, in sessions that
remember nothing about this conversation.

Think compiler. The corpus and the author's judgement are your inputs; the
profile is your object file. Two things get confused constantly, so hold them
apart from the first minute:

- **This document** is the method. It is generic, it ships with the skill, and it
  is the same for every author.
- **The profile you write** is the product. It is specific to one person, it
  lives outside the skill, and it has to stand alone.

Anything you learn here that doesn't survive into the profile is lost. That
single fact should govern every judgement call you make below.

Write the profile to the location `SKILL.md` resolved: a project-local
`.write-like-me/` if one exists, otherwise `~/.write-like-me/`. If neither
exists, create `~/.write-like-me/` and say so — a profile written somewhere the
other modes don't look is a profile nobody will ever load.

## Choose the surface first

The three passes are identical everywhere; only how you get text differs.

**Filesystem available** (Claude Code, or any agent with file tools): ask for a
directory, a glob, or a repo path. Read the files yourself. Prefer this — it lets
you cite exact filenames, which the whole evidence discipline below depends on.

**No filesystem** (Desktop, mobile, chat): run the corpus in through the
conversation. Ask for uploads or pasted text, and number each piece as it
arrives (`[C1]`, `[C2]`, …) so you can cite it later the way you'd otherwise cite
a filename. Batch the intake — ask for several pieces per turn, not one, or the
author will abandon the process before Pass 1.

Say which mode you're in before you start reading. If someone points you at a
folder and you can't actually read it, that's worth catching in the first turn
rather than the fifth.

## Intake: qualify the corpus before you analyse a word

Skip this and everything downstream is confidently wrong, because a voice
extracted from the wrong text is indistinguishable — to you — from one extracted
from the right text.

The failure is not hypothetical or rare. People point voice extractors at a notes
vault or a "writing" folder, and those are usually full of saved articles by
other people, AI-drafted summaries, and translations. All three read as fluent
prose. None of them is the author's voice.

Sort every candidate document into one of four buckets, and say which bucket you
put it in:

| Bucket | What it is | Use it? |
|---|---|---|
| **Native** | Written by the author, in the target language, without AI help | Yes — this is the corpus |
| **Assisted** | AI wrote it, or AI edited it past light proofreading | No |
| **Translated** | The author wrote it, but in a different language first | No — see below |
| **Not theirs** | Clippings, quotes, co-authored text, forwarded material | No |

**On translated text.** It's the bucket people forget, and it's the one that
feels safest to include, because the author really did write it. But translation
carries the source language's rhythm, and a translator's word choices are
constrained by the original in a way that free composition never is. Extract from
a translation and you get the author's ideas wearing someone else's sentences.
Keep translations out of the corpus. They're still useful later as calibration
material, since the author can judge whether a generated passage sounds like
them.

**How to actually tell.** You can't ask "did you write this?" for two hundred
files. Get leverage instead:

- Ask directly about *provenance rules* rather than documents: which folders,
  which date ranges, which platforms. Authors know "everything after March is
  AI-assisted" even when they can't remember individual files.
- Check for structural tells of capture rather than composition: source URLs in
  frontmatter, an author field that isn't them, consistent metadata that a person
  wouldn't hand-write.
- Look for paired files across languages — a shared translation key, matching
  filenames in `es/` and `en/` — which usually means one side is derived.
- Read a little of the prose. Translated text tends to lose language-specific
  habits the author uses freely when composing natively: forms of address,
  idiom, register shifts, discourse particles.
- When you're unsure about a document, ask about that document. Being unsure
  about six is normal; being unsure about sixty means you're asking the wrong
  question.

**Then check whether what's left can support an extraction:**

- **Volume**: 10+ documents, and enough words that patterns can repeat. Under
  that, you are extracting noise.
- **Variety**: two or more content types. One type gives you a *format*, not a
  voice — you'll have no way to separate what's characteristic of the person from
  what's characteristic of blog posts.
- **Recency**: prefer the last two years. Voice moves. If the corpus straddles a
  long gap, don't silently average across it — surface the gap, ask which era is
  the target, and weight accordingly. Someone's writing at 25 and at 43 are two
  different authors, and blending them produces a voice belonging to neither.
- **Length spread**: a mix. All-short gives you no evidence about how they build
  an argument; all-long gives you none about how they're terse.

### The gate has three outcomes, not two

Treating it as pass/fail is the mistake that makes this step feel bureaucratic.
Almost every real corpus lands in the middle.

**Fails.** Say so and stop. This is a real stopping point, not a formality — an
extraction from a thin or contaminated corpus spends the author's review time on
patterns that aren't real, and produces an artifact that looks authoritative
anyway. Report what you found, in which bucket, and what's missing.

**Qualifies, with gaps.** The common case: enough documents, but only one content
type, or a decade-wide hole, or nothing short. Don't wave it through with a
caveat buried in a footnote, and don't refuse either — **name the specific gap
and close it**, harvesting first and commissioning only what the harvest can't
cover (below). A caveat tells someone their result is limited; a named gap with a
plan lets them fix it.

**Qualifies cleanly.** Rare. Proceed.

### Enrichment: harvest first, commission last

Whether the corpus failed outright or came up short on one dimension, close the
gap in this order, and do not skip to the second step:

1. **Harvest.** Ask where the missing material already exists. Someone with no
   emails in the corpus almost always has years of sent mail, chat, issue
   comments or review threads. Existing text is the strongest evidence there is
   precisely because it was **not written for this exercise**: no observer, no
   brief shaping what shows up. Ask for sources and date ranges, not for
   documents, and apply the same provenance triage to what comes back.
2. **Commission** only for a gap the harvest could not cover, or to settle a
   specific ambiguity the corpus leaves open. Name the gap or the question in the
   request; a commission without one is ritual.

| What's missing | Harvest from | Commission, if nothing exists |
|---|---|---|
| A second content type | Sent mail, chat, issue and review comments | An email to a colleague, a reply to a stranger |
| Recent voice | Anything sent this year | Two short pieces from this month |
| Short-form evidence | Chat and replies | Three replies under a hundred words |
| Long-form evidence | Design docs, long threads, proposals | One piece that sustains an argument past a page |
| Emotional range | Personal messages, if the author will share them | Bad news; an annoyance; a recommendation to a friend |

**Classify harvested material by register, not by channel.** A chat message to a
client can be as formal as an email, and an email to a close colleague as loose
as chat. Register follows the recipient and the purpose. Record both axes for
every piece — register, and provenance (`harvested` or `commissioned`) — because
they decide how much each piece weighs and which rules it can support.

**When you do commission, ask for the text as they would send it**, revised the
way they revise anything, and record the brief you gave next to the piece. The
brief shapes what appears: tell an author "don't polish" and every trait they add
at revision — formatting especially — goes missing, and the analysis will read
that absence as evidence. A commissioned piece is the weakest evidence in the
corpus; weight it that way and never let it overrule harvested material.

Full triage and rationale in `corpus-qualification.md`.

## Pass 1 — Baseline analysis

Read the qualified corpus and characterise it across eight dimensions. Details,
including what to look for in each, are in `dimensions.md`; read that
file now if you have not.

**A.** Sentence patterns · **B.** Opening patterns · **C.** Vocabulary
fingerprint · **D.** Structural patterns · **E.** Tone markers · **F.**
Formatting habits · **G.** Language-specific patterns · **H.** LLM-ism presence

Openings and closings get their own attention (B, and the closing half of D)
because that's where generated text gives itself away most reliably, and so
that's where the profile needs its sharpest rules.

### Classify every pattern before you write it down

For each pattern, decide what it actually is:

- **VOICE** — a choice the author makes. It would follow them to another platform.
- **PLATFORM** — a convention of the medium. Anyone writing there does it.
- **BORDERLINE** — you genuinely can't tell yet.

This classification is the single highest-leverage step in the pass, because the
confound it addresses is the one that quietly ruins voice profiles. "Uses H2
headings and short paragraphs" is not a personality; it's what blogging looks
like. Encode enough of that and you produce a skill that writes competent blog
posts in nobody's voice.

The useful test: would this pattern survive a change of medium? If they moved
from blog to email, would the habit come along? Bullet lists mostly wouldn't.
A fondness for parenthetical asides would.

**Tag every pattern with the register it was observed in, too.** A corpus that
mixes personal and professional writing will give two honest extractions that
share nothing, and neither is wrong: they sampled different registers. A pattern
seen in only one register goes into that register's rules, not into the global
ones. Global rules — and above all the ban-list exceptions — need evidence from
every register they claim to cover, or a note saying which one they come from.

Mark BORDERLINE items honestly. They are the most valuable input to Pass 2 —
they're precisely the questions where the author knows something you can't see.

**Excluded from the corpus is not the same as useless as evidence.** The medium
test needs two media, and the documents you disqualified are usually the only
other medium you have. A habit that shows up both in the corpus and in something
you excluded — a translated piece, a work document, writing in an institutional
voice — has just survived a change of medium, which is the test. Read the
excluded pile for *this* purpose and no other: it settles BORDERLINE items, and
it never contributes a pattern of its own. Do not let it back in through the side
door — cite it as corroboration for a pattern the corpus already shows, never as
the source of one.

### Evidence discipline

Every claim needs a **filename (or corpus tag) plus a quoted span**. For how
widespread a pattern is, **list the pieces rather than counting them**: "in
`a.md`, `b.md`, `f.md`", not "seen in 8 of 12 posts". A count nobody recomputes
is unverifiable even when it is right, and a list of files is checkable in two
seconds, which is what makes Pass 2 work at all. When a count is needed, compute
it with a tool and say so.

Where you're inferring rather than observing — a plausible pattern with thin
support — mark it inline as `<!-- INFERRED -->`. These markers stay in the draft
through Pass 3 so they keep drawing scrutiny, and get stripped at finalisation.
Inference isn't forbidden; unmarked inference is.

**Verify the citation before you make it, including your own.** Re-read the span
in the file and confirm it says what you are about to claim; a claim about a
repository's history means re-running the command, not recalling what it said
earlier in the session. This sounds redundant next to the rule above and it is
not: the characteristic failure here is not a missing citation but a *confident
and false* one — the right conclusion supported by evidence that does not exist,
which is invisible to every check that only asks whether a citation is present.
A negative claim ("no commit does X") is the most dangerous shape, because it is
the one you cannot support by reading a single file.

### Reserve a held-out set

Before you analyse anything, set aside **20% of the qualified corpus, chosen at
random, and do not read it.** Note which documents they are and leave them alone.

Everything the prior art in this space does terminates in someone's subjective
judgement, which means a profile can be enthusiastically approved and still
be wrong. The held-out set is what makes the result checkable: at the end you'll
generate against prompts derived from those documents and compare with the real
thing the author wrote. Deciding this after you've read everything is not an
option — that's how held-out sets stop being held out.

If the corpus is small enough that holding back 20% drops the working set below
the intake threshold, hold back two documents rather than a percentage, and tell
the author the validation will be weak. Don't skip it. Two checkable cases beat
none, and the alternative is an extraction with no external evidence at all.

Output of Pass 1: a draft `VOICE.md` built against
`../assets/profile-template.md`, plus your VOICE/PLATFORM/BORDERLINE table.

## Pass 2 — Alignment

Walk the author through the draft and collect corrections in four categories:

| Tag | Meaning |
|---|---|
| `WRONG` | Not true of them at all |
| `OVERSTATED` | Real, but you've made it more absolute than it is |
| `MISSING` | A pattern you didn't catch |
| `NEEDS_NUANCE` | True in some contexts, not others |

`OVERSTATED` earns its place. The characteristic failure of voice extraction
isn't inventing traits wholesale — it's taking something the author does
sometimes and encoding it as something they always do. A skill built from
overstated patterns produces a caricature: recognisably them, and unusably so.
Probe for it. When the author confirms a pattern, ask how often, and in what
context.

Take BORDERLINE items to them explicitly. That's what they're for.

**When the author contradicts the corpus, the author wins.** They know their own
writing better than a sample of it shows, and they know which pieces they'd
disown. Record the correction, and note the tension in a comment if the evidence
was strong — a pattern they reject but that's visibly all over the corpus is
worth one follow-up question, because sometimes it means the corpus contains
something they didn't realise wasn't native.

Annotate revisions inline as `<!-- PASS2: ... -->`, so Pass 3 can see what
changed and why. Strip them at finalisation.

## Pass 3 — Calibration

Generate sample passages using the revised draft — one per format the skill
claims to support — and have the author mark them up. Use prompts drawn from
things they'd plausibly write, not abstract exercises.

Each sample gets an overall verdict:

**GOOD** (ship it) · **CLOSE** (right register, wrong details) · **OFF** (not
them)

And each problem line gets a label that names what went wrong. The labels matter
because each one **maps to the section of `VOICE.md` that has to change** —
this is what turns a reaction into an edit:

| Label | Fix it in |
|---|---|
| `TOO_FORMAL` | Tone markers / register |
| `TOO_CASUAL` | Tone markers / register |
| `WRONG_WORD` | Vocabulary fingerprint, or the ban list |
| `LLM_ISM` | Ban lists |
| `NOT_ME` | Core voice patterns |
| `MISSING_PATTERN` | Whichever section should have caught it |

The codes are for you. With the author, say the plain phrase — "not you",
"sounds like AI", "too formal" — and translate it to the code when you record
the case.

Do not self-audit your own samples for LLM-isms before showing them. Checking
your own output with the same model that produced it is circular, and the
author's eye is the instrument you actually came here for. Show the samples
unpolished.

Keep going until samples come back GOOD consistently, and treat each round's
markings as permanent: **these markings are the regression suite.** Store each as
prompt + the author's verdict + the labels, because that's the format you'll
re-run against later.

## Emit the profile

You are not emitting a skill. The skill already exists — it is the one you are
running inside, it is public, and it is identical for every author. What you emit
is **data it reads**: four files in the profile directory you resolved at the top
of this document.

The split that matters is **generic method versus author-specific evidence**, and
it does not run between extraction and writing — it runs straight through the
middle of the writing rules. A ban on `in conclusion` is generic and already
ships in `../assets/`. A note that this author demonstrably uses one of the
listed words, with the pieces that show it, is evidence, and it belongs in the
profile. When in doubt,
apply the stranger test: if the line would be identical for another author, it
is method and does not go here.

**1. `VOICE.md`** — the applicator's rules, and the file loaded on every write.
Structure it in this order, which is by descending impact on the output:

1. **Ban-list deltas.** Not the generic list — the skill loads that itself from
   `../assets/`. What goes here is what the corpus changed about it: the
   **exceptions**, each with the quotation that earns it, the pieces it appears
   in, and the register it belongs to, plus any capped-not-banned items. A
   generic list over-suppresses; this file is what makes it corpus-checked.
   Do not cap how many exceptions there are; the criterion below is the filter.
2. **Anti-performative rules** — don't manufacture a catchphrase from one
   observed use; don't inflate an occasional habit into a signature. This section
   exists because the failure it prevents is the one authors find most
   embarrassing.
3. **Core voice patterns**, each with a golden sample the applying agent can hold
   its draft against before delivering. Concrete comparison beats abstract rules.
4. **Registers**, with one named as the default, and openings and closings broken
   out as their own subsections. Call them registers, not modes — `rewrite` and
   `edit` are modes, and reusing the word for `formal`/`personal` guarantees a
   confusion that costs a whole draft.
5. **What the two review sweeps check for this author.** The skill owns the
   two-sweep structure; this section says which of the sections above each sweep
   walks.

Write rules as prescriptions with wrong/right pairs. The pairs do more work than
any description — a demonstrated contrast is something a model can hold its draft
against, where an abstract quality is not.

**Correct in one direction only, and find out which direction it is.** The usual
failure is toward clean, neutral and tidy, so the default is to write rules that
penalise under-shooting and leave over-shooting alone: "if the sentence lengths
are all similar, vary them" rather than "keep sentence-length variance near the
author's". But do not assume the direction — Pass 3 tells you. An author whose
corrections all pull *away* from the literary needs the rule written the other
way round, and writing it backwards makes every draft worse. Record the direction
you found, in the author's own corrections, at the top of section 3.

The same asymmetry governs the ban lists. Derive them partly from what is
**absent** in the corpus — the constructions this author never reaches for are
sharper evidence than the ones they occasionally use — and check every candidate
against the corpus before it goes in. A word the author demonstrably uses in
clean, pre-AI writing is their word, whatever a generic list says.
Absence only earns a line when the item is *not* on a generic list already. If
a Spanish corpus has no `cabe destacar`, that confirms the list; writing it into
`VOICE.md` again fails the stranger test and costs context on every write.

**An exception has to be discriminative, not just present.** It exists to stop
the skill deleting something that sounds like the author. A word that is common
in AI prose and rare in theirs does the opposite: keeping it moves the output
toward the model. So weigh two things, not one — how widely *they* use it, and
how strongly it reads as generated:

- **Dispersion decides.** Admit a word only when it appears across several
  pieces, ideally across years or registers, cited by filename. One piece is an
  occurrence, not a habit, however often it repeats there.
- **The generic lists are the proxy for the AI side.** Each list has an
  *exception bar* table that sorts its sections into structural entries
  (connectives, openers, closers: high bar, many pieces spread over time),
  content words (normal bar), and shapes (never an exception; pin the real
  habit instead). Use that table rather than guessing the kind.
- **High AI frequency plus strong dispersion is the canonical exception**, not a
  reason to drop it: that is exactly the word a generic list would wrongly strip.
  What disqualifies is thin dispersion.

Some patterns are simultaneously the author's signature and a generic AI tell.
Don't ban those; flag **stacking**. One use is voice, three in a page is a tell.
Say so in the rule, and give the count.

**2. `VOICE_PROFILE.md`** — the patterns, evidence, and corpus notes, referenced
by `VOICE.md` rather than inlined. Keeping the evidence separate means the author
can correct a rule later by editing one short file, and means a review can cite
the proof without the writing path paying for it.

Hold every line in it to two standards, both of which exist to stop the profile
degrading into horoscope prose:

- **The stranger test.** If a line would apply unchanged to someone else's
  writing, it is describing writing in general, not this person. Delete it.
  "Clear and concise" and "professional but warm" describe every text ever
  written.
- **Attach a count to every adjective.** "Median 68 words; past 120 it stops
  sounding like them" is checkable against a draft. "Concise" is not. A number
  earns its place when the applying agent can actually count it in its own
  output — which is exactly why scalar style dials (`formality: 0.7`) fail: no
  model can tell whether its paragraph is 0.7 formal.

Record what you got wrong during the extraction, and what the profile is still
weak on. Both are load-bearing: the first stops the next run repeating your
mistakes, and the second is the only honest answer when the author asks how far
to trust a register nothing in the corpus covers.

**3. `GROUNDING.md`** — what the applying agent may assert as fact about the
author, and what it must verify first. Voice and biography get conflated
disastrously easily: an agent successfully imitating someone's confident register
will invent a job history, a client, or an anecdote in that same confident
register. Sounding like the author never licenses speaking for them. Give it
rows: what's safe to state, what needs checking, what's off-limits.

Dates deserve their own row. A relative reference in a post ("three years ago
this November") chained to a `date:` field you have already flagged as unreliable
produces a confident absolute year that is nobody's claim but yours. So record
the reference as the author wrote it, with the piece it comes from, and never
convert it to an absolute date: `"three years ago this November" (gym-post.md)`,
not `since November 2016, approx.`. Only a date the author states outright goes
in the safe row; "approx." marks a guess, and a guess belongs in "verify first".

**4. `regression/`** — the Pass 3 cases as prompt + golden sample + rubric,
alongside the held-out documents. Include a short README saying how to re-run
them, because the point is that they get re-run after a model upgrade or a corpus
refresh, and the person doing that may not be you.

A bilingual author gets one profile with shared rules plus per-language sections
— not two profiles, because it's one person. Name in `VOICE.md` which of the
skill's language assets apply.

## Validate before you hand it over

Generate against two or three prompts derived from the **held-out documents**,
then show the author their own text beside the generated version. This is the
only step in the process that can tell you something the author's approval
can't, because it's the only one where a right answer already exists.

Report honestly. If the held-out comparison is weak, say so even when Pass 3
went well — that gap is real information, and it usually means the corpus was
thinner than it looked.

Set expectations while you're there: a voice profile makes text read like the
author, and it reduces but does not eliminate AI-detector signal. Anyone who
tells you otherwise is selling something.

## When the profile already exists

Don't reach for a full extraction. `update.md` owns that path, and it is the
right one almost every time: a specific complaint is a five-minute edit to one
section of `VOICE.md`, not a rebuild. Come back here only when the corpus itself
turned out to be contaminated, or when new material is large enough to need a
fresh held-out draw and another round of Passes 2 and 3. In both cases keep the
existing profile as the starting draft — the author's accumulated corrections are
the most expensive information in it.

## Reference material

- `dimensions.md` — the eight dimensions in detail
- `corpus-qualification.md` — provenance triage, worked examples
- `regression-suite.md` — building and re-running the suite
- `../assets/profile-template.md` — skeleton for the emitted `VOICE.md`
- `../assets/es/llm-isms.md`, `../assets/en/llm-isms.md` — ban lists
- `../assets/shared/structural-tells.md` — language-independent patterns

## Attribution

The three-pass structure, the eight dimensions, the review and calibration
taxonomies, and the label-to-section mapping derive from
[sam-dumont/claude-skills](https://github.com/sam-dumont/claude-skills)
(MIT, Copyright (c) 2025 Sam Dumont). See `NOTICE` at the repository root.
