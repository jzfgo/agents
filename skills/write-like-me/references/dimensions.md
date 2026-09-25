# The eight dimensions

What to look for when characterising a corpus. Work through all eight — they're
ordered roughly by how much they shape a reader's sense of "this is them".

For every observation: cite a filename (or corpus tag) and quote the span. Then
classify it VOICE / PLATFORM / BORDERLINE. An observation without evidence and a
classification is not usable in Pass 2.

---

## A. Sentence patterns

The rhythm of the prose, which readers register before they register word choice.

- **Length distribution** — not just the average. Someone who alternates a
  40-word sentence with a 4-word one has a different voice from someone who
  writes 22 words every time, even though the means match. Look at the spread and
  at whether short sentences cluster (endings, emphasis) or scatter.
- **Fragments.** Deliberate ones. Do they occur, and where — for emphasis, in
  asides, at closings?
- **Subordination vs. coordination** — do clauses nest, or chain? Long
  subordinate structures read as considered; chains of `and`/`but`/`y`/`pero`
  read as spoken.
- **Openers** — how sentences begin. Conjunctions at sentence-start? Adverbial
  or prepositional lead-ins? Subject-first every time?
- **Parallelism and repetition** as deliberate devices, distinct from the
  mechanical triads under H.

## B. Opening patterns

How pieces start. Weighted heavily because it's the highest-variance,
highest-tell region of any text — the emitted skill needs its sharpest rules
here.

- Cold open, or scene-setting? Question, claim, anecdote, quote, definition?
- How long until the actual subject arrives? Some authors land it in the first
  clause; others earn it over a paragraph.
- Do they address the reader immediately? Establish stakes? Signal the shape of
  what's coming, or withhold it?
- **Catalogue the specific first sentences** across the corpus. Openings repeat
  structurally far more than authors realise, and the pattern is usually visible
  once the sentences sit next to each other.

## C. Vocabulary fingerprint

Word choice, at the level of individual lexical items.

- **Recurring content words** that aren't topic-driven. Topic words tell you
  what they write about; these tell you how they think.
- **Register**: formal / neutral / colloquial, and whether it shifts within a
  piece. Shifts are often the signature.
- **Technical density**, and whether jargon gets glossed. Who do they assume is
  reading?
- **Intensifiers and hedges** — the specific ones, and the rate. This is where
  authors differ sharply and predictably.
- **Profanity, slang, humour vocabulary**, if present. Note the contexts.
- **Loanwords and code-switching** — for bilingual authors especially, which
  terms stay in the other language and which get translated. Frequently the most
  distinctive single thing about a bilingual voice.
- **Words they conspicuously avoid** where you'd expect them. Harder to see, and
  worth the effort.

## D. Structural patterns

How a whole piece is built, and how it ends.

- **Argument shape** — thesis-first, or built toward? Problem/solution?
  Chronological? Digressive with a return?
- **Paragraph length and function.** Do paragraphs carry one idea, or accumulate?
- **Evidence habits** — block quotes, links, personal anecdote, data, appeals to
  authority. What counts as proof for this person?
- **Transitions** — explicit connectives, or juxtaposition without scaffolding?
- **Closings.** Treat these with the same weight as openings. Do they resolve,
  trail off, turn outward with a question, land a callback to the opening,
  undercut themselves with a joke? Generated text defaults to summary-plus-uplift
  closings, so a precise rule here pays for itself immediately.

## E. Tone markers

The author's posture toward the subject and the reader.

- **Certainty** — assertion vs. hedging, and whether hedges are genuine
  uncertainty or politeness.
- **Distance** — first / second / third person; direct address; inclusive "we".
  For Spanish specifically, the tú / usted / vosotros / ustedes choice is a
  strong and stable marker (see G).
- **Humour** — dry, absurd, self-deprecating, sarcastic? Where does it sit — in
  asides, or in the main line?
- **Self-presentation** — expert, peer, learner-in-public? Do they admit error,
  and how?
- **Emotional range.** Enthusiasm, irritation, affection. What actually moves
  this person, and how visible is it?
- **Reader relationship** — teaching, arguing, thinking aloud, entertaining?

## F. Formatting habits

The visual texture of the text. **Scrutinise this dimension hardest for
PLATFORM contamination** — more misclassifications happen here than in the other
seven combined, because formatting is where the medium's conventions are most
binding.

- Headings: frequency, depth, phrasing (noun phrases? questions? sentences?)
- Lists vs. prose, and what earns a list.
- Emphasis: bold, italics, caps. **Classify by job, not by rate.** List what each
  bold span does — a label in a key-value line, a heading, the conclusion of a
  block, a product or tool name, a word stressed for intensity — and write the
  rule as the jobs. Density follows content (a piece that names forty products
  carries forty bolds), so a global cap is meaningless; if you give a range,
  give it per structure: lists and running prose differ several-fold.
- **Count formatting only where it survived.** Conversion flattens it: plain-
  text email renders bold and italic identically, and markdown export of rich
  text loses size and weight distinctions. Use the HTML, the raw message, or the
  published page. A formatting rule extracted from converted text is fiction.
- **Formatting is often added at revision.** Material written on request without
  a revision pass can have none, and that absence is not evidence. Ask.
- Punctuation signature: em-dashes, parentheses, ellipses, semicolons,
  exclamation marks. Both which and how often. Parenthetical density in
  particular travels across media, so it's usually VOICE.
- Links: inline or referenced, and how anchor text is written.
- Code blocks, images, footnotes — presence and captioning style.

Ask of every item here: would this survive a move to email or a printed page? If
not, it's PLATFORM.

## G. Language-specific patterns

For bilingual and multilingual authors. The goal is **one voice with per-language
sections**, not two voices — the same person is writing.

- Which features are shared across languages (rhythm, argument shape, humour,
  posture) and which are language-bound?
- **Spanish**: form of address (tú / usted / vosotros / ustedes) and its
  consistency; peninsular vs. Latin American lexis; use of `—raya—` versus
  parentheses; diminutives; impersonal `se`; subjunctive habits; whether they
  write `pues`, `bueno`, `o sea` as discourse particles.
- **English**: British vs. American spelling and lexis; contraction rate;
  phrasal-verb preference versus Latinate single verbs.
- **Interference**, which is often the most characteristic thing present: syntax
  from one language showing through in the other. Note it, but be careful — the
  author may consider it an error rather than a trait. Ask in Pass 2.
- If part of the corpus turned out to be translated, it was excluded at intake.
  Do not quietly readmit it here.

## H. LLM-ism presence

Check the corpus itself for AI-generated tells, as a **contamination detector**,
not as a style observation.

If material flagged Native at intake is full of the patterns in
`../assets/shared/structural-tells.md` and the per-language ban lists, one of two
things is true: the intake triage missed something, or this author genuinely
writes that way. Both matter, and they need opposite responses.

- Contamination → go back to intake, re-bucket, and say so.
- Genuine → and this is the awkward case — a word on the ban list that the author
  demonstrably uses in clean, pre-AI writing is **their word**, and banning it
  makes the emitted skill worse. Record the exception with its evidence.

The second case is why the ban lists are filtered against the corpus rather than
applied wholesale. A generic list over-suppresses; a corpus-checked list doesn't.
