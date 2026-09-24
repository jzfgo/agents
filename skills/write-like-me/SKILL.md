---
name: write-like-me
description: >-
  Write, rewrite or review a text in the user's own voice, using a profile
  extracted from their own writing. Use it whenever they are producing something
  another person will read under their name — a post, an email, a client
  message, an issue, an internal note, a script — and whenever they say "write
  this", "draft this", "clean this up", "make it sound like me", or "stop making
  it sound like AI". Also handles building that profile in the first place, via
  `init`, from a corpus of their own writing ("capture my tone of voice", "build
  a style guide from my blog posts"), and correcting it afterwards via `update`
  ("it keeps saying X", "that doesn't sound like me"). When in doubt while writing for an
  audience, apply it: the cost of not applying it is prose that sounds like
  nobody. Not for editing a document to read better in general, and not for
  imitating a voice that isn't the user's own.
---

# Write like me

This skill is generic and identical for everyone. Everything author-specific
lives in a **profile** outside it, so the skill can be updated without touching
the profile and the profile never has to be published.

## Resolve the profile first

Before anything else, look for the profile, in this order:

1. `.write-like-me/` in the current project — a project can pin its own voice.
2. `~/.write-like-me/` — the user's default.

The local one wins outright when both exist; do not merge them.

**If neither exists, stop and say so.** Do not improvise a voice, and do not
start an extraction on your own:

> There's no voice profile yet, so I can't write in your voice. Run
> `/write-like-me init` and I'll build one from a corpus of your own writing —
> it's an interactive session and takes a while.

That is the whole response. `init` is long and expensive, and starting one the
user didn't ask for is worse than answering nothing.

## Choose a mode

An explicit mode word wins. Otherwise infer it.

```txt
init                                Build the profile from a corpus. Only on the literal word.
update                              Correct one rule in an existing profile. Cheap; prefer it.
rewrite                             Rewrite an existing text in their voice.
edit                                Touch the minimum; keep their structure and order.
review                              Say what doesn't sound like them, and why. Do NOT touch the text.
(no mode)                           Write from scratch in their voice.
```

Ask only when `review` and `rewrite` are equally plausible, because handing a
rewritten text to someone who asked for a critique is the most expensive of the
four mistakes: they lose the decision.

**`init` fires on the word, never on inference — `update` is what you almost
always want.** A complaint about the voice ("it keeps using dashes", "that
doesn't sound like me any more") is an `update`: one labelled fix to one section
of `VOICE.md`, plus a regression case, in five minutes. A full extraction is
23 minutes and a large token bill, and it discards every correction the author
has made since. Only re-extract when the corpus itself was wrong.

Load only what the mode needs:

```txt
write / rewrite   <profile>/VOICE.md + <profile>/GROUNDING.md + the language ban lists
edit              <profile>/GROUNDING.md; VOICE.md too if you'll change word choice
review            <profile>/VOICE.md + VOICE_PROFILE.md + regression/ cases
update            references/update.md + <profile>/VOICE.md + regression/
init              references/init.md, and nothing from the profile until it tells you to
```

The ban lists are this skill's own: `assets/es/llm-isms.md`, `assets/en/llm-isms.md`,
`assets/shared/structural-tells.md`. They are generic on purpose. **Filter them
through the exceptions in `VOICE.md` before applying them** — a word the author
demonstrably uses in their own clean writing is their word, and banning it makes
the output worse, not safer.

### What each mode does

**rewrite** — the text ends up said by them. Change order, split and join
sentences, and rewrite openings and closings wholesale; those are where voice
shows most.

**edit** — respect the structure, the paragraphs and the argument. Touch word
choice, punctuation, connectives and endings. If you find yourself moving
paragraphs, the mode was `rewrite`.

**review** — return a list of findings, each with the quoted line, what is wrong
with it in plain words ("sounds like AI", "too formal for this reader", "not how
you open a message"), and why, anchored to the profile in a way the author can
follow **without the profile open**: name the habit, not the section number —
"you open with the problem, not with a greeting", not "§4 Openings". **Do not
deliver rewritten text**, not even "as an example".

Write the review in the language of the draft under review. The label taxonomy
(`TOO_FORMAL`, `LLM_ISM`, `NOT_ME`, …) is internal routing for `update`; never
print a code to the author. A code they have to decode is a finding they skip.

**update** — follow `references/update.md`. Label the complaint, follow the label
to the section of `VOICE.md` it maps to, edit that section only, and add the case
to the regression suite so the fix stays fixed. Tell the author which section you
changed; they own the profile.

**init** — follow `references/init.md`. Full extraction from a corpus, or a
re-extraction when the corpus itself turned out to be contaminated.

## Before anything: don't invent

Applies to every mode. Sounding like someone does not license speaking for them,
and a text in their register of trust smuggles an invented figure past the reader
without a seam. Read `GROUNDING.md` before asserting any fact about the author,
their work, their history or their clients.

## Before delivering: the revision pass

Most authors write in two phases, and some traits only appear in the second:
formatting above all — bold, headings, italics on foreign words — but also typo
fixes and the odd sentence reshaped. If `VOICE.md` describes revision-phase
habits, apply them before you deliver. A text in their voice that skips their
revision reads like their unsent draft.

## Before delivering: two separate sweeps

They are different failure modes and one combined sweep catches neither.

**Sweep 1 — LLM-isms.** Walk the ban lists and the profile's deltas. Check the
closing: does it summarise? Rewrite it. Count the triads.

**Sweep 2 — performance.** Harder, and the one that survives the first sweep:

- Any word the author wouldn't say out loud? Replace it with the ordinary one.
- Have you used any single trait from the profile more than once? Drop one.
- Does it read like someone doing an impression of them, rather than like them?
  Strip ornament until it stops.

Sweep 2 has a direction, and it is not the same for everyone. `VOICE.md` records
which way this author's corrections pull. Follow it rather than assuming the
usual one.

## Reference material

- `references/init.md` — the extraction flow: intake, three passes, emission
- `references/update.md` — correcting a profile without rebuilding it
- `references/corpus-qualification.md` — provenance triage
- `references/dimensions.md` — the eight dimensions
- `references/regression-suite.md` — building and re-running the suite
- `assets/profile-template.md` — skeleton for a profile's `VOICE.md`

## Attribution

The three-pass structure, the eight dimensions, the review and calibration
taxonomies, and the label-to-section mapping derive from
[sam-dumont/claude-skills](https://github.com/sam-dumont/claude-skills)
(MIT, Copyright (c) 2025 Sam Dumont). See `NOTICE` at the repository root.
