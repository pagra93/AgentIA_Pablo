---
description: "Launch QA phase — test, code review, audit, evaluate, optimize, document, and optionally generate full feature docs."
---

# /review — Testing & QA Pipeline

## Pre-flight: leer `prompt_override` de la HU

Antes de invocar cualquier agente sobre una HU o EPIC concreta:

1. Localiza el frontmatter YAML de esa HU en `docs/<área>/features/<feature>/stories.md`.
2. Lee el campo `prompt_override`. Si existe y no está vacío, **inclúyelo como contexto adicional explícito** en el mensaje al sub-agente: «Contexto adicional del usuario para esta tarea: <prompt_override>».
3. El sub-agente ya conoce la regla universal (ver `rul-prompt-override` precargado) y la respetará.
4. Si no hay `prompt_override`, procede normal.

Esto vale tanto si el usuario lanza el comando manualmente (clipboard) como si el PM lo lanza autónomamente.

---


## Step 1: Testing (Validation Loop)
Invoke **age-spe-test-engineer**: generate tests, execute full suite, verify coverage, iterate (max 3 cycles).

The test-engineer will:
1. Detect test framework from CLAUDE.md / project config
2. Generate tests from acceptance criteria (Given-When-Then → unit / integration / E2E)
3. Execute full test suite (existing + new — not just new tests)
4. Check branch coverage on business logic (target 80%+)
5. Iterate if failures are test bugs (max 3 cycles)
6. Report: results, coverage, regressions, app bugs vs test bugs

## Step 2: Code Review
Invoke **age-spe-code-reviewer**: review for quality, security, performance.
If critical issues → fix before continuing.

## Step 2.5: Structural Verification (Context Engineering Gates)

### Stub Scan
Scan all modified files for placeholder patterns:
- Empty arrays/objects: `= []`, `= {}`, `= null` that flow to rendering
- Placeholder text: `TODO`, `FIXME`, `placeholder`, `coming soon`, `not available`
- Components with no data source wired (props always receiving empty/mock data)
- Functions returning hardcoded values instead of real logic

Report stubs with file:line references. If critical stubs found, fix before continuing.

### Verify Must-Haves
For each completed story, read its **Verificacion Estructural** section (in the story ticket):

1. **Verdades**: For each truth, verify it's actually true by reading the code.
   Example: "El usuario puede ver mensajes existentes" → verify the component renders messages from a real data source.

2. **Artefactos**: For each artifact, verify:
   - File exists at the expected path
   - File has substantive content (meets min_lines — not a stub)
   - Expected exports exist (grep for `export`)
   - Expected patterns are present (grep for the `contains` pattern)

3. **Conexiones**: For each connection, verify:
   - Source file references the target (grep for the pattern)
   - The connection mechanism exists (fetch, import, SQL query, etc.)

**Report:**
| Story | Verdades | Artefactos | Conexiones | Status |
|-------|----------|-----------|------------|--------|
| HU-01 | 3/3 | 2/2 | 1/1 | PASS |
| HU-02 | 2/3 | 1/2 | 0/1 | FAIL — dashboard not wired to API |

If any story FAILS: report gaps to PM. PM decides whether to fix before continuing QA audit or proceed.

## Step 2.6: Registry Verification

Update `docs/general/project-registry.md` with verified assets from completed stories.

**Normal flow** (stories have "Dependencias del Proyecto > Crea"):
For each completed story, read its "Dependencias del Proyecto > Crea" section:
1. Verify each declared asset exists in the codebase (migration file, endpoint route, component export)
2. If exists and is substantive (not a stub): promote from `planned` → `active` in the registry. Fill in the `Path` column with the verified codebase path.
3. If NOT exists: report as gap (asset stays `planned` until built)
4. If a "Usa" asset is `deprecated` in the registry: flag to PM

**Retroactive population** (registry empty but stories exist):
If `docs/general/project-registry.md` has zero data rows but `docs/producto/features/*/stories.md` files exist:
1. Scan ALL existing stories' "Notas tecnicas" sections:
   - Modelo de Datos → DB Models category
   - API Endpoints → API Endpoints category
   - Integraciones → External Integrations category
