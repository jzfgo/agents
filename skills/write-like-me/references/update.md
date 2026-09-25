# `update` — fix a profile without rebuilding it

Most complaints about a voice profile are not extraction failures. They are one
rule that is wrong, overstated, or missing. `update` is the cheap path, and it is
the right one almost every time.

**Never re-run a full extraction by reflex.** A rebuild throws away every
correction the author has made since the profile was written, and those
corrections are the most expensive information in it — each one cost the author
reading a generated sample and saying precisely what was off. If the fix turns
out to need a real re-extraction, `init` handles that and knows to keep the
existing profile as its starting draft.

Resolve the profile the way `SKILL.md` does: project-local `.write-like-me/`
first, then `~/.write-like-me/`. If there is none, this is an `init`, not an
update — say so and stop.

Run the regression suite first (`regression-suite.md` explains how to read the
results), then match the fix to what the suite tells you:

**A specific complaint** — "it keeps using em-dashes", "it opens every reply with
a question". Treat it as a Pass 3 marking: label it, follow the label to the
section it maps to, edit that section, and add the case to the suite so the fix
stays fixed. This is a five-minute job, not an extraction.

**Drift after a model change** — the profile is still accurate but the rules are
landing differently. Look for rules written as tendencies rather than as
checkable instructions, and sharpen those. The corpus is not the problem.

**"It doesn't sound like me any more"** with no specific complaint — usually the
author has moved rather than the profile. Ask for three recent pieces and compare
them against the profile. If they've genuinely drifted apart, extend the corpus
with the new material and re-run Passes 2 and 3 — but keep the existing profile
as the starting draft rather than beginning from nothing.

**New corpus material** — fold it in, hold out a fresh slice of it before
analysing, and re-run the suite. A held-out set that has already been read is not
held out, so never reuse the old one to validate a profile it helped build.

Before any new piece counts as evidence, ask the author which of them the profile
helped write. Once a profile exists, the author uses it, and anything drafted or
polished with it carries the profile's own rules back in. Analysing that material
confirms the profile against itself, and a tic the profile introduced comes back
as a pattern the author "has". The same goes for the three recent pieces above.
Keep what the author wrote alone; set aside what the profile touched, and say
which pieces you set aside.

Full re-extraction is right in one case: the original corpus turned out to be
contaminated. If material was translated, AI-assisted, or not the author's, then
the patterns built on it are unsound and no amount of patching fixes that. Go
back to intake and say plainly why you're starting over.


## Decide what the evidence settles; return only what it can't

When the fix is evident from the corpus or the complaint, make it — the author
can always object afterwards. Escalate only what the author alone knows:
preference, intention, identity. If a request contains a contradiction the
evidence cannot resolve, still make the edits that are clear, and return the
contradiction marked beside them. One action plus a flagged residue, never a
question in place of the action.

## Always close the loop

Whatever the fix, do these two things or it will come back:

1. **Add the case to the regression suite** — the author's complaint, in their
   words, plus the corrected output. A fix with no case is a fix that silently
   regresses on the next model change.
2. **Record it in `VOICE_PROFILE.md`** under the extraction's known errors. The
   next person to run `init` needs to know this pattern was already gotten wrong
   once, and how.

Then tell the author which file and which section you changed, in one line. They
own the profile; a silent edit to it is worse than no edit.
