# Perfil de voz — Nuria Beltrán (evidencia)

> ⚠️ **PERFIL DE PRUEBA.** Autora inventada. Ni el corpus ni las citas de este
> fichero existen fuera de los evals de `write-like-me`.

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
