# Plan V3: Reorganización a "Cerebro Digital de Empresa"

## Context

Auditoría de la estructura actual reveló 6 problemas:

1. `qa-reports/` (en `/new-project`) vs `qa/` (en agentes/commands) — mismo concepto, dos nombres
2. `docs/working-docs/` vs `docs/working_docs/` (con guion bajo) — escrito de dos formas en distintos sitios
3. `docs/project-docs/` (en `/docs`) vs `docs/working-docs/` (en `/define`) — confusión semántica
4. `docs/architecture/` aparece sin estar definido en la estructura inicial
5. **11 cosas en la raíz del proyecto** (.claude, dashboard, inbox.md, tasks.json, config.json, docs, tasks, qa, memory, ...) sin separación entre "estado operativo" y "documentos"
6. **No hay sitio claro** para Marketing/RRHH/Operaciones cuando lleguen — todo está pensado solo para Producto

V3 reorganiza la estructura para que sea coherente, escalable a multi-área y con la raíz limpia. Es **paso previo obligatorio** a V2.2 (edición inline en dashboard) — si reordenamos después, hay que tocar V2.2-V2.5 dos veces.

**Decisiones confirmadas con el usuario:**
- Hay varios proyectos VIVOS en producción → necesario script de migración robusto
- Full reorg (no parches mínimos)
- Antes de continuar V2.2

## Estructura nueva

```
proyecto/
├── .claude/
│   └── CLAUDE.md                            ← convención Claude Code
├── dashboard/                                ← UI (sirve a TODAS las áreas)
│   ├── bridge.py
│   ├── index.html
│   ├── styles.css
│   └── app.js
├── pm/                                       ← Estado operativo del PM (NO editar a mano)
│   ├── tasks.json
│   ├── config.json
│   ├── events.jsonl
│   └── build-state.md
├── docs/                                     ← Cerebro digital de la empresa
│   ├── README.md                             ← Mapa de la empresa (auto-generado)
│   ├── general/                              ← Info cross-área
│   │   ├── PROJECT_KNOWLEDGE.md
│   │   ├── project-registry.md
│   │   └── exportable/                       ← output de /docs (Docusaurus, etc.)
│   ├── producto/                             ← Caja completa del área
│   │   ├── inbox.md                          ← buzón propio
│   │   ├── sprint.md                         ← era tasks/todo.md
│   │   ├── lessons.md                        ← era tasks/lessons.md
│   │   ├── qa.md                             ← era qa/qa-report.md
│   │   └── features/
│   │       └── [feature-name]/
│   │           ├── stories.md
│   │           ├── jtbds.md
│   │           ├── prd.md
│   │           ├── architecture.md
│   │           └── research.md
│   ├── marketing/                            ← Estructura espejo, sin activar hoy
│   │   ├── inbox.md                          ← buzón propio
│   │   └── README.md                         ← "Área no activada — pendiente PM de Marketing"
│   ├── rrhh/                                 ← Espejo
│   ├── operaciones/                          ← Espejo
│   └── (otras áreas según se activen en pm/config.json)
├── memory/                                   ← Convención code-reviewer (Claude Code)
│   └── MEMORY.md
└── (código del usuario: src/, package.json, ...)
```

**Áreas:**
- Lista canónica de áreas vive en `pm/config.json` campo `areas`
- Cada área tiene un campo `active: true|false`
- El dashboard lee `pm/config.json` y muestra todas (las inactivas greyed)
- Activar un área = cambiar `active: true` + crear los archivos correspondientes (lo hace el PM o el usuario manualmente)

**Lo que se queda igual:**
- `.claude/CLAUDE.md` (convención CC)
- `memory/MEMORY.md` (convención code-reviewer)
- `dashboard/` (la UI)
- Los 16 agentes y sus skills/rules

## Mapeo viejo → nuevo (canónico)

| Viejo | Nuevo |
|---|---|
| `inbox.md` | `docs/producto/inbox.md` |
| `tasks.json` | `pm/tasks.json` |
| `config.json` | `pm/config.json` |
| `tasks/todo.md` | `docs/producto/sprint.md` |
| `tasks/lessons.md` | `docs/producto/lessons.md` |
| `tasks/events.jsonl` | `pm/events.jsonl` |
| `tasks/build-state.md` | `pm/build-state.md` |
| `qa/qa-report.md` | `docs/producto/qa.md` |
| `qa-reports/` | (eliminar — era duplicado de qa/) |
| `docs/PROJECT_KNOWLEDGE.md` | `docs/general/PROJECT_KNOWLEDGE.md` |
| `docs/project-registry.md` | `docs/general/project-registry.md` |
| `docs/working-docs/[feature]/` | `docs/producto/features/[feature]/` |
| `docs/working_docs/...` | `docs/producto/features/...` (guion bajo era bug) |
| `docs/project-docs/` | `docs/general/exportable/` |
| `docs/architecture/` | `docs/producto/features/[feature]/architecture.md` |
| `memory/MEMORY.md` | `memory/MEMORY.md` (sin cambio) |
| `.claude/CLAUDE.md` | `.claude/CLAUDE.md` (sin cambio) |
| `dashboard/` | `dashboard/` (sin cambio) |

