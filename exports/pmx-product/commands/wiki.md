---
description: "Wiki de empresa: ingestar artículos/reuniones/notas, sintetizar entidades/conceptos, mantener índice/log/tags. Modos: ingestar, anotar, articulo, reunion, nota, etiqueta, vincular, revisar, buscar. Ejecuta age-spe-wiki-curator."
---

# /wiki — Wiki de empresa

Curator transversal del conocimiento de empresa. Procesa raw sources (artículos, reuniones, notas, transcripciones), extrae entidades/conceptos, mantiene una wiki sintética con wikilinks `[[...]]`.

**Es transversal a todas las áreas** (Producto, Marketing, RRHH, Operaciones). A diferencia del PM (uno por área), la wiki es global. Los conocimientos de Marketing y los de Producto comparten entity pages, concept pages y tags.

## Sintaxis

```
/wiki ingestar <path>             → procesa un raw source y lo integra
/wiki anotar <texto>              → captura una nota rápida e ingesta
/wiki articulo <path-o-url-texto> → crea artículo + ingesta
/wiki reunion <título>            → crea plantilla de reunión nueva
/wiki nota <texto>                → alias de /wiki anotar
/wiki etiqueta <pagina> <tag1>... → añade tags a una página
/wiki vincular <slug-a> <slug-b>  → enlaza dos páginas wiki
/wiki revisar                     → health check (orphans, broken links, duplicados)
/wiki buscar <pregunta>           → búsqueda sintetizada (V2)
```

## Modos

### `/wiki ingestar <path>`

Procesa un raw source existente:

1. Lee `<path>` (ej. `raw/articulos/2026-05-06-llm-wiki.md`)
2. Detecta tipo por frontmatter (`type: article|meeting|note|transcript`) o carpeta
3. Crea `docs/general/wiki/sources/<slug>.md` con summary + extracts
4. Para cada entidad mencionada (persona, herramienta, API, librería, producto): si existe → actualiza con citation; si no → pregunta si crear
5. Para cada concepto/decisión mencionada: lo mismo
6. **Si es reunión**: extrae decisiones (`DECISIÓN:`) y action items (`- [ ]`). Las decisiones se proponen como concept pages; los action items se proponen como tareas para `/pm capture`
7. Actualiza `index.md`, `log.md`, `tags.md`
8. Reporta cambios + pendientes de confirmación

### `/wiki anotar <texto>`

Captura rápida sin archivo previo:

1. Crea `raw/notas/YYYY-MM-DD-<slug-auto>.md` con `type: note` y el texto
2. Ejecuta el flujo `ingestar` sobre ese archivo

Útil cuando estás en conversación y quieres capturar una idea sin salir.

### `/wiki articulo <path-o-url-o-texto>`

Atajo para crear artículo + ingestar:

- Si es **URL** → guarda URL como `source_url`, contenido vacío para rellenar después manualmente
- Si es **path local** → mueve/copia a `raw/articulos/YYYY-MM-DD-<slug>.md`
- Si es **texto pegado** → crea `raw/articulos/YYYY-MM-DD-<slug>.md` con el texto

Tras crear, ejecuta `ingestar` automáticamente.

### `/wiki reunion <título>`

Crea plantilla de reunión interactiva:

1. Pregunta: fecha (default: hoy), asistentes, agenda inicial
2. Crea `raw/reuniones/YYYY-MM-DD-<slug>.md` con plantilla rellenable (secciones: Agenda, Notas, Decisiones, Action items)
3. **NO ingesta todavía** — la reunión está vacía. Avisa: "Cuando tengas las notas, ejecuta `/wiki ingestar raw/reuniones/<slug>.md`"

### `/wiki nota <texto>`

Alias rápido de `/wiki anotar`. Equivalente.

### `/wiki etiqueta <pagina> <tag1> [tag2...]`

1. Localiza `<pagina>` en `raw/` o `docs/general/wiki/`
2. Añade tags al frontmatter (sin duplicar)
3. Recalcula `tags.md`

### `/wiki vincular <slug-a> <slug-b>`

Añade enlaces bidireccionales entre dos páginas wiki. Raro de uso manual; los wikilinks normalmente se generan automáticamente al ingestar.

### `/wiki revisar`

Health check completo. Reporta:

- **Orphans**: páginas wiki que ninguna otra cita
- **Broken wikilinks**: `[[slug]]` que no existen
- **Sources sin ingestar**: archivos en `raw/` sin entrada en `sources/`
- **Tags huérfanos**: tags en `tags.md` con 0 páginas
- **Contradicciones**: heurística de concept pages que se contradicen
- **Duplicados**: entities con slug similar (posible mismo concepto)

NO arregla nada. Solo reporta. Pablo decide.

### `/wiki buscar <pregunta>` (V2)

Reservado para V2. En V1 responde: "Aún no implementado. Lee manualmente `docs/general/wiki/index.md`."

## Pipeline

1. Invocar **age-spe-wiki-curator** con el modo y argumentos
2. El agente lee la página/archivo y decide acciones
3. Pide confirmación antes de crear entity/concept pages
4. Reporta al humano en formato markdown estructurado

## Output esperado

```markdown
## /wiki <modo> — <timestamp>

### Resumen
[1-3 líneas]

### Cambios aplicados
- Creado: docs/general/wiki/sources/...
- Actualizado: docs/general/wiki/entities/...

### Pendiente de confirmación
- ¿Crear entity page para "X"? [sí/no]
- ¿Promover decisión "Y" a concept page? [sí/no]
- ¿Crear tarea PM para action item "Z"? [sí/no]

### Drift detectado (si aplica)
- ...
```

## Notas

- La wiki es **transversal**: conocimiento de cualquier área entra al mismo lugar.
- Raw es **inmutable**: el curator solo escribe en `raw/` cuando creas nuevos sources via `articulo`/`reunion`/`nota`/`anotar`. Nunca modifica raw existente.
- Wiki es **derivado**: si borras `docs/general/wiki/`, se puede regenerar ingestando los raw uno a uno.
- IDs/slugs son **estables**: renombrar el contenido no rompe los wikilinks.
- El curator **nunca invoca a otros agentes**. Sugiere "esto puede ser una tarea para `/pm capture`" pero no lo ejecuta.
- Activity log en wiki: `docs/general/wiki/log.md` lleva el orden cronológico de ingestiones.

## Disciplina recomendada (en CLAUDE.md)

Cuando Pablo pegue un texto largo, comparta un artículo, mencione una reunión o capture una idea, Claude debería preguntar:

> "¿lo guardo en raw/ y lo ingesto al wiki? ¿Qué tipo (artículo/reunión/nota)?"

Ver sección "Wiki Disciplina" en `CLAUDE.md` del proyecto.
