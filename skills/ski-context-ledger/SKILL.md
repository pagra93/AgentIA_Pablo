---
name: ski-context-ledger
description: "API para escribir entradas en context-ledger/ — log append-only por sesión por agente. Trazabilidad de input/output/razonamiento de pasos significativos. Resumir trabajo cuando vuelves días después."
license: MIT
allowed-tools: Read Write Edit
user-invocable: false
metadata:
  author: agent-architect
  version: "1.0.0"
  category: persistence
  inspired-by: "luisdomarco/AiAgentArchitect (context-ledger layer)"
---

# Context Ledger — Log append-only de sesiones

## Propósito

Cuando un agente del arquitecto (o de un paquete) ejecuta un paso significativo, deja una entrada en `context-ledger/` que documenta:

- Qué hizo (paso)
- Con qué input
- Qué output produjo
- Razonamiento clave (no exhaustivo — el "por qué" no obvio)

Esto permite **reanudar trabajo cuando vuelves a una sesión días después** sin perder el hilo: leyendo las últimas entradas del ledger, recuperas contexto rápido.

NO es un log de bajo nivel (no es "abrí archivo X, leí 50 líneas"). Es un log de pasos editoriales/de proceso.

## Cuándo escribir

Aplica a:

- Generación de un paquete nuevo (`generator` escribe primera entrada al crear `exports/<paquete>/`)
- Propagación significativa (`propagator` escribe al completar una propagación cross-paquete)
- Auditoría con hallazgos (`auditor` escribe cuando detecta drift no trivial)
- Decisiones tomadas durante un comando (cuando el PM elige una opción concreta entre varias)
- Bloqueos identificados (cuando un agente se detiene por falta de información)

NO aplica a:

- Lecturas de archivos
- Operaciones triviales
- Cada step interno de un agente (sería ruido)

## Estructura de un archivo de entrada

Cada entrada es un archivo independiente. Ruta:

```
context-ledger/<YYYY-MM-DD>-<HHMMSS>-<agente>.md
```

Ejemplo: `context-ledger/2026-05-14-213045-age-spe-arc-generator.md`

Contenido (frontmatter + cuerpo):

```markdown
---
agent: age-spe-arc-generator
session_id: opcional-uuid-corto
timestamp: 2026-05-14T21:30:45+02:00
step: "create_package"
scope: "newsletter-system"
input_summary: "Mini-discovery completado: name=newsletter-system, prefix=news, dominio=editorial-content, 6 agentes previstos"
outcome: "completed | partial | blocked | aborted"
artifacts_touched:
  - exports/newsletter-system/
  - exports/README.md
  - changelog/propagations.md
---

## Qué se hizo

Paquete `newsletter-system` creado desde el template canónico. Mini-discovery aplicado con éxito.
Se generaron 6 stubs de agentes editoriales con TODO en DUTIES.md.

## Decisiones tomadas

- Prefix elegido: `news` (3 letras, evita colisión con `mkt`/`pm`)
- Domain folder: `newsletter/` (consistente con otros dominios editoriales)
- Outputs definidos: número de newsletter (.md + html), métricas de envío

## Razonamiento

El PM confirmó que el flujo es lineal (research → outline → draft → edit → publish), no iterativo
con feedback loops complejos. Por eso los 6 agentes son secuenciales, no orquestados por un PM
específico del paquete. La coordinación queda a cargo del PM humano usando los slash commands.

## Próximos pasos (sugeridos al PM)

- Implementar lógica de cada stub (sesión aparte)
- Ejecutar `exports/newsletter-system/install.sh` para compilar agentes a ~/.claude/
- Probar despliegue en proyecto cliente vacío

## Notas

(Anomalías, observaciones, ideas para refactor futuro.)
```

## Índice (`INDEX.md`)

Cada directorio `context-ledger/` mantiene un `INDEX.md` con **una línea por entrada**, en orden cronológico. Es la capa barata: escanear decenas de entradas cuesta unos pocos cientos de tokens, frente a abrir los archivos completos.

Formato (tabla markdown):

```markdown
# Context Ledger — Índice

| timestamp | agente | step | scope | outcome | archivo |
|---|---|---|---|---|---|
| 2026-05-15T10:15:00+02:00 | age-spe-arc-generator | create_package | newsletter-system | completed | 2026-05-15-101500-age-spe-arc-generator.md |
| 2026-05-18T11:55:00+02:00 | age-spe-arc-generator | migration | pmx-product | completed | 2026-05-18-115500-arc-generator-migration.md |
```