## Archivos a tocar (orden recomendado)

### Fase A: infraestructura

1. `scripts/migrate-to-v3.sh` — script de migración con `--dry-run` y `--apply`
2. `dashboard-template/bridge.py` — leer áreas dinámicamente desde `pm/config.json`
3. `templates/config-template.json` — añadir lista de áreas con paths

### Fase B: agentes (16 DUTIES.md)

Cambios mecánicos: replace de rutas viejas por nuevas. Todos los agentes que mencionen:
- `tasks/todo.md` → `docs/producto/sprint.md`
- `tasks/lessons.md` → `docs/producto/lessons.md`
- `qa/qa-report.md` → `docs/producto/qa.md`
- `docs/working-docs/` → `docs/producto/features/`
- `docs/working_docs/` → `docs/producto/features/`
- `inbox.md` → `docs/producto/inbox.md`
- `tasks.json` → `pm/tasks.json`
- `config.json` → `pm/config.json`
- `tasks/events.jsonl` → `pm/events.jsonl`
- `tasks/build-state.md` → `pm/build-state.md`
- `docs/PROJECT_KNOWLEDGE.md` → `docs/general/PROJECT_KNOWLEDGE.md`
- `docs/project-registry.md` → `docs/general/project-registry.md`

### Fase C: commands (~10 archivos)

Mismo replace que agentes. Comandos: analyze, define, plan, build, review, save, story, design-to-prd, hotfix, code-review, learned, docs, unknown-unknowns, challenge, pm.

### Fase D: new-project.md

Reescribir Step 2 con la nueva estructura. Crear:
- `pm/{tasks.json, config.json, events.jsonl, build-state.md}`
- `docs/general/{PROJECT_KNOWLEDGE.md, project-registry.md}`
- `docs/producto/{inbox.md, sprint.md, lessons.md, qa.md}`
- `docs/producto/features/.gitkeep`
- `docs/marketing/README.md` ("área no activada")
- `docs/rrhh/README.md`
- `docs/operaciones/README.md`
- `memory/MEMORY.md`
- `.claude/CLAUDE.md`
- `dashboard/` (copy from `~/.claude/dashboard-template/`)

### Fase E: templates y guía HTML

- `templates/CLAUDE-template.md` — actualizar paths
- `pm-agent-system-guia-de-uso.html` — actualizar tab Carpetas y todas las menciones de rutas

### Fase F: dashboard

- `bridge.py` — `AREAS` deja de ser hardcoded; lee de `pm/config.json`
- Verificar que el árbol funciona con la nueva estructura
- Verificar que el viewer renderiza .md desde nuevas rutas

## Script de migración

`scripts/migrate-to-v3.sh`:

```bash
#!/usr/bin/env bash
# Reorganiza un proyecto PM x10 de estructura V2 a V3.
# Idempotente: ejecutar dos veces no rompe nada.
# Por defecto dry-run. Usar --apply para ejecutar.

set -euo pipefail

DRY_RUN=true
[ "${1:-}" = "--apply" ] && DRY_RUN=false

# ... (validaciones, mv idempotentes, limpieza de carpetas vacías)
```

Características:
- `--dry-run` por defecto (solo imprime las acciones)
- `--apply` ejecuta de verdad
- Idempotente: si ya está migrado, no hace nada
- Avisa antes de tocar nada y pide confirmación en `--apply`
- Recomienda hacer `git commit` antes
- Backup opcional a `.pm-backup/` antes de mover

## Lo que NO cambia

- Nombres de los 16 agentes
- Comportamiento del PM (8 estados, transiciones)
- Skills/rules/knowledge
- Los slash commands existentes (siguen llamándose igual)
- `~/.claude/agents/`, `~/.claude/commands/`, `~/.claude/skills/` (instalación global)

## Verificación

1. Crear proyecto de prueba `/tmp/v3-test`
2. Ejecutar `/new-project` → verificar nueva estructura
3. Crear archivos de prueba en `docs/producto/inbox.md`, `docs/producto/features/auth/stories.md`
4. Arrancar dashboard: `python3 dashboard/bridge.py`
5. Verificar que el árbol muestra estructura nueva correctamente
6. Verificar que las áreas Marketing/RRHH/Operaciones aparecen como inactivas
7. Migrar un proyecto vivo con `--dry-run`, revisar output, luego `--apply`
8. Verificar que el proyecto migrado funciona igual que antes

## Después de V3

Continuamos con V2.2 (edición inline en dashboard) sobre la estructura nueva.
