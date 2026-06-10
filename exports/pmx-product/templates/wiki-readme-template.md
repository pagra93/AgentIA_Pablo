# Wiki — Cerebro de conocimiento de la empresa

Esta carpeta es la **memoria viva** del proyecto/empresa. Es transversal: el conocimiento de Producto, Marketing, RRHH y Operaciones convive aquí.

## Cómo funciona

Hay 2 zonas:

1. **`raw/` (en la raíz del proyecto)** — fuente de verdad inmutable
   - `raw/articulos/` — artículos, blogs, papers
   - `raw/reuniones/` — reuniones celebradas (asistentes, agenda, decisiones, action items)
   - `raw/notas/` — notas sueltas, ideas, capturas rápidas
   - `raw/transcripciones/` — audio→texto
   - `raw/otros/` — lo que no encaja

2. **`docs/general/wiki/` (esta carpeta)** — síntesis derivada
   - `index.md` — catálogo de todo lo que hay
   - `log.md` — cronológico (qué se ingesta cuándo)
   - `tags.md` — índice de tags con conteos
   - `entities/` — personas, herramientas, APIs, librerías, productos
   - `concepts/` — decisiones, patrones, principios
   - `topics/` — áreas/temas de exploración
   - `sources/` — summaries de cada raw, con citations

## Reglas

1. **Raw es inmutable**. Solo el curator (`age-spe-wiki-curator`) puede escribir cuando lo invocas con `/wiki articulo|reunion|nota|anotar`. Nunca modifica raw existente.
2. **Wiki es derivado**. Toda página aquí se puede regenerar reingiriendo el raw correspondiente.
3. **Wikilinks `[[slug]]`** siempre que sea posible. Son el valor de la wiki.
4. **Citations obligatorias**. Toda concept/entity page cita las sources que la respaldan.

## Comandos

```
/wiki ingestar <path>      Procesa un raw e integra al wiki
/wiki anotar <texto>       Captura nota rápida e ingesta
/wiki articulo <input>     Crea artículo (URL/path/texto) e ingesta
/wiki reunion <título>     Crea plantilla de reunión
/wiki nota <texto>         Alias de anotar
/wiki etiqueta <p> <tag>   Añade tags a una página
/wiki revisar              Health check
```

Ver `~/.claude/commands/wiki.md` para detalles completos.

## Por qué esto importa

Sin wiki:
- Un artículo que leíste hace 3 semanas → olvidado
- Una decisión en reunión → "creo que decidimos X..."
- Un concepto técnico mencionado 10 veces → cada vez se reexplica

Con wiki:
- Cada source genera páginas reusables
- Las decisiones se promueven a concept pages citando la reunión
- Cuando preguntas "¿qué decidimos sobre X?", el LLM lee la wiki y cita la fuente
