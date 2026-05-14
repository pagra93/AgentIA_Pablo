---
description: "Launch Planning phase — design architecture and create sprint plan from validated stories."
---

# /plan — Planning Pipeline

## Pre-flight: leer `prompt_override` de la HU

Antes de invocar cualquier agente sobre una HU o EPIC concreta:

1. Localiza el frontmatter YAML de esa HU en `docs/<área>/features/<feature>/stories.md`.
2. Lee el campo `prompt_override`. Si existe y no está vacío, **inclúyelo como contexto adicional explícito** en el mensaje al sub-agente: «Contexto adicional del usuario para esta tarea: <prompt_override>».
3. El sub-agente ya conoce la regla universal (ver `rul-prompt-override` precargado) y la respetará.
4. Si no hay `prompt_override`, procede normal.

Esto vale tanto si el usuario lanza el comando manualmente (clipboard) como si el PM lo lanza autónomamente.

---


## Input
Validated stories from /define.

## Step 1: Architecture Design
Invoke **age-spe-tech-architect** with stories. Must read CLAUDE.md for stack constraints AND `docs/general/project-registry.md` for existing assets.
- Do NOT redesign tables/services that already exist in the registry (`planned` or `active`)
- Architecture extends existing assets, never duplicates them
- Reference registry assets by name when designing data flow

Present architecture. Ask PM: "Approve or adjust?"

**Decisión crítica loggable** si el architect generó un ADR (decisión arquitectural con tradeoffs) y PM lo aprobó. Escribir al `_events.jsonl` de la feature:
```jsonl
{"ts":"<ISO>","agent":"human","event":"decision","summary":"aprobar ADR: <título-ADR>","context":"<por qué se eligió esta opción>","entity":"<feature-slug>"}
```

## Step 2: Sprint Planning
Invoke **age-spe-sprint-planner** with stories + architecture.
Sprint plan written to `docs/producto/sprint.md`.

## Step 3: Confirm
Present the sprint plan. Ask PM: "Approve this plan to start building?"

Next: "Use /build to start executing the sprint."

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
