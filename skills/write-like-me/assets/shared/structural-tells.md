# Structural tells (language-independent)

Patterns that mark generated text regardless of language, because they're
artifacts of how models compose rather than of any vocabulary. Translating a
document doesn't remove them, which is what makes them the most durable part of
any ban list.

Apply these to every language. The per-language files handle lexis; this file
handles shape.

**Exception bar.** Everything here is shape, not lexis. None of it goes into a
profile's exceptions table. When the author really uses a shape (triads,
summary closes), record it as a *stacking* rule with a count, backed by
several pieces.

**Before applying any of it, check the corpus.** These are tendencies of
generated text, not crimes. A writer who genuinely favours triads should keep
their triads — see *Stacking* at the end.

---

## The triad

Three parallel items where the content justifies one or two. `fast, simple, and
reliable`. `rápido, sencillo y eficaz`. The most reliable single tell across
languages, and the hardest for a model to stop doing, because three items feel
complete in a way two doesn't.

Watch for it at every scale: three adjectives, three clauses, three bullets,
three paragraphs, three sections. Also for the **triad of triads**, where a piece
has one in the opening, one in the middle, and one in the close.

## Not just X, but Y

`It's not just a tool, it's a philosophy.` `No es solo una herramienta, es una
filosofía.` A construction that asserts depth through syntax alone, then usually
declines to supply any. Includes: *more than just*, *isn't merely*, *goes beyond*.

Related: **the false-contrast pivot** — `It's not about X. It's about Y.` — where
X was never seriously in contention.

## Scene-setting openings

Establishing a landscape before arriving at the subject. `In today's fast-paced
world…`, `As technology continues to evolve…`, `Picture this:`. The tell isn't
the specific phrase, it's the shape: two or three sentences of throat-clearing
that could preface any piece on any topic.

The test: delete the first paragraph. If nothing is lost, it was scene-setting.

## Summary-plus-uplift closings

Restate the argument, then turn outward on a forward-looking note. `Whether
you're a beginner or an expert, …`, `One thing is certain: …`, `The future
of X is bright.` Pairs with a rhetorical question aimed at the reader.

Closings are where generated text is most uniform, because the model is
completing a shape rather than finishing a thought.

## Importance-flagging

Announcing that something matters rather than showing it. `It's important to
note that`, `Crucially`, `The key takeaway is`. Real writers make things matter
by their placement; generated text labels them.

Related: heavy **adverbial hedging at both ends** — `arguably`, `it could be
argued`, `generally speaking`, `in many cases` — where the writer is neither
committing nor genuinely uncertain.

## Mechanical parallelism

Every bullet in a list built to the same grammatical pattern and roughly the same
length. Every section under a heading of the same depth. Human lists are ragged:
items differ in length, some are fragments, one runs long because it needed to.

## Uniform sentence length

Long stretches where every sentence lands within a few words of the same count.
Human prose varies sharply — a long subordinate structure, then four words.
The variance itself carries meaning; its absence reads as flat even when no
individual sentence is wrong.

## Bilateral hedging

Presenting both sides and declining to land. `While X has advantages, it also
has drawbacks.` Fine once. As a habit, it's the model avoiding commitment, and
it's especially visible in a corpus by an author who normally argues.

## Empty specificity

Numbers, categories, and structure that carry no information. `There are three
main considerations` (when there are as many as you like), `studies show`,
`experts agree`, `up to 40% more efficient` with no source.

## Sycophantic framing

Opening by praising the question or the reader. `Great question!`, `That's a
really interesting point.` Also self-congratulatory transitions: `Now here's
where it gets interesting.`

## Section-heading disease

Imposing headed sections on something short enough to be prose. A 400-word piece
with four H2s is a shape decision no human makes, and it's especially wrong in
email, chat, and short-form writing.

## Emphasis inflation

Bolding key terms throughout, to the point that the bolding stops marking
anything. Ask what the bold is *for*: navigation in a long reference document is
legitimate, decoration in an argument is not.

---

## Stacking, not banning

Several of these are legitimate moves that most good writers use occasionally.
Triads exist because three is genuinely a good number of examples. Parallelism is
a real rhetorical device.

So the rule for anything in this file that the corpus shows the author actually
using: **count, don't ban.** One triad in a piece is voice. Four is a tell.
Record the author's real rate from the corpus and write the rule as a threshold,
not a prohibition — a skill that forbids a writer's own devices produces text
that avoids sounding like a model by not sounding like anyone.
