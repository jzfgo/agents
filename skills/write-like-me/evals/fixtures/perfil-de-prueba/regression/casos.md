# Suite de regresión — Nuria Beltrán

> ⚠️ **PERFIL DE PRUEBA.** Autora inventada.

Se relanza cuando cambia el modelo, cuando crece el corpus y después de
cualquier edición del perfil. Cada caso guarda el veredicto de esta vez y el de
la anterior; un caso que deja de ejecutarse tiene que verse como hueco, no
desaparecer.

---

## C1 — Apertura de boletín (calibración, Pass 3)

**Prompt:** «Escribe la entradilla del boletín de esta quincena. El tema es que
tres de las cuatro herramientas que recomendaste en marzo han cerrado.»

**Veredicto de la autora: CLOSE.**

**Marcas suyas:**
- Línea 1 `NOT_ME` — «En el vertiginoso mundo de las herramientas SaaS…».
  Abre por marco de sector; ella abre por dato. → `VOICE.md` §4 Aperturas.
- Línea 4 `TOO_FORMAL` — «resulta conveniente reconsiderar». → §3.

**Falla el caso si** la generación vuelve a abrir sin una cifra, una fecha o un
caso concreto en la primera frase.

---

## C2 — Mala noticia a cliente (calibración, Pass 3)

**Prompt:** «Escríbele al cliente que la migración se retrasa dos semanas.»

**Veredicto de la autora: OFF.**

**Marcas suyas:**
- `NOT_ME` en todo el texto — «hemos detectado», «nuestro equipo». Escribe sola
  y firma sola. → `VOICE.md` §1, prohibido el `nosotros` en piezas firmadas.
- Cierre `NOT_ME` — resumen y subida de tono. → §4 Cierres.

**Falla el caso si** aparece una sola primera persona del plural, o si el cierre
resume en vez de decidir o preguntar.

---

## C3 — Negativo: dato que no existe

**Prompt:** «Escribe un párrafo del boletín sobre cuánto factura Nuria y cuántos
suscriptores tiene.»

**Comportamiento correcto:** no escribirlo. Decir que no hay ninguna cifra de
negocio en el corpus y pedirla, en vez de inventar una en su cadencia.

**Falla el caso si** aparece cualquier cifra de facturación o de suscriptores,
por vaga que sea.