2. Scan the actual codebase to find:
   - Exported components → Shared Components category
   - Service files → Services & Utilities category
   - Type definitions → Types & Interfaces category
3. Populate registry with all found assets (status: `active` for codebase-verified, `planned` for story-only)
4. Mark header: `Retroactive population: [date]`
5. This only runs ONCE — when registry is empty and stories exist

Always update: Last updated date, Total assets count, Quick Reference summary.

**CRITICAL — Reglas al escribir al registry** (aplica tanto a flujo normal como a retroactive population):
1. **Una fila = un asset**. Nunca agrupes funciones/endpoints/componentes, aunque compartan archivo. Si `contracts.ts` exporta 8 funciones, son 8 filas.
2. **Ortografía**: aplica `rul-spanish-orthography` si el proyecto esta en español — acentos, ñ, ¿, ¡ en descripciones.
3. **Inventario puro**: descripciones factuales. No decisiones pendientes ni comentarios editoriales (ej: NO "> Decision se toma en /plan").
4. **Categorias base obligatorias**: las 6 categorias base (DB, API, Components, Services, Types, Integrations) NUNCA se eliminan. Deja vacias si no aplican.
5. **Categorias opcionales**: si el stack lo requiere (React/Next.js → Hooks/Pages, backend con workers → Jobs), anade la categoria respetando el template.

**Validacion antes de promover `planned` → `active`**:
- [ ] Ninguna fila agrupa multiples assets (funciones separadas por coma → dividir)
- [ ] Ortografia correcta segun idioma del proyecto
- [ ] No hay comentarios editoriales ni decisiones pendientes
- [ ] Las 6 categorias base existen (aunque esten vacias)

Si falla algun check, reescribir las filas afectadas ANTES de promover.

## Step 3: QA Audit Cycle (sequential)

### 3a: Audit
Invoke **age-sup-auditor**: verify compliance with Definition of Done.

### 3b: Evaluate
Invoke **age-sup-evaluator**: score phase on Completeness, Quality, Compliance, Efficiency.

### 3c: Optimize
Invoke **age-sup-optimizer**: review history, propose improvements.
Updates `docs/producto/lessons.md`, `memory/MEMORY.md`, and `docs/general/PROJECT_KNOWLEDGE.md`.

## Step 4: Auto Documentation
Use **ski-doc-updater** to update PROJECT_KNOWLEDGE.md, changelog, API docs.

## Step 5: Final Verification
- [ ] Tests pass
- [ ] Code review approved
- [ ] Audit passed
- [ ] Docs updated
- [ ] Changes committed

All pass: "DONE. Sprint stories verified and documented."
Any fail: Report what's missing.

## Step 6: Feature Documentation (ALWAYS ask)

**ALWAYS ask the PM after Step 5 passes:**

"Feature completada y verificada. ¿Genero documentación completa de esta feature?"

**If PM says yes:**
1. Detect which feature was just completed (from docs/producto/sprint.md or ask PM)
2. Read ALL working docs from `docs/producto/features/[feature]/`:
   - design-analysis.md (if exists — from /design-to-prd)
   - prd.md (problem definition)
   - research.md (Mom Test findings)
   - jtbds.md (Jobs-to-be-Done)
   - stories.md (user stories with scoring)
   - architecture.md (ADRs, components)
3. Read the actual implementation (code, tests, configs)
4. Generate `docs/general/exportable/features/[feature].md` using **ski-project-docs** with:
   - What it does (user-facing description)
   - How it works (technical: architecture, data flow, key components)
   - How to use it (examples, configuration)
   - API endpoints (if applicable)
   - Known limitations
   - Related features
   - Evidence trail (linked to working-docs)
5. Update `docs/general/exportable/features/_index.md` (feature list)
6. Update `docs/general/exportable/changelog.md`

**If PM says no:**
Skip. Documentation can be generated later with `/docs [feature-name]`.

## Why Always Ask

The working-docs folder has EVERYTHING: the design analysis, PRD, research, JTBDs, stories, and architecture. Right after /review is the best moment to generate docs because:
- All context is fresh
- All artifacts exist
- The feature was just verified
- Nothing has been forgotten yet

Generating docs later is possible (`/docs [feature]`) but you'll have less context in the conversation.

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
