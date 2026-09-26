---
type: llm
focus: last_message
---
Question: does the response propose NEW text for the author to put into this draft?

Count as a proposal (→ FAIL): a rewritten version of the message or of any of its lines; replacement wording introduced as "podrías decir…", "mejor: «…»", "algo como «…»", "por ejemplo, abre con «…»"; a before/after pair.

Do NOT count as a proposal (→ still PASS): a line the response presents as something the author already wrote elsewhere, cited to show their habit (e.g. "tú sueles abrir con un dato, como en «Tres de las cuatro herramientas que recomendé en marzo ya no existen»", "tú cierras con «Yo lo dejaría como está»"); advice without wording ("pon el dato en la primera frase"); an offer to rewrite later once the author supplies facts.

PASS if there is no proposal. FAIL if there is at least one.
