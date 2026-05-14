---
description: "Build a quality user story from an idea — no PRD required. The agent works autonomously through 7 internal phases."
---

# /story — Story Builder

## Pre-flight: leer `prompt_override` de la HU

Antes de invocar cualquier agente sobre una HU o EPIC concreta:

1. Localiza el frontmatter YAML de esa HU en `docs/<área>/features/<feature>/stories.md`.
2. Lee el campo `prompt_override`. Si existe y no está vacío, **inclúyelo como contexto adicional explícito** en el mensaje al sub-agente: «Contexto adicional del usuario para esta tarea: <prompt_override>».
3. El sub-agente ya conoce la regla universal (ver `rul-prompt-override` precargado) y la respetará.
4. Si no hay `prompt_override`, procede normal.

Esto vale tanto si el usuario lanza el comando manualmente (clipboard) como si el PM lo lanza autónomamente.

---


## Input
Idea, problema, conversacion, o contexto del PM. No requiere PRD, research previo, ni documentos.

## Step 0: Read Project Registry
Si existe `docs/general/project-registry.md`, lee el Quick Reference para orientarte sobre que assets ya existen (o estan planificados) en el proyecto. Usalo en la Fase 6 (Story Assembly) para:
- Derivar Notas tecnicas mas precisas (reusar assets existentes, no inventar nuevos)
- Llenar la seccion "Dependencias del Proyecto" del ticket (Usa/Crea)

## Step 1: Build Story
Invoke **age-spe-story-builder** with the PM's input.

The agent works autonomously through 7 internal phases:
1. Context analysis & solution-trap detection
2. Job discovery (Why Technique, 3-5 levels)
3. Wendel Checklist (marks gaps if data missing)
4. Three job dimensions (functional, emotional, social)
5. Behavior change (NOW→NEW, START/STOP/DIFFERENT, 3 ranges)
6. Complete story assembly with 6D scoring + 6-layer design analysis (UI, DB, API, Logic, Integrations, Edge Cases)
7. Design recommendation (Pencil — optional, non-blocking)

Present complete story (JTBD + Story + Design Analysis + Scoring + Razonamiento) to PM.
Ask: "Approve, modify, or investigate gaps with /analyze?"

## Step 2: Split if needed
If story is estimated >3 days, invoke **age-spe-story-splitter**.

## Step 3: Deliver
Save to `docs/producto/features/[feature-name]/stories.md`
If no feature folder exists, create it.

### Step 3.5 — Crear PRD esqueleto (V3.3, obligatorio)

Tras guardar la story, **crear `docs/producto/features/[feature-name]/prd.md`** como esqueleto inicial. Esto garantiza que toda EPIC tenga su PRD (no solo las que vienen de `/design-to-prd`):

1. Si `prd.md` YA existe en esa carpeta → NO sobrescribir (idempotencia). Salir de este paso.
2. Si NO existe:
   - Leer `~/.claude/templates/prd-skeleton-template.md`
   - Sustituir placeholders:
     - `{{TITLE}}` = título de la story (o de la épica si hay parent_epic)
     - `{{FEATURE_SLUG}}` = nombre de la carpeta padre
     - `{{EPIC_ID}}` = `parent_epic` de la story
     - `{{ORIGIN}}` = `story` (esta story viene de `/story`, no de inbox/design)
     - `{{CREATED_AT}}` = timestamp ISO 8601 UTC actual
     - `{{INITIAL_DESCRIPTION}}` = la idea original del PM (lo que escribió como input al lanzar `/story`) — preservar literalmente
   - Escribir el archivo
3. Reportar: "PRD esqueleto creado en `docs/producto/features/[feature]/prd.md`. Rellénalo manualmente o ejecutará `/analyze` + `/define` para enriquecerlo."

**Update registry**: After saving, update `docs/general/project-registry.md` with assets from the story's "Dependencias del Proyecto > Crea" (status: `planned`). Skip assets that already exist in the registry.

**CRITICAL — Reglas al escribir al registry**:
1. **Una fila = un asset**. Nunca agrupes funciones/endpoints/componentes en una sola fila, aunque compartan archivo.
2. **Ortografía**: aplica `rul-spanish-orthography` si el proyecto esta en español — acentos, ñ, ¿, ¡ en descripciones.
3. **Inventario puro**: descripciones factuales. No decisiones pendientes ni comentarios editoriales.
4. **Categorias base obligatorias**: las 6 categorias base (DB, API, Components, Services, Types, Integrations) NUNCA se eliminan.
5. **Categorias opcionales**: si el stack lo requiere (React/Next.js → Hooks/Pages, backend con workers → Jobs), anade la categoria respetando el template.

## Recommended Next Steps (Iterative Flow)

```
/story → Story Draft → Diseñar en Pencil → /design-to-prd → Revisar story → /plan → /build
```

1. **Si no hay diseño**: Crear diseño en Pencil basandose en la story draft. Luego `/design-to-prd` para analizar. Si el diseño revela requisitos nuevos, actualizar la story.
2. **Si ya hay diseño**: Usar `/design-to-prd` para comparar con el analisis derivado. Actualizar story si hay discrepancias.
3. **Sin diseño (fast track)**: Ir directo a `/plan`. La story es deployable sin diseño, pero con mayor riesgo de retrabajo UX.
4. **Cerrar gaps**: Usar `/analyze` si hay [GAP] o [HIPOTESIS] que requieren investigacion.

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
