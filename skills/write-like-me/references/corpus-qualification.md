# Corpus qualification

The gate before Pass 1. Its job is to answer one question: **is this text
actually evidence of this person's voice?**

Treat a failed gate as a real outcome. Stopping costs the author twenty minutes;
proceeding costs them a review cycle spent correcting patterns that were never
theirs, and leaves them holding an artifact that looks authoritative and isn't.

---

## The four buckets

**Native** — the author composed it, in the target language, without AI
assistance beyond spellcheck. This is the corpus. Everything else is out.

**Assisted** — AI drafted it, or edited it beyond light proofreading. Excluded
for the obvious reason: extract from it and you learn the model's voice, laundered
through the author's topic choices. This is the most dangerous bucket because
assisted text is fluent, on-topic, and often *feels* more like "good writing" than
the author's real prose, so it's the last thing anyone suspects.

**Translated** — the author wrote it, but composed it in another language first.
Excluded, and it's the bucket that gets forgotten, because the author genuinely
wrote it and remembers doing so. But a translator works against constraints a
composer doesn't: word choice is pinned to the source, and the rhythm is
inherited. What you extract is the author's ideas in a shape they didn't choose.

Translations aren't waste. They're good calibration material in Pass 3 — the
author can judge whether generated text sounds like them regardless of how the
reference came to exist.

**Not theirs** — clippings, saved articles, quoted material, co-authored work,
forwarded text. Excluded. In note-taking systems this is usually the majority of
the files, by a wide margin.

**A trap inside this bucket: writing done in an institutional voice.** Text the
author composed alone, in their own language, without AI — but *as* a company, a
team, or a publication. The tell is the first person plural: "our projects", "we
think", a byline that isn't personal. It passes every provenance check you'd
normally run, because on every axis except this one it is genuinely theirs.

It is still the wrong corpus. A house style is a set of constraints the author
was writing *inside*, and extracting from it gives you the constraints rather
than the person. Worse, it usually sits in the same directory as their personal
writing, separated only by date — someone's early posts written for an employer,
their later ones written for themselves. Blend the two and the profile averages
a corporate register with a personal one.

Check the pronouns and the intended byline, not just the authorship. When a
corpus splits this way, treat it the way you'd treat a date gap: surface it, ask
which voice is the target, and weight accordingly.

## Getting leverage on provenance

You cannot ask about documents one at a time, and the author cannot remember them
one at a time either.

**Ask for rules, not verdicts.** "Which folders hold things you wrote, versus
things you saved?" "Was there a point where you started drafting with AI?" "Do
any of these exist in another language first?" Authors answer these accurately
and fast, and one answer disqualifies a hundred files.

**Read the metadata before the prose.** A `url:` or `source:` field, an `author:`
that isn't them, a `clipped:` date, uniform frontmatter across hundreds of files —
these mark capture, not composition. Directory names carry the same signal:
`clippings`, `inbox`, `readwise`, `archive`, `references`.

**Look for pairing across languages.** Matching filenames under `es/` and `en/`,
a shared `translationKey`, parallel directory trees. One side is nearly always
derived. Determine which: check the site's default locale, ask, or read both and
see which one has language-specific habits the other lost. Native prose uses
idiom and forms of address freely; a translation of it tends to flatten them.

**Read the history, not only the content.** If the corpus lives in a repository,
its provenance is frequently written down in plain language and nobody thinks to
look. Commit messages say things like *"add English translations for 10 old blog
posts"*. Co-author trailers name the model that helped. Creation dates reveal
that a file dated 2008 was actually written last June.

This is the single highest-yield check available when it applies, because it is
testimony rather than inference — and it routinely contradicts the metadata. A
`date:` field in frontmatter is usually the *publication* date, so filtering on
it will happily admit files that were authored years later by someone, or
something, else. Run `git log --diff-filter=A` on a sample of files and read what
it says.

**But read the commit, not just the trailer.** A `Co-Authored-By` line means a
model touched that commit; it does not say what the model did. Migrating a blog
between static-site generators, renaming files, or rewriting frontmatter across a
tree all produce AI-co-authored commits containing prose the author wrote alone,
years earlier. Treat the trailer as a question, not a verdict — a corpus where
every file was moved once by tooling would otherwise be disqualified in full, and
the extraction would refuse over an artifact of the build system.

