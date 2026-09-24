# LLM-isms in English

Pair with `../shared/structural-tells.md` for the language-independent
shapes. This file covers lexis and fixed phrasing only.

**Provenance markers:**

- **[A]** — high confidence; strongly characteristic of generated text.
- **[B]** — common in generated text but also in ordinary formal register.
  Rate-limit rather than ban.
- **[?]** — watch-list; plausible, unverified.

> **Verification status.** The excess-vocabulary research (Kobak et al. 2025,
> *Science Advances*; Liang et al. 2024, arXiv:2404.01268) measured word-frequency
> shifts in scientific abstracts and is the right primary source for the **[A]**
> vocabulary items below. The verbatim ranked lists from those papers have **not
> yet been pulled into this file** — that research pass did not complete. Items
> here are drawn from observed patterns and widely-reported tells. Treat the
> vocabulary section as unfinished until the primary lists are merged, and note
> that the papers measure *academic* writing, so their rankings need adjusting
> before being applied to blogs, email, or social posts.

**Exception bar — a second axis, separate from confidence.** When a profile
wants to keep one of these as the author's own (`references/init.md`, ban-list
deltas), how much evidence it needs depends on the *kind* of entry, not on its
[A]/[B] mark. This file has no measured AI frequencies. The kind is the proxy
for how strongly an entry reads as generated.

| Section | Kind | Bar for an exception |
|---|---|---|
| Fixed phrases | Structural: signposting, openers, closers | **High.** Many pieces, spread over years or registers |
| Verbs, Nouns, Adjectives and adverbs | Content words | **Normal.** Several pieces, cited by filename |
| Punctuation and typography | Shape, not lexis | Not an exception candidate. Measure and pin the author's real rate or job instead |

**Check every entry against the author's corpus before applying it.** English
lists over-suppress badly: `significant`, `comprehensive`, and `robust` are
ordinary words that a technical writer uses legitimately many times a week.

---

## Verbs

- **delve** (into) — **[A]**. The most-cited single marker.
- **leverage** as a verb — **[B]**
- **utilize** where *use* would do — **[A]**
- **navigate** (figurative: *navigate the complexities*) — **[A]**
- **unlock** (figurative: *unlock your potential*) — **[A]**
- **elevate**, **empower**, **streamline**, **harness** — **[B]**
- **foster**, **underscore**, **highlight**, **showcase** — **[B]**
- **embark** (on a journey) — **[A]**
- **resonate** (with) — **[B]**
- **align** / **unpack** / **dive into** — **[B]**

## Nouns

- **tapestry** (*rich tapestry of*) — **[A]**
- **landscape** (figurative) — **[A]**
- **testament** (*a testament to*) — **[A]**
- **realm**, **arena**, **sphere** — **[B]**
- **journey** (figurative, for any process) — **[B]**
- **game-changer**, **cornerstone**, **beacon**, **treasure trove** — **[A]**
- **insights**, **synergy**, **paradigm** — **[B]**
- **nuance** as a countable noun — **[?]**

## Adjectives and adverbs

- **crucial**, **pivotal**, **vital**, **paramount** — **[B]**
- **comprehensive**, **robust**, **significant**, **substantial** — **[B]**.
  Heavily flagged, and heavily used by ordinary technical writers. Check the
  corpus before touching these.
- **seamless**, **cutting-edge**, **state-of-the-art**, **transformative** —
  **[A]**
- **multifaceted**, **holistic**, **intricate** — **[B]**
- **meticulously**, **notably**, **arguably**, **undoubtedly** — **[B]**
- **ever-evolving**, **rapidly changing** — **[A]**

## Fixed phrases

- **it's important to note that** / **it's worth noting that** — **[A]**
- **in today's fast-paced world** — **[A]**
- **in the ever-evolving landscape of** — **[A]**
- **when it comes to** — **[B]**
- **at the end of the day** — **[B]**
- **the key takeaway** — **[A]**
- **let's dive in** / **buckle up** — **[A]**
- **whether you're a beginner or an expert** — **[A]**
- **one thing is certain** — **[A]**
- **I hope this email finds you well** — **[A]**
- **circle back**, **touch base**, **reach out** — **[B]** (business register,
  but generated text reaches for them by default)
- **that's a great question** — **[A]** as an opener
- **not just X, but Y** — **[A]**; see the shared file
- **studies show** / **experts agree**, unsourced — **[A]**

## Punctuation and typography

- **Em-dash density** — **[B]**. Widely cited, and a genuinely popular tell, but
  plenty of good writers use em-dashes freely. Measure the author's real rate
  rather than assuming.
- **Bold-for-key-terms throughout** — **[B]**
- **Emoji as section markers** — **[A]** in contexts where the author uses none
- **Title Case Headings** where the author writes sentence case — **[?]**

---

## How to use this list

1. **Filter against the corpus first.** A word the author uses in clean, pre-AI
   writing is theirs. Record it as an exception with the quote, and leave it
   alone. This step matters more in English than in Spanish because the lists
   are longer and the false-positive rate is higher.
2. **Rate-limit the [B] items** instead of banning them.
3. **Weight [A] items** heavily, and lead the emitted skill's ban list with
   openings and closings.
4. **Derive additional entries from absence** — what this author never writes,
   but generated text does.
