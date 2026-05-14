---
description: "Launch Definition phase — transform research into JTBDs, stories, quality review, and splitting. Detects existing stories from /design-to-prd and enriches them instead of duplicating."
---

# /define — Definition Pipeline

## Pre-flight: leer `prompt_override` de la HU

Antes de invocar cualquier agente sobre una HU o EPIC concreta:

1. Localiza el frontmatter YAML de esa HU en `docs/<área>/features/<feature>/stories.md`.
2. Lee el campo `prompt_override`. Si existe y no está vacío, **inclúyelo como contexto adicional explícito** en el mensaje al sub-agente: «Contexto adicional del usuario para esta tarea: <prompt_override>».
3. El sub-agente ya conoce la regla universal (ver `rul-prompt-override` precargado) y la respetará.
4. Si no hay `prompt_override`, procede normal.

Esto vale tanto si el usuario lanza el comando manualmente (clipboard) como si el PM lo lanza autónomamente.

---


## Input
Research brief from /analyze, or user-provided context.

## Step 0: Detect Existing Stories

Before starting, check if `docs/producto/features/[feature]/stories.md` already exists (from `/design-to-prd`).

- **Si existe**: Modo **Enrich** — los JTBDs se mapean a stories existentes, el story-writer enriquece secciones [DERIVADO] preservando Diseno y Notas tecnicas.
- **Si NO existe**: Modo **Create** — pipeline completo, genera stories desde cero.

## Step 1: Generate JTBDs
Invoke **age-spe-jtbd-architect** with the research brief.
- En modo **Enrich**: el architect tambien recibe las stories existentes para mapear cada JTBD a una story ya identificada.
Present JTBDs. Ask PM: "Approve, modify, or add?"

## Step 2: Write Stories
Invoke **age-spe-story-writer** with approved JTBDs.
- En ambos modos, el writer debe leer `docs/general/project-registry.md` (si existe) para:
  - Llenar "Dependencias del Proyecto > Usa" con assets existentes (`planned` o `active`)
  - Llenar "Dependencias del Proyecto > Crea" con assets nuevos que la story producira
  - Evitar duplicar en Notas tecnicas tablas/endpoints ya registrados (referenciar, no redefinir)
- En modo **Enrich**: el writer recibe stories existentes + mapping JTBD→Story. Enriquece secciones debiles, preserva secciones fuertes del design-analyst.
- En modo **Create**: genera stories desde cero en formato kno-story-ticket-template.

## Step 3: Quality Review
Invoke **age-sup-quality-coach** to review stories.
If any story scores < 7:
- Present suggestions to PM
- "Accept suggestions, modify, or proceed as-is?"
- If accepted: rerun story-writer with suggestions
- **If "proceed as-is" (override del quality-coach)**: es una decisión crítica loggable. Escribir entrada al `_events.jsonl` de la feature:
  ```jsonl
  {"ts":"<ISO>","agent":"human","event":"decision","summary":"override quality-coach en HU-XXX","context":"<razón>","entity":"HU-XXX"}
  ```

## Step 4: Split Large Stories
Invoke **age-spe-story-splitter** only for stories flagged as >3 days.

## Step 5: Deliver
Present final stories with scoring.
- En modo **Enrich**: mostrar que secciones se upgradearon (Historia, Definicion, Scoring) y que secciones se preservaron (Diseno, Notas tecnicas).
- En modo **Create**: presentar stories completas con marcadores de confianza.

**Where to save**: Save to the feature's folder:
- `docs/producto/features/[feature-name]/jtbds.md` — JTBDs generated
- `docs/producto/features/[feature-name]/stories.md` — Stories (nuevas o enriquecidas)

If no feature folder exists, create it. Always organize by feature, not by phase.

**Update registry**: After saving stories, update `docs/general/project-registry.md` with assets from each story's "Dependencias del Proyecto > Crea" (status: `planned`). Skip assets that already exist in the registry.

**CRITICAL — Reglas al escribir al registry**:
1. **Una fila = un asset**. Nunca agrupes funciones/endpoints/componentes, aunque compartan archivo.
2. **Ortografía**: aplica `rul-spanish-orthography` si el proyecto esta en español — acentos, ñ, ¿, ¡ en descripciones.
3. **Inventario puro**: descripciones factuales. No decisiones pendientes ni comentarios editoriales.
4. **Categorias base obligatorias**: las 6 categorias base (DB, API, Components, Services, Types, Integrations) NUNCA se eliminan.
5. **Categorias opcionales**: si el stack lo requiere (React/Next.js → Hooks/Pages, backend con workers → Jobs), anade la categoria respetando el template.

Next: "Use /plan to create architecture and sprint plan."

## Modo Enrich vs Create — Que Cambia

| Seccion del Ticket | Create (sin /design-to-prd) | Enrich (con /design-to-prd) |
|--------------------|---------------------------|---------------------------|
| Historia de Usuario | COMPLETA (de JTBD) | **UPGRADE** [DERIVADO] → JTBD validado |
| Definicion | COMPLETA (Behavior Change) | **UPGRADE** [DERIVADO] → research evidence |
| Diseno | [PENDIENTE DE DISENO] | **PRESERVAR** (del design-analyst) |
| Criterios de aceptacion | COMPLETA (de JTBD) | **MERGE** existentes + nuevos de JTBD |
| Notas tecnicas | [DERIVADO] | **PRESERVAR** (del design-analyst) |
| Plan pruebas | COMPLETA | **MERGE** existentes + nuevos |
| Scoring 6D | COMPLETA | **RECALCULAR** (D1/D2 suben con evidence) |

---

## Auto-sync con PM (último paso, automático)

Tras completar todos los pasos anteriores, ejecuta **age-spe-pm-producto** en dos modos secuenciales:

### 1. modo `sync`
- Lee filesystem (stories.md, qa.md, sprint.md, etc.)
- Actualiza `pm/tasks.json` con los cambios producidos por este command
- Actualiza `pm/id-counters.json`
- Reporta drift solo si lo detecta (sino, output silent)

### 2. modo `dossier all`
- Detecta qué feature folders se modificaron en los últimos 60 segundos
- Regenera `_dossier.md` y appendea evento a `_events.jsonl` en cada una
- Preserva sección `<!-- USER:notes -->` del dossier
- Output silent excepto reporte breve de qué dossiers se actualizaron

**Por qué**: el dashboard refleja el nuevo estado (kanban + tabla + dossiers contextuales) sin que tengas que ejecutar `/pm sync` ni `/pm dossier` manual. Si el sync detecta drift, se reporta al final.
