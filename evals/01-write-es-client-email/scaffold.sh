#!/usr/bin/env bash
# Stages the fixture profile (Nuria Beltrán) as a project-local .write-like-me/
# in the sandbox cwd. Self-contained: touches nothing outside cwd.
# The repo fixture's 'PERFIL DE PRUEBA' banners are stripped here: real profiles
# don't carry them, and with them the skill (correctly) refuses to write.
set -euo pipefail
mkdir -p .write-like-me/regression
cat > .write-like-me/VOICE.md <<'__WLM_FIXTURE_EOF__'
# Voz — Nuria Beltrán

Evidencia y notas de corpus en `VOICE_PROFILE.md`. Lo que puede afirmarse como
hecho sobre Nuria, en `GROUNDING.md`.

## Antes de escribir

Busca en `VOICE_PROFILE.md` la muestra del mismo formato más cercana y copia su
estructura, su párrafo y su ritmo. Imitar una pieza real acerca más que
cualquier regla de las de abajo; las reglas son la barandilla de lo que la
imitación no cubre.

## 1. Deltas de la lista de prohibidos

La skill carga las listas genéricas desde su propio `assets/`. Este fichero no
puede llegar a ellas por ruta y no debe intentarlo. Aquí solo va lo que el
corpus cambió.

### Prohibido también, para esta autora

- **El `nosotros` en piezas firmadas.** Escribe sola y firma sola. En el corpus
  no hay una sola primera persona del plural fuera de las notas internas.
- **El guion largo con espacios a los lados.** Usa coma, punto y coma o
  paréntesis. Cero apariciones en 11 piezas.

### Excepciones — palabras que las listas genéricas prohíben y que son suyas

No las quites.

| Palabra | Prueba |
|---|---|
| `clave` | «la pregunta clave no era cuánto costaba, era quién lo iba a mantener» (boletin-2024-03) |
| `potente` | «el argumento es potente y por eso me da pereza rebatirlo» (boletin-2024-09) |

### Con tope, no prohibidas

- `sin duda` — **máximo 1 por pieza**. Aparece 3 veces en 11 piezas, siempre
  cerrando un párrafo, nunca abriéndolo.

### Apilables, no prohibidas

- **La pregunta retórica.** Una por pieza es voz suya. Tres es un tic.

## 2. No interpretes la voz

Los patrones de abajo describen tendencias, no obligaciones.

- Una expresión usada una vez en el corpus no es una coletilla. «y ya está»
  aparece dos veces, las dos en 2023. No la conviertas en estribillo.
- Un hábito ocasional no es una firma. Nuria empieza a veces por una cifra; en
  todos los párrafos es una caricatura.
- No fabriques aspereza. Erratas puestas a propósito o incisos forzados para
  parecer humano leen peor que la prosa limpia. Nuria **no** quiere que se
  conserven sus erratas.

## 3. Patrones centrales

**Dirección de la corrección: hacia lo concreto.** Su fallo característico no es
sonar formal, es sonar abstracta. Cuando algo le suena mal, casi siempre es que
falta el dato, la cifra o el nombre del caso.

**Empieza por el dato, no por el marco**

| ❌ | ✅ |
|---|---|
| «La gestión documental es un reto creciente para las pymes.» | «Una asesoría de nueve personas me enseñó su carpeta compartida: 4.100 ficheros, ninguno con fecha en el nombre.» |

**Nombra el coste, no la ventaja**

| ❌ | ✅ |
|---|---|
| «Migrar te permitirá ganar agilidad.» | «Migrar te va a costar dos semanas malas. Lo que compras con ellas es dejar de pagar la licencia.» |

**Frase corta para rematar**

| ❌ | ✅ |
|---|---|
| «Por todo ello, resulta conveniente replantear el enfoque inicial.» | «Así que lo tiramos y empezamos otra vez.» |

## 4. Registros

Registros, no modos: `rewrite` y `edit` son modos, y reutilizar la palabra
garantiza una confusión que cuesta un borrador entero.

Por defecto: **boletín**, salvo que la tarea diga otra cosa.

| Registro | Trato | Persona | Cuándo |
|---|---|---|---|
| Boletín | `tú` | `yo` | su envío quincenal, entradas de blog |
| Correo a cliente | `tú` | `yo` | propuestas, avisos, malas noticias |
| Nota interna | `tú` | `nosotros` | documentos de equipo, actas |

