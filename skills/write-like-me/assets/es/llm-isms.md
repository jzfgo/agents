# LLM-ismos en español

Lexis and phrasing that mark Spanish text as machine-generated. Pair this with
`../shared/structural-tells.md`, which covers the language-independent
shapes — the triad, the scene-setting opening, the summary-plus-uplift close —
all of which are at least as common in Spanish as in English.

**Provenance.** Items are marked by how well attested they are:

- **[A]** — high confidence, and unusually characteristic of generated Spanish.
- **[B]** — common in generated Spanish, but also common in ordinary formal
  register (journalism, corporate writing, academia). Suppress with judgement.
- **[?]** — plausible and worth watching; not yet verified against a corpus.

> **Verification status.** This list is drawn from observed patterns and has not
> yet been checked against a measured corpus of Spanish LLM output the way
> English lists have been against Kobak et al. (2025) and Liang et al. (2024).
> Nothing equivalent has been published for Spanish — which is why this file
> exists, and why it should be treated as a strong v1 rather than as settled.
> The `[?]` items in particular deserve a corpus pass.

**Exception bar — a second axis, separate from confidence.** When a profile
wants to keep one of these as the author's own (`references/init.md`, ban-list
deltas), how much evidence it needs depends on the *kind* of entry, not on its
[A]/[B] mark. This file has no measured AI frequencies. The kind is the proxy
for how strongly an entry reads as generated.

| Section | Kind | Bar for an exception |
|---|---|---|
| Muletillas de importancia, Aperturas, Cierres, Conectores sobreutilizados | Structural: connectives, openers, closers, signposting | **High.** Many pieces, spread over years or registers. These read as generated on sight, so a thin sample keeps them banned |
| Adjetivos inflados, Verbos y calcos del inglés | Content words | **Normal.** Several pieces, cited by filename |
| Registro y forma | Shape, not lexis | Not an exception candidate. Pin the author's actual habit in the profile instead |

**Check every entry against the author's own corpus before applying it.** Spanish
generated text drifts toward a neutral, faintly journalistic register, so the
overlap with legitimate formal Spanish is much larger than in English. Banning
`fundamental` outright will damage the voice of anyone who writes essays.

---

## Muletillas de importancia

Announcing significance instead of demonstrating it. The single densest category
in generated Spanish.

- **cabe destacar / cabe señalar / cabe mencionar / cabe resaltar** — **[A]**.
  The strongest single marker in this file. Rare in unselfconscious writing,
  near-ubiquitous in generated prose.
- **es importante destacar / señalar / mencionar / tener en cuenta / recordar** —
  **[A]**
- **conviene señalar / no está de más recordar** — **[B]**
- **cabe preguntarse** — **[?]**, especially as a manufactured pivot
- **es imperativo / resulta imprescindible** — **[A]**. Manufactures an urgency
  the argument has not earned. Ordinary Spanish says `hay que` or `tenemos que`.
- **hay que tener presente que** — **[B]**

## Adjetivos inflados

Not banned — *rate-limited*. Each is ordinary Spanish; what marks generated text
is density, and the habit of attaching one to every noun.

- **clave** — **[A]** as a post-nominal adjective (`el factor clave`, `un aspecto
  clave`). Count them: more than one or two in a piece is a tell.
- **fundamental**, **esencial**, **crucial**, **primordial**, **vital** — **[B]**
- **robusto** — **[A]** when applied to software or process. A calque of
  *robust*; natural Spanish prefers `sólido`, `fiable`, `estable`.
- **potente / poderoso** — **[B]**, especially `una herramienta poderosa`
- **innovador**, **revolucionario**, **disruptivo** — **[B]**
- **integral**, **holístico** — **[?]**
- **versátil**, **escalable** — **[B]** in technical writing
- **Intensificadores en -mente**: `sumamente`, `enormemente`, `tremendamente`,
  `increíblemente`, `notablemente` — **[A]** as a class. Spanish speakers reach
  overwhelmingly for `muy` + adjective; a piece with several -mente intensifiers
  and no `muy` is almost certainly generated. Count the author's `muy` and
  `mucho` against these before deciding a threshold.

## Verbos y calcos del inglés

Where generated Spanish most visibly shows its English substrate.

- **desbloquear** for *unlock* (in the figurative sense: `desbloquea tu
  potencial`) — **[A]**. A calque; Spanish unlocks doors, not potential.
- **navegar por** for *navigate* (figurative: `navegar por el panorama`) —
  **[A]**
- **panorama** / **paisaje** for *landscape* (figurative) — **[A]**
- **aprovechar** used as a flat rendering of *leverage* — **[B]**
- **impulsar**, **potenciar**, **empoderar** — **[B]**. `Empoderar` especially
  outside explicitly political contexts.
- **abordar** for *address* — **[B]**
- **profundizar en** / **adentrarse en** / **sumergirse en** — **[A]** as an
  invitation to the reader (`sumérgete en`, `adéntrate en`)
