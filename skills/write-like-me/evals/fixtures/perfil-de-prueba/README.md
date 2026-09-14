# Fixture: perfil de prueba

Perfil completo y **ficticio** que los evals de routing (4 y 5) necesitan tener
delante. Existe porque esos evals no miden una extracción: miden qué hace la
skill cuando el perfil **ya existe**, y para eso hace falta uno.

## Por qué vive exactamente aquí

- **No en `*-workspace/`**, que es donde están los artefactos de benchmark: ese
  patrón está en `.gitignore`. Un fixture ahí no sobrevive a un `clone` y el
  eval deja de ser reproducible fuera de esta máquina.
- **No en el cuerpo de la skill** (`references/`, `assets/`): el eval 3 afirma
  que no puede escribirse evidencia de un autor concreto dentro del directorio
  de la skill.
- **Bajo `evals/`** es material de prueba, no material que la skill cargue. La
  skill solo resuelve directorios que se llamen `.write-like-me/`; este se llama
  `perfil-de-prueba/`, así que no puede resolverse por accidente aunque viaje
  dentro del plugin.

## Por qué la autora es inventada

Nuria Beltrán no existe. Si el fixture fuese el perfil real de Javi:

1. El eval acabaría puntuándose por fidelidad de voz en lugar de por routing,
   que es lo único que mide.
2. Duplicaría material personal en un repo que sí tiene remoto público.
3. Cualquiera podría confundirlo con el perfil bueno de `~/.write-like-me/`.

Las citas, el corpus y las piezas de los ficheros son inventados enteros.

## Cómo se usa

**Se copia, no se apunta a él.** El modo `update` escribe en el perfil, así que
el run necesita su propia copia y el fixture tiene que quedar intacto:

```sh
cp -R skills/write-like-me/evals/fixtures/perfil-de-prueba "$RUN_DIR/.write-like-me"
```

El run arranca con `$RUN_DIR` como directorio de trabajo y **no se le dice dónde
está el perfil**: resolverlo es parte de lo que se mide. Que sea un
`.write-like-me/` local también es lo que protege el perfil real de
`~/.write-like-me/`, porque el local gana en el orden de resolución.

Al terminar, el estado del fixture es el criterio de dos assertions: el eval 4
tiene que haber tocado **solo** la sección 1 de `VOICE.md` (lo demás,
byte-idéntico) y el eval 5 no tiene que haber tocado **nada**.

## Los ganchos que llevan puestos

No los quites sin mirar qué assertion depende de cada uno:

| Gancho | Dónde | Para qué |
|---|---|---|
| `clave` como excepción con cita | `VOICE.md` §1 | es de lo que se queja el eval 4; el arreglo correcto es bajarla a «con tope», no borrarla |
| «Con tope, no prohibidas» ya poblada con `sin duda` | `VOICE.md` §1 | le enseña al run la forma del arreglo sin que el prompt se la sople |
| `potente` como excepción con cita | `VOICE.md` §1 | es el señuelo del eval 5: marcarla es un fallo |
| Aperturas / Cierres explícitos | `VOICE.md` §4 | dos de las cuatro infracciones plantadas en el eval 5 caen ahí |
| ⚠️ registros sin evidencia | `VOICE.md` §4 | hueco declarado, para que no se rellene solo |
| «Errores conocidos de la extracción» | `VOICE_PROFILE.md` | `update.md` obliga a anotar ahí; la sección ya existe para que se **añada**, no se cree |
| C1/C2/C3 | `regression/casos.md` | `update.md` manda relanzar la suite antes de tocar nada, y una suite que pierde casos en silencio reporta salud para siempre |
