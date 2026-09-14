# Voz — Nuria Beltrán

> ⚠️ **PERFIL DE PRUEBA.** Nuria Beltrán no existe. Es una autora inventada para
> los evals de routing de `write-like-me`. Nada de este fichero describe a una
> persona real, no procede de ningún corpus real, y no debe usarse para escribir
> en nombre de nadie.

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