- **transformar la manera en que** — **[A]**
- **jugar un papel fundamental** — **[A]**. Calque of *play a key role*;
  natural Spanish is `desempeñar un papel` — and more often, just say what it
  does.
- **en última instancia** for *ultimately* — **[B]**
- **construir** for *build* in abstract senses (`construir confianza`) — **[?]**
- **maximizar** / **minimizar** outside genuinely technical contexts — **[B]**.
  Calque of *maximize*; natural Spanish says `aprovechar al máximo`, `sacar el
  máximo partido`, or simply names the improvement.

## Aperturas

Scene-setting before the subject arrives.

- **en el vertiginoso mundo de** — **[A]**
- **en la era digital / en la era de la IA** — **[A]**
- **en un mundo cada vez más [adjetivo]** — **[A]**
- **hoy en día** as an opener — **[B]**
- **a medida que la tecnología avanza** — **[A]**
- **imagina por un momento / imagina que** — **[B]**
- **¿Alguna vez te has preguntado…?** — **[A]**
- **A continuación, te presento / te explico** — **[A]**, especially as a
  hinge into a list

## Cierres

Where generated Spanish is most uniform.

- **en resumen / en conclusión / en definitiva / en pocas palabras** — **[B]**
  as a closing marker; **[A]** when the piece is short enough not to need one
- **sin duda / sin lugar a dudas** — **[B]**
- **el futuro de X es prometedor** — **[A]**
- **ya seas principiante o experto** — **[A]**
- **así que… ¡manos a la obra!** / **¡a por ello!** — **[A]**
- **Recuerda que…** as a closing directive — **[B]**
- **Espero que esto te sirva / te haya sido útil** — **[A]** outside genuine
  correspondence

## Conectores sobreutilizados

Individually fine; the tell is one at the head of nearly every paragraph.

- **además**, **asimismo**, **por otro lado**, **en este sentido**, **de igual
  manera**, **cabe añadir** — all **[B]**, all worth counting
- **no solo… sino también** — **[A]**. The Spanish rendering of *not just X but
  Y*, and just as overused.

  **Ban the completion, not the opening.** `no solo…` is ordinary Spanish and
  continues in several directions; only `sino también` is the tell. `no solo… sino
  que` is a different construction — it coordinates clauses rather than stacking a
  second complement — and plenty of writers use it naturally while never once
  writing `sino también`. A rule that keys on `no solo` alone, or that treats the
  two as one entry, will strip a construction the author actually uses. Check them
  separately against the corpus; they can land in opposite buckets for the same
  person.
- **Adicionalmente** — **[A]** at the head of a paragraph. A calque of
  *Additionally*, and rarer in unselfconscious Spanish than `además` — which is
  itself worth counting.
- **tanto… como…** — **[B]** when stacked
- **ya sea… o…** — **[B]**
- **a la hora de** — **[B]**; usually a wordy substitute for `al` + infinitive

## Registro y forma

Not vocabulary, but where generated Spanish gives itself away structurally.

- **Register flattening** — **[A]**. Output drifts to a neutral pan-Hispanic
  formal register: no regional lexis, no colloquialism, no slang, no profanity,
  and a conspicuous absence of discourse particles (`pues`, `bueno`, `o sea`,
  `en fin`, `vamos`) that natural Spanish uses constantly.
- **Address avoidance** — **[A]**. Generated text avoids committing to
  tú/vosotros/usted/ustedes, preferring impersonal `se` and infinitives. A
  peninsular writer who uses `vosotros` naturally will lose it entirely. Check
  the author's actual form of address and pin it.
- **Diminutive absence** — **[?]**. Spanish uses diminutives for register and
  affect far beyond size. Generated text almost never does.
- **Anglo em-dash spacing** — **[B]**. Spanish raya takes no space on the inner
  side (`—como esta—`). English-style ` — ` spacing is an import.
- **Ordinal-heavy structure** (`En primer lugar… En segundo lugar…`) — **[B]**
  in prose that isn't a procedure.
- **Excessive bolding of key terms** — **[B]**; see the shared file.
- **Translated idiom** — **[A]**. Idioms rendered literally from English
  (`al final del día` for *at the end of the day*, `el elefante en la
  habitación`). Natural Spanish has its own; a writer who reaches for idiom will
  reach for Spanish ones.

---

## Cómo usar esta lista

1. **Filter against the corpus first.** Any entry the author demonstrably uses in
   clean, pre-AI writing is theirs. Record it as an exception with the quote that
   proves it, and do not strip it.
2. **Prefer thresholds to prohibitions** for everything marked **[B]**. `clave`
   is a real Spanish word; four of them in a page is the problem.
3. **Weight [A] items heavily** in the emitted skill's ban list, and put the
   openings and closings sections first — that's where the density is.
4. **Treat [?] items as watch-list**, not ban-list, until a corpus confirms them.
5. Derive additional entries from **absence**: constructions this author never
   uses, but that generated text reaches for, are the sharpest possible evidence
   and are specific to them in a way a generic list can never be.