El índice es derivable: si se pierde o desincroniza, se regenera con `skills/ski-context-ledger/ledger-index.sh` (ver abajo).

## API mínima

Los agentes que escriben en el ledger usan el siguiente patrón:

1. Generar timestamp ISO 8601 (`date -u +%Y-%m-%dT%H:%M:%S%z`)
2. Generar nombre de archivo: `<fecha>-<hora>-<nombre-agente>.md`
3. Componer frontmatter con campos requeridos (agent, timestamp, step, scope, input_summary, outcome, artifacts_touched)
4. Componer cuerpo en secciones estándar: "Qué se hizo", "Decisiones tomadas", "Razonamiento", "Próximos pasos", "Notas"
5. Escribir archivo con `Write` (siempre nuevo archivo, jamás modificar entradas anteriores)
6. **Actualizar el índice**: hacer `Edit` (append) de una línea a `context-ledger/INDEX.md` con `timestamp | agente | step | scope | outcome | archivo`. Si `INDEX.md` no existe todavía, crearlo con la cabecera de tabla + la primera línea. Esto es append-only, igual que el resto del ledger.

## Cómo se consulta — recuperación en 3 capas

Para reanudar trabajo en una sesión nueva, no leas los archivos completos a ciegas. Procede por capas, de barato a caro:

1. **Capa índice (barata)**: leer `context-ledger/INDEX.md`. Filtrar mentalmente por `scope`, `agente` o fecha para identificar qué entradas importan.
2. **Capa timeline**: el índice ya está en orden cronológico; quédate con las N entradas relevantes (las últimas, o las del scope que vas a tocar) y anota sus nombres de archivo.
3. **Capa detalle (cara)**: hacer `Read` solo de los archivos seleccionados en el paso 2.

Atajos en shell:

```
# Capa índice: ver el índice completo
cat context-ledger/INDEX.md

# Capa detalle: leer una entrada concreta ya identificada
cat context-ledger/<archivo-seleccionado>.md
```

Si el ledger no tiene `INDEX.md` (heredado de una versión anterior o desincronizado), regenerarlo primero con `skills/ski-context-ledger/ledger-index.sh` (ver "Regeneración del índice").

## Regeneración del índice

El índice se mantiene vivo con el paso 6 de la API (append al escribir). Si aun así se desincroniza, se hereda un ledger sin índice, o quieres reconstruirlo desde cero:

```
bash skills/ski-context-ledger/ledger-index.sh [ruta-al-context-ledger]   # default: ./context-ledger
```

El script escanea el frontmatter (`timestamp`, `agent`, `step`, `scope`, `outcome`) de cada `*.md` del directorio, los ordena por timestamp y reescribe `INDEX.md`. Es idempotente y fail-safe (no rompe si el directorio no existe).

## Reglas

1. **Append-only**: nunca se edita ni borra una entrada. Si una entrada se reveló incorrecta, se añade una NUEVA entrada que la corrige (con frontmatter `corrects: <ruta-de-la-entrada-errónea>`). La entrada correctora también añade su línea al `INDEX.md` (las dos quedan listadas; el índice no se "rebobina").

2. **Una entrada por paso significativo**, no por cada operación. Si el agente hizo 10 operaciones para crear un paquete, eso es UNA entrada (`step: create_package`).

3. **Resúmenes, no transcripciones**: el ledger es "qué pasó y por qué", no "todo lo que dijo el modelo". Conciso, accionable.

4. **No info sensible**: el ledger se versionará con git. Nunca incluir credenciales, tokens, contenido confidencial. Si la entrada referencia algo sensible, lo nombra ("acceso al API de X usado") pero no incluye el valor.

5. **Idiomas consistentes con el sistema**: en este arquitecto, español con ortografía correcta (regla `rul-spanish-orthography`).

## Ubicaciones por sistema

- **Arquitecto**: `AgentArchitect/context-ledger/` (raíz del arquitecto, no creado todavía — se crea al primer uso)
- **Paquete (export)**: `AgentArchitect/exports/<paquete>/context-ledger/`
- **Proyecto cliente**: NO tiene context-ledger por defecto (es opcional; si un paquete lo necesita, su `deploy.sh` lo crea)

## Implementación nota

Esta skill define el formato. La generación efectiva del archivo la hace el agente que la invoca, usando el tool `Write` con la ruta y contenido construido según las reglas de arriba. No requiere binario ni script externo.
