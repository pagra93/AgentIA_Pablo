---
description: "Initialize a new project (or add PM x10 to existing one) with CLAUDE.md, docs, tasks, memory, QA, and working-docs structure."
---

# /new-project — Project Initializer

Works for NEW projects and EXISTING ones. Only adds management files — never touches your code.

## Step 1: Interview

Ask the user:
1. **Project name**: "What's the project called?"
2. **Description**: "Describe it in 1-2 sentences"
3. **Tech stack**: "What technologies? (e.g., Next.js + PostgreSQL + Supabase)"
4. **Platform**: "Web, mobile, API, or combination?"
5. **Team context**: "Solo with AI, or is there a team?"
6. **Test setup**: "Do you have a test framework already? (e.g., Jest, Vitest, Pytest, none yet)"

## Step 2: Create Structure

Create ALL of the following. If a file/folder already exists, SKIP it (don't overwrite).

### .claude/CLAUDE.md (or update existing)

If CLAUDE.md already exists, ADD the PM x10 sections to it (don't replace existing content).
If it doesn't exist, generate from scratch:

```markdown
# [Project Name]

## What This Project Does
[User's description]

## Tech Stack (non-negotiable)
[User's stack — agents MUST respect this]

## Navigation
### Global (installed in ~/.claude/)
- Agents: 14 specialized agents (10 specialists + 4 supervisors)
- Skills: 7 (PRD builder, competitive analysis, plan mode, doc updater, unknown unknowns, project docs, impeccable guide)
- Rules: 6 (definition of done/ready, antipatterns, scoring, naming, git branching)
- Knowledge: 5 (JTBD framework, Mom Test, story splitting, testing strategy, story ticket template)
- Commands: 14 slash commands

### Project (this project)
- Project docs: docs/general/PROJECT_KNOWLEDGE.md — READ THIS FIRST when returning
- Project registry: docs/general/project-registry.md — technical asset inventory (DB, APIs, components)
- Working docs: docs/producto/features/[feature]/ — artifacts per feature
- Current tasks: docs/producto/sprint.md — sprint plan and progress
- Lessons learned: docs/producto/lessons.md — patterns and mistakes
- Working memory: memory/MEMORY.md — agent observations across sessions
- QA reports: docs/producto/qa.md — audit trail (append-only)

## Orchestration Rules
1. Start every non-trivial task in plan mode (>3 steps)
2. Write plans to docs/producto/sprint.md before executing
3. Commit after each completed story (/save)
4. /review after completing features (tests + QA + asks about docs)
5. Consult docs/producto/lessons.md at start of each session
6. Read memory/MEMORY.md for patterns from previous sessions
7. Save artifacts to docs/producto/features/[feature]/ organized by feature

## Available Commands
/analyze            Evaluate problem/PRD (Quality Guard + Research)
/define             Create JTBDs + stories (with quality review)
/plan               Architecture + sprint plan
/story              Build story from idea (no PRD, autonomous agent)
/build              Implement stories (Claude Code directly)
/save               Commit + push to GitHub (validates branch, detects secrets)
/review             QA pipeline + feature docs (ALWAYS asks about documentation)
/hotfix             Bug fix with learning (only saves when PM confirms resolved)
/code-review        Just code review
/design-to-prd      Pencil designs → PRDs per feature (6-layer analysis)
/unknown-unknowns   Detect hidden risks (8 dimensions)
/docs               Generate/update project documentation
/learned            Save a learning anytime (bug resolved, discovery, mistake)

## Testing
### Framework
[Based on stack — e.g., Vitest for Vite projects, Jest for React/Node, Pytest for Python]

### Test File Location
[Based on stack — e.g., co-located __tests__/ for React, tests/ for Python]

### Test Commands
- Unit/Integration: [e.g., npm test, pytest]
- E2E: [e.g., npx playwright test]
- Coverage: [e.g., npm test -- --coverage]

### Test Data
[Based on stack — e.g., factories with faker.js, MSW for API mocking]

## Coding Standards
[Based on stack — generate appropriate for the tech]

## Core Principle
Analysis Informs, Never Blocks. Agents identify risks. PM always decides.
```

### docs/general/PROJECT_KNOWLEDGE.md
```markdown
# Project Knowledge — [Name]
Last updated: [today]

## What This Project Does
[Description]

## Architecture Overview
[To be filled after /plan]

## Features Implemented
| Feature | Date | Status | Notes |
|---------|------|--------|-------|

## Key Decisions
| Decision | Date | Why |
|----------|------|-----|

## How Things Work
[To be filled as features are built]

## Known Issues & Tech Debt
| Issue | Priority | Notes |
|-------|----------|-------|
```

### docs/general/project-registry.md
```markdown
# Project Registry
Last updated: [today]
Total assets: 0

## Reglas de Llenado

**Granularidad**: Una fila = un asset. Nunca agrupes múltiples funciones, endpoints o componentes en una sola fila, aunque compartan archivo. Si `contracts.ts` exporta 8 funciones, son 8 filas.

**Ortografía**: Aplica `rul-spanish-orthography` cuando el proyecto esté en español — acentos, ñ, ¿, ¡ en todas las descripciones. Ejemplo: "análisis", "energía", "configuración".

**Inventario puro**: Solo hechos, no decisiones. Nada de "> Decisión final se toma en /plan" ni comentarios editoriales. Para decisiones pendientes usa `docs/producto/features/[feature]/architecture.md` o un ADR.

**Categorías base obligatorias**: Las 6 categorías base (DB Models, API Endpoints, Shared Components, Services & Utilities, Types & Interfaces, External Integrations) NUNCA se eliminan — se dejan vacías si no aplican todavía.

**Categorías opcionales según stack**: Puedes añadir Hooks, Pages, Libs/Utils, Jobs, Middlewares según el stack del proyecto. Ver sección opcional al final del archivo.

## Quick Reference
<!-- SUMMARY -->
**DB**: (none yet)
**API**: (none yet)
**Components**: (none yet)
**Services**: (none yet)
**Types**: (none yet)
**Integrations**: (none yet)
<!-- /SUMMARY -->

## DB Models
<!-- CATEGORY:db -->
| Table | Key Fields | Relations | Feature | Story | Status |
|-------|-----------|-----------|---------|-------|--------|

## API Endpoints
<!-- CATEGORY:api -->
| Method | Path | Auth | Feature | Story | Status |
|--------|------|------|---------|-------|--------|

## Shared Components
<!-- CATEGORY:components -->
| Component | Path | Props/Interface | Feature | Story | Status |
|-----------|------|----------------|---------|-------|--------|

## Services & Utilities
<!-- CATEGORY:services -->
| Service | Path | Key Exports | Feature | Story | Status |
|---------|------|-------------|---------|-------|--------|

## Types & Interfaces
<!-- CATEGORY:types -->
| Type | Path | Key Fields | Feature | Story | Status |
|------|------|-----------|---------|-------|--------|

## External Integrations
<!-- CATEGORY:integrations -->
| Service | Purpose | Feature | Story | Status |
|---------|---------|---------|-------|--------|

<!-- ═══════════════ CATEGORÍAS OPCIONALES (añadir solo si el stack lo requiere) ═══════════════ -->

## (Opcional) Hooks — solo para proyectos React/Next.js
<!-- CATEGORY:hooks -->
| Hook | Path | Purpose | Feature | Story | Status |
|------|------|---------|---------|-------|--------|

## (Opcional) Pages — solo para proyectos Next.js con routing por archivo
<!-- CATEGORY:pages -->
| Route | File | Feature | Story | Status |
|-------|------|---------|-------|--------|

## (Opcional) Jobs — solo para proyectos con background workers
<!-- CATEGORY:jobs -->
| Job | Trigger | Purpose | Feature | Story | Status |
|-----|---------|---------|---------|-------|--------|
```

### docs/producto/features/ (empty directory)
This is where feature artifacts will be organized:
```
docs/producto/features/
└── [feature-name]/          ← created by /design-to-prd, /analyze, /define
    ├── design-analysis.md   ← from /design-to-prd
    ├── prd.md               ← from /design-to-prd or /analyze
    ├── research.md          ← from /analyze
    ├── jtbds.md             ← from /define
    ├── stories.md           ← from /define
    └── architecture.md      ← from /plan
```

### docs/producto/sprint.md
```markdown
# Tasks — [Name]
Status: INITIALIZED

## Current Sprint
[No sprint yet. Use /analyze → /define → /plan to create one.]
```

### docs/producto/lessons.md
```markdown
# Lessons Learned — [Name]

## Patterns to Follow
[Populated by QA Optimizer and /learned]

## Mistakes to Avoid
[Populated by /hotfix and /learned after resolving issues]
```

### memory/MEMORY.md
```markdown
# Working Memory — [Name]
Last updated: [today]

## Project Patterns
(Populated by Code Reviewer after /review cycles)

## Recurring Issues
(Populated by Optimizer after detecting patterns in QA reports)

## Recent Decisions
- [today]: Project initialized with PM x10 Agent System

## Open Questions
(None yet)
```

### docs/producto/qa.md

Crear archivo vacío con header inicial:

```markdown
# QA Report — [Project Name]

(Append-only. Cada `/review` añade una nueva sección con fecha.)
```

### raw/ — Fuente de verdad de la wiki (NUEVO V3.0)

Crear la estructura `raw/` con sus 5 subcarpetas categorizadas. Es donde Pablo (o agentes via `/wiki articulo|reunion|nota`) deposita los sources brutos antes de que el curator los integre al wiki.

```
raw/
├── articulos/           # artículos, blogs, papers (recursos externos interesantes)
├── reuniones/           # reuniones celebradas (asistentes, agenda, decisiones, action items)
├── notas/               # notas sueltas, ideas, capturas rápidas
├── transcripciones/     # audio→texto
└── otros/               # lo que no encaja
```

Crear cada subcarpeta con un `.gitkeep` o un `README.md` mínimo explicando qué va ahí.

### docs/general/wiki/ — Síntesis derivada (NUEVO V3.0)

Crear la estructura `docs/general/wiki/` que será la wiki sintética mantenida por `age-spe-wiki-curator`.

```
docs/general/wiki/
├── README.md            # cómo funciona la wiki (copia desde templates/wiki-readme-template.md)
├── index.md             # catálogo (copia desde templates/wiki-index-template.md)
├── log.md               # cronológico (copia desde templates/wiki-log-template.md)
├── tags.md              # índice de tags (copia desde templates/wiki-tags-template.md)
├── entities/            # personas, herramientas, APIs, librerías, productos
├── concepts/            # decisiones, patrones, principios
├── topics/              # áreas/temas de exploración
└── sources/             # summaries de cada raw, con citations
```

Las 4 subcarpetas (entities, concepts, topics, sources) se crean vacías con `.gitkeep`. Los archivos índice (`index.md`, `log.md`, `tags.md`, `README.md`) se copian desde `~/.claude/templates/wiki-*-template.md`.

### docs/marketing/README.md, docs/rrhh/README.md, docs/operaciones/README.md

Crear las carpetas para áreas futuras con un README explicando que están preparadas pero no activadas:

```markdown
# Área: [marketing | rrhh | operaciones]

Esta área está **preparada pero no activada**.

Para activarla:
1. Edita `pm/config.json` y cambia `areas.<area>.active` a `true`
2. Crea el agente PM correspondiente (`age-spe-pm-<area>`) con sus propios estados
3. El dashboard la mostrará al recargar

Mientras tanto, este área aparece en el sidebar del dashboard como "sin activar".
```

### docs/producto/inbox.md (Buzón de ideas del área Producto)

Buzón de ideas. Copia desde `~/.claude/dashboard-template/../templates/inbox-template.md` o usa este contenido mínimo:

```markdown
# Inbox — buzón de ideas

Buzón libre. Cualquiera puede añadir entradas (tú, los agentes). El PM las procesa al ejecutar `/pm inbox` o `/pm`.

## Cómo añadir entradas

Tres formatos válidos:
- **Sección con título**: `## Idea: ...`  + cuerpo opcional
- **Línea simple**: `- texto descriptivo`
- **Con metadata**: `## Título` seguido de bloque ` ```yaml `

(Ver `~/.claude/skills/templates/inbox-template.md` para ejemplos completos)
```

### pm/tasks.json (índice del PM)

```json
{
  "schema_version": "1.0.0",
  "area": "producto",
  "last_indexed_at": null,
  "tasks": [],
  "drift_warnings": []
}
```

### pm/id-counters.json (counters de IDs libres)

```json
{
  "schema_version": "1.0.0",
  "next_hu": 1,
  "next_epic": 1,
  "updated_at": null
}
```

Este archivo es ~50 tokens y lo leen los 3 agentes generadores (story-writer, story-builder, design-analyst) en lugar del `pm/tasks.json` completo (~9K tokens) cuando solo necesitan asignar el siguiente HU-XXX libre. El PM lo mantiene en cada `/pm sync` recalculando los counters como `max(id observado en stories) + 1`. Si se borra, el PM lo regenera.

### pm/events.jsonl (activity log opcional)

Crear archivo vacío. Los agentes o slash commands pueden añadir eventos opcionalmente. Sin el archivo, el PM funciona inferenciando por filesystem.

### dashboard/ (V2.1 — UI visual del proyecto)

Copiar el contenido de `~/.claude/dashboard-template/` al directorio `dashboard/` del proyecto:
- `dashboard/bridge.py` — servidor HTTP local (Python stdlib, sin dependencias externas)
- `dashboard/index.html` — UI con sidebar de áreas + viewer de markdown
- `dashboard/styles.css` — dark theme consistente con el resto del sistema
- `dashboard/app.js` — vanilla JS (fetch del árbol, renderizado de markdown)

Comando para arrancar (documentar al PM al final):
```bash
python3 dashboard/bridge.py
# Abre http://localhost:7700/ en el navegador
```

Si Python3 no está disponible, instalar primero (mac: `brew install python3`, ubuntu: `apt install python3`).

### pm/config.json (config de áreas, agentes, estados)

Copia desde `~/.claude/skills/templates/config-template.json` (o `templates/config-template.json` del repo del sistema). Contiene:

- `areas`: General y Producto activas; Marketing, RRHH, Operaciones preparadas pero inactivas
- `agents`: lista de los 16 agentes disponibles
- `default_phase_agents`: qué agente trabaja qué fase
- `states`: los 8 estados + cancelado
- `transitions`: qué transiciones son válidas entre estados
- `id_format`: formato de IDs (HU-XXX, EPIC-XXX, subtareas)

El bridge del dashboard lee este archivo para saber qué áreas mostrar y cuáles están activas. **Editar este archivo es la forma de activar nuevas áreas** (cambiar `active: true`).

## Step 3: Confirm

Tell the user:

"Project initialized with PM x10 Agent System.

Created:
- .claude/CLAUDE.md — Project config with all commands listed
- docs/general/PROJECT_KNOWLEDGE.md — Living knowledge (read this when returning)
- docs/general/project-registry.md — Technical asset inventory (DB, APIs, components, services)
- docs/producto/features/ — Feature artifacts (filled by /design-to-prd, /analyze, /define)
- docs/producto/sprint.md — Sprint plan and progress
- docs/producto/lessons.md — Patterns and mistakes
- docs/producto/qa.md — QA audit trail (append-only)
- docs/producto/inbox.md — Buzón de ideas del área Producto. El PM las procesa con /pm inbox
- docs/marketing/, docs/rrhh/, docs/operaciones/ — Áreas preparadas pero no activadas
- raw/ — Fuente de verdad de la wiki (artículos, reuniones, notas, transcripciones, otros)
- docs/general/wiki/ — Wiki sintética de empresa (mantenida por /wiki ingestar). Transversal a todas las áreas.
- pm/tasks.json — Índice maestro mantenido por el PM (estado operativo, no editar a mano)
- pm/id-counters.json — Counters de IDs libres (~50 tokens). Lo leen los agentes generadores en vez de tasks.json para ahorrar contexto.
- pm/config.json — Áreas, agentes, estados y transiciones del PM
- pm/events.jsonl — Activity log opcional
- memory/MEMORY.md — Agent observations across sessions
- dashboard/ — UI visual (V2.1). Arranca con: python3 dashboard/bridge.py → http://localhost:7700

Available commands:
- /design-to-prd    Pencil designs → PRDs per feature
- /analyze          Evaluate a problem or PRD
- /define           Create JTBDs and user stories
- /plan             Architecture and sprint plan
- /build            Implement stories
- /save             Commit and push to GitHub
- /review           QA pipeline + feature docs
- /hotfix           Bug fix with learning
- /unknown-unknowns Detect hidden risks
- /docs             Generate project documentation
- /learned          Save a learning anytime
- /pm               PM de Producto: índice + buzón. Modos: sync, inbox, next, status, prioritize, block, unblock, done, cancel
- /wiki             Wiki de empresa (transversal). Modos: ingestar, anotar, articulo, reunion, nota, etiqueta, vincular, revisar

Tip: For small tasks (<30 sec), just ask directly — no commands needed.
For features: /analyze → /define → /plan → /build → /save → /review
If you have designs: start with /design-to-prd"
