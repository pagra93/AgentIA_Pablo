---
description: "PM de Producto: índice + buzón + dossiers contextuales. Modos: sync, inbox, next, status, prioritize, block, unblock, done, cancel, dossier. Ejecuta age-spe-pm-producto."
---

# /pm — PM de Producto

Coordinador del área Producto. Mantiene `pm/tasks.json` como índice derivado del filesystem, procesa `docs/producto/inbox.md`, infiere estado de cada tarea y permite acciones explícitas (priorizar, bloquear, aprobar).

**Es agente por área.** Cuando llegue Marketing, RRHH, Operaciones, cada área tendrá su propio PM (`age-spe-pm-marketing`, etc.) con sus propios estados.

## Sintaxis

```
/pm                              → sync + next + status (modo default)
/pm sync                         → re-indexa filesystem
/pm inbox                        → procesa inbox.md
/pm next                         → propone qué arrancar
/pm status                       → resumen del kanban
/pm prioritize HU-XXX            → mueve a backlog_priorizado
/pm block HU-XXX <razón>         → bloquea con razón
/pm unblock HU-XXX               → desbloquea (restaura estado anterior)
/pm done HU-XXX                  → aprueba manualmente
/pm cancel HU-XXX <razón>        → descarta
/pm dossier <feature|all>        → regenera _dossier.md y _events.jsonl
```

## Modos

### `/pm` (default) → sync + next + status

Ejecución completa. Reindexa, propone qué arrancar, muestra el estado.

### `/pm sync`

Lee filesystem (`stories.md`, `docs/producto/sprint.md`, `docs/producto/qa.md`, `pm/build-state.md`, `architecture.md`, `research.md`, `jtbds.md`) + `pm/events.jsonl` (si existe). Reconstruye `pm/tasks.json` con la inferencia de estado por precedencia. Reporta drift.

### `/pm inbox`

Lee `docs/producto/inbox.md`. Clasifica cada entrada (épica/tarea/subtarea), asigna ID estable, sugiere agente y criticality. Crea entradas en `pm/tasks.json` con estado `backlog_sin_priorizar`. Vacía las líneas consumidas.

### `/pm next`

Propone 3-5 tareas listas para arrancar (dependencias resueltas, ordenadas por criticality). Indica con qué slash command empieza la siguiente fase.

### `/pm status`

Resumen visual textual: contadores por columna del kanban, drift activo, recordatorio de entradas pendientes en inbox.

### `/pm prioritize HU-XXX`

Cambia estado de `backlog_sin_priorizar` a `backlog_priorizado`. Añade entrada en `docs/producto/sprint.md`. Es la única forma manual de mover una tarea al sprint sin pasar por `sprint-planner`.

### `/pm block HU-XXX <razón>`

Marca la tarea como bloqueada. Guarda el estado actual en `previous_status` y la razón en `blocked_reason`. Actualiza el frontmatter de la story afectada (`blocked: true`).

### `/pm unblock HU-XXX`

Restaura el estado anterior al bloqueo. Limpia `blocked` y `blocked_reason`. Actualiza el frontmatter de la story (`blocked: false`).

### `/pm done HU-XXX`

Marca como `hecho` sin pasar por `/review`. Útil para ideas descartadas formalmente, tareas no-build (decisiones, comunicaciones), o trabajo aprobado fuera del pipeline estándar.

### `/pm cancel HU-XXX <razón>`

Estado terminal `cancelado`. La tarea queda archivada pero visible en histórico. Distinto de `done` porque no se considera "hecho" para métricas.

### `/pm dossier <feature-slug | all>` (V3.1)

Regenera la vista contextual unificada (`_dossier.md`) y el timeline (`_events.jsonl`) de una feature folder. **Auto-invocado** desde el bloque auto-sync de los 8 commands principales (`/story`, `/define`, `/design-to-prd`, `/plan`, `/build`, `/review`, `/hotfix`, `/analyze`).

- `<feature-slug>`: regenera solo esa feature.
- `all`: detecta features modificadas en los últimos 60 segundos y regenera sus dossiers.

**Idempotente**: ejecutar dos veces produce el mismo resultado (excepto `last_updated_at`). Los eventos en `_events.jsonl` NO se duplican (detección por `(ts, agent, event, entity)`).

**Preserva** la sección `<!-- USER:notes -->` del dossier — Pablo puede editarla libremente sin temor a sobrescrituras.

Ver `~/.claude/templates/feature-dossier-template.md` y `~/.claude/templates/feature-events-jsonl-schema.md` para schemas completos.

## Pipeline

1. Invocar **age-spe-pm-producto** con el modo y argumentos
2. El agente lee `pm/config.json` para conocer agentes, estados y transiciones
3. Ejecuta el modo solicitado
4. Reporta al usuario en formato markdown estructurado

## Output esperado

Cada modo produce un reporte con:
- Resumen (1-3 líneas)
- Detalles (tabla o lista)
- Acciones sugeridas
- Drift detectado (si aplica)

## Activity log (opcional)

`pm/events.jsonl` es opcional. Si existe, el PM lo consume al sincronizar y enriquece `last_activity` y `activity_count` por tarea. Cualquier agente o slash command puede añadir eventos:

```jsonl
{"ts":"2026-05-01T10:00:00Z","task_id":"HU-042","agent":"age-spe-researcher","phase":"en_analisis","event":"started","summary":"Iniciado research"}
{"ts":"2026-05-01T11:30:00Z","task_id":"HU-042","agent":"age-spe-researcher","phase":"en_analisis","event":"completed","summary":"Completado","output_files":["docs/producto/features/auth/research.md"]}
```

Sin el archivo, el PM funciona igual inferenciando por presencia de archivos en filesystem.

## Notas

- El PM nunca invoca a otros agentes. Solo propone.
- El PM nunca bloquea flujo. Si lanzas `/build` directamente, el próximo `/pm sync` reconcilia.
- IDs son inmutables. `HU-001` siempre será la misma tarea aunque la renombres.
- Activity log es opcional. Si los slash commands no lo escriben, el PM infiere por filesystem.
