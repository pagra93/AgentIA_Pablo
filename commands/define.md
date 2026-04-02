---
description: "Launch Definition phase — transform research into JTBDs, stories, quality review, and splitting. Detects existing stories from /design-to-prd and enriches them instead of duplicating."
---

# /define — Definition Pipeline

## Input
Research brief from /analyze, or user-provided context.

## Step 0: Detect Existing Stories

Before starting, check if `docs/working-docs/[feature]/stories.md` already exists (from `/design-to-prd`).

- **Si existe**: Modo **Enrich** — los JTBDs se mapean a stories existentes, el story-writer enriquece secciones [DERIVADO] preservando Diseno y Notas tecnicas.
- **Si NO existe**: Modo **Create** — pipeline completo, genera stories desde cero.

## Step 1: Generate JTBDs
Invoke **age-spe-jtbd-architect** with the research brief.
- En modo **Enrich**: el architect tambien recibe las stories existentes para mapear cada JTBD a una story ya identificada.
Present JTBDs. Ask PM: "Approve, modify, or add?"

## Step 2: Write Stories
Invoke **age-spe-story-writer** with approved JTBDs.
- En modo **Enrich**: el writer recibe stories existentes + mapping JTBD→Story. Enriquece secciones debiles, preserva secciones fuertes del design-analyst.
- En modo **Create**: genera stories desde cero en formato kno-story-ticket-template.

## Step 3: Quality Review
Invoke **age-sup-quality-coach** to review stories.
If any story scores < 7:
- Present suggestions to PM
- "Accept suggestions, modify, or proceed as-is?"
- If accepted: rerun story-writer with suggestions

## Step 4: Split Large Stories
Invoke **age-spe-story-splitter** only for stories flagged as >3 days.

## Step 5: Deliver
Present final stories with scoring.
- En modo **Enrich**: mostrar que secciones se upgradearon (Historia, Definicion, Scoring) y que secciones se preservaron (Diseno, Notas tecnicas).
- En modo **Create**: presentar stories completas con marcadores de confianza.

**Where to save**: Save to the feature's folder:
- `docs/working-docs/[feature-name]/jtbds.md` — JTBDs generated
- `docs/working-docs/[feature-name]/stories.md` — Stories (nuevas o enriquecidas)

If no feature folder exists, create it. Always organize by feature, not by phase.

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