Distinguish them by what the commit message claims and what the content shows. A
message like *"add English translations"* is an authorship claim and the trailer
confirms it. A message like *"migrate posts to Astro"* is a move, and you can
confirm it is a move by looking for things a rewrite would have removed:
uncorrected typos, dead period-specific links, obsolete orthography, formatting
inconsistencies. Text that survived with its flaws intact was carried, not
regenerated.

**Sample the prose.** Read openings from a handful of files. Contaminated corpora
usually announce themselves — a run of documents that all open by restating the
title, or all close with a summary and an uplifting forward-look.

**Ask about the specific files you're unsure of.** Being unsure about five is
normal and worth a question. Being unsure about fifty means the rule-level
questions haven't been asked yet.

## Sufficiency, once provenance is settled

**Volume** — 10+ documents, with enough total text that a pattern can repeat
often enough to be a pattern. Below that you are extracting noise and presenting
it as signal.

**Variety** — two or more content types. This one gets waived more than it should
be, and it shouldn't: with a single content type you have no way to separate the
person from the format. Everything you observe is confounded, and the
VOICE/PLATFORM classification in Pass 1 becomes guesswork. If only one type is
available, say plainly that format modes will be weak, and consider a
self-interview to add a second.

**Recency** — prefer the last two years, and *look at the distribution rather
than the range*. A corpus spanning fifteen years is not a fifteen-year average; it
is usually two clusters with a gap. Surface it:

> Fourteen documents qualify, but ten are from 2007–2008 and four from 2020.
> That's two different writers a decade apart. Which is the target — recent
> voice, with the older material as background, or is the earlier voice the one
> you want back?

Then weight explicitly, and record the decision in `VOICE_PROFILE.md`. Silently
averaging across the gap produces a voice belonging to neither period.

**Length spread** — a mix of short and long. All-short tells you nothing about
how they sustain an argument; all-long tells you nothing about how they're brief.

## Reporting the gate

Say what you found, per bucket, with counts and the reasoning. The author needs
to be able to correct you — they know things about their own files that no
inspection reveals.

> **Qualified: 14 documents, ~10,000 words, Spanish.**
> **Excluded:** 2 documents (AI-assisted, per your rule about anything after
> March); 14 documents (English translations of the Spanish originals — the
> Spanish side has forms of address the English loses, so I've treated Spanish as
> the source); 2,100 documents (saved articles by other authors).
> **Gaps:** one content type only, and a twelve-year hole in the middle.

## Enrichment: harvest, then commission

Not only a fallback. Reach for it whenever a dimension came up short — which is
most of the time — and not merely when the gate failed outright. A corpus of
fourteen blog posts *qualifies*, and it still leaves you with no evidence about
how this person writes an email.

**Harvest before you commission.** The author almost certainly has the missing
material already: sent mail, chat history, issue comments, review threads.
Existing text is worth more than new text written for the exercise, because
nobody was watching when it was written and no brief shaped what went into it.
Ask for sources and date ranges; if a model or tool will do the searching, give
it the provenance rules (cut-off dates for AI assistance, which sources are
theirs) and ask for the raw message rather than a converted rendering, because
conversion destroys formatting evidence.

Anonymise work material before it is stored: people become roles, client names
become placeholders, and figures, credentials, addresses and internal URLs go.
A piece that cannot be anonymised without wrecking the prose is dropped.

**Record two axes per piece**, in the corpus table:

| Axis | Values | Why |
|---|---|---|
| Register | who it's for and why — client, team, friend, public | Channel does not decide register; a chat message to a client can be as formal as an email |
| Provenance | `harvested` or `commissioned` (+ the brief used) | Commissioned text is the weakest evidence and must never overrule harvested |

**Commission only for a named gap or a specific ambiguity** the harvest could not
resolve. Prescribe for what's missing, not a fixed list:

- Explain something you know well to someone who doesn't. *(register, technical
  density, reader relationship)*
- Disagree with something you read recently. *(certainty, argument shape,
  posture)*
- Deliver a piece of bad news. *(distance, hedging, closings)*
- Describe something that annoyed you this week. *(humour, emotional range,
  profanity)*
- Recommend something you love, to a friend. *(enthusiasm, informality)*
- Write the opening paragraph of a piece you've been meaning to write. *(openings,
  cold-start habits)*

Ask for the text **as they would send it, after their usual revision**, and store
the brief next to the piece. Do not say "don't polish": authors who add
formatting, fix typos or reshape sentences at revision will leave all of that
out, and the analysis will read the absence as a trait. The observer effect is
real, but the fix for it is harvested material, not an instruction that removes
half of the author's process.