⚠️ No hay evidencia de registro académico ni de nota de prensa. Si te piden uno,
dilo en voz alta en vez de inventarlo.

### Aperturas

Dato concreto, fecha o cifra en la primera frase. **Nunca escena, nunca
contexto de sector.** Ejemplos reales: «El martes me llamó un cliente que llevaba
once meses sin abrir su propio panel.» / «Tres de las cuatro herramientas que
recomendé en marzo ya no existen.»

### Cierres

La última frase es **una decisión o una pregunta directa al lector**. Nunca
resumen de lo dicho, nunca subida de tono, nunca «el futuro es prometedor».
Ejemplos reales: «Yo lo dejaría como está.» / «¿Tú qué harías con los 4.100?»

## 5. Qué revisa cada barrido

**Barrido 1 — LLM-ismos:** secciones 1 y 4. Contar en concreto: `sin duda`
(máximo 1), preguntas retóricas (máximo 2), guiones largos (cero).

**Barrido 2 — interpretación:** secciones 2 y 3. La pregunta que caza casi todo
en Nuria: *¿esta frase se sostiene sin un dato detrás?* Si se sostiene, sobra.
__WLM_FIXTURE_EOF__
cat > .write-like-me/VOICE_PROFILE.md <<'__WLM_FIXTURE_EOF__'
# Perfil de voz — Nuria Beltrán (evidencia)

## Corpus

Extracción del 2025-11-04. Todo el material es prosa nativa de la autora; no hay
traducciones ni material asistido.

| Etiqueta | Formato | Piezas | Palabras |
|---|---|---|---|
| `boletin-2023-*` | boletín quincenal | 5 | 3.100 |
| `boletin-2024-*` | boletín quincenal | 4 | 2.400 |
| `correo-2024-*` | correo a cliente | 2 | 600 |
| **Total analizado** | | **11** | **6.100** |
| `boletin-2025-01` | reservado, sin leer | 1 | 700 |

Las frecuencias están **ponderadas por documento**, no por palabra: el boletín
más largo tiene 4 veces la extensión del más corto y por palabra fijaría él solo
las tasas.

## Huecos conocidos

- **Un solo formato dominante.** Nueve de once piezas son el mismo boletín. El
  registro de correo a cliente se apoya en dos piezas y 600 palabras: trátalo
  como INFERRED.
- **Sin registro académico ni nota de prensa.** Marcados con ⚠️ en `VOICE.md`.
- **Sin material anterior a 2023.**

## Errores conocidos de la extracción

Cosas que este proceso ya se equivocó una vez. Quien vuelva a correr `init`
necesita saberlo para no repetirlas.

1. **`clave` clasificada como LLM-ismo y prohibida en el primer borrador.** La
   autora lo desmintió en Pass 2: es palabra suya y la usa en posición
   predicativa, no pegada al sustantivo. Pasó a la tabla de excepciones de
   `VOICE.md` §1 con su cita.
2. **La frase corta final, dada por regla de formato.** El primer borrador decía
   que remataba corto «en boletín». Aparece también en los dos correos, así que
   es de voz y no de canal. Corregido en §3.
__WLM_FIXTURE_EOF__
cat > .write-like-me/GROUNDING.md <<'__WLM_FIXTURE_EOF__'
# Grounding — Nuria Beltrán

Sonar como alguien no autoriza a hablar por esa persona. Antes de afirmar
cualquier hecho sobre Nuria, su trabajo o sus clientes, lee esto.

## Puede afirmarse

- Que escribe un boletín quincenal y que lleva escribiéndolo desde 2023.
- Que trabaja sola.

## No puede afirmarse nunca

- **Nombres de clientes.** En el corpus aparecen descritos por tamaño y sector
  («una asesoría de nueve personas»), nunca por su nombre. Mantén esa forma.
- **Cifras de negocio, precios o número de suscriptores.** No hay ninguna en el
  corpus.
- **Opiniones sobre herramientas o personas concretas** que no estén citadas
  literalmente en `VOICE_PROFILE.md`.

Si un texto necesita uno de estos datos, deja un hueco marcado y pregunta. Un
dato inventado en su registro de confianza pasa sin costura y es el fallo más
caro que puede cometer este perfil.
__WLM_FIXTURE_EOF__
cat > .write-like-me/regression/casos.md <<'__WLM_FIXTURE_EOF__'
# Suite de regresión — Nuria Beltrán

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
__WLM_FIXTURE_EOF__
