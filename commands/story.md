---
description: "Build a quality user story from an idea — no PRD required. The agent works autonomously through 7 internal phases."
---

# /story — Story Builder

## Input
Idea, problema, conversacion, o contexto del PM. No requiere PRD, research previo, ni documentos.

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
Save to `docs/working-docs/[feature-name]/stories.md`
If no feature folder exists, create it.

## Recommended Next Steps (Iterative Flow)

```
/story → Story Draft → Diseñar en Pencil → /design-to-prd → Revisar story → /plan → /build
```

1. **Si no hay diseño**: Crear diseño en Pencil basandose en la story draft. Luego `/design-to-prd` para analizar. Si el diseño revela requisitos nuevos, actualizar la story.
2. **Si ya hay diseño**: Usar `/design-to-prd` para comparar con el analisis derivado. Actualizar story si hay discrepancias.
3. **Sin diseño (fast track)**: Ir directo a `/plan`. La story es deployable sin diseño, pero con mayor riesgo de retrabajo UX.
4. **Cerrar gaps**: Usar `/analyze` si hay [GAP] o [HIPOTESIS] que requieren investigacion.
