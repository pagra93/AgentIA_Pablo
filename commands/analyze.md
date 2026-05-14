---
description: "Launch Analysis phase — evaluate problem/PRD with Quality Guard, then research gaps."
---

# /analyze — Problem Analysis Pipeline

## Pre-flight: leer `prompt_override` de la HU

Antes de invocar cualquier agente sobre una HU o EPIC concreta:

1. Localiza el frontmatter YAML de esa HU en `docs/<área>/features/<feature>/stories.md`.
2. Lee el campo `prompt_override`. Si existe y no está vacío, **inclúyelo como contexto adicional explícito** en el mensaje al sub-agente: «Contexto adicional del usuario para esta tarea: <prompt_override>».
3. El sub-agente ya conoce la regla universal (ver `rul-prompt-override` precargado) y la respetará.
4. Si no hay `prompt_override`, procede normal.

Esto vale tanto si el usuario lanza el comando manualmente (clipboard) como si el PM lo lanza autónomamente.

---


## Step 1: Gather Context
Ask: "Describe the problem or paste the PRD you want me to analyze."
If file path provided, read it.

## Step 2: Quality Guard Evaluation
Invoke **age-spe-quality-guard**:
- Evaluate the problem/PRD across 3 dimensions
- Wait for the scoring report

## Step 3: Present Results and Ask PM
- Score >= 7: "Problem is well-defined. Shall I proceed to research?"
- Score 4-6: "Gaps identified. Proceed with elevated risk or address gaps first. Your call."
- Score < 4: "Significant gaps. High risk of solving wrong problem. Strongly recommend addressing. But it's your call."

**Never block. PM decides.**

### 3.1 Decisión crítica — registrar en _events.jsonl

Si Quality Guard score < 7 **y** PM decide proceder (no corregir gaps primero), esta es una **decisión crítica loggable**. Antes de continuar a Step 4, escribir entrada al `_events.jsonl` de la feature:

```jsonl
{"ts":"<ISO>","agent":"human","event":"decision","summary":"proceder con score X.X","context":"<razón humana 1 línea>","entity":"<EPIC-XXX o feature-slug>"}
```

Path: `docs/producto/features/<feature>/_events.jsonl` (crear si no existe). Si la feature folder aún no existe (caso primera ejecución), crearla.

## Step 4: Research (if PM proceeds)
Invoke **age-spe-researcher**:
- Research knowledge gaps using Mom Test methodology
- Execute competitive analysis
- Produce decision-ready brief

## Step 5: Deliver
Present research brief.

**Where to save**: If analyzing a feature from /design-to-prd, save to `docs/producto/features/[feature-name]/research.md`. Otherwise, save to `docs/producto/features/[topic-name]/research.md`. Always organize by feature, not by phase.

Next: "Use /define to generate JTBDs and stories from this research."

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
