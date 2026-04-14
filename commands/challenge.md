---
description: "Sparring partner estrategico — desafia premisas, debate, hace preguntas incomodas, fuerza evidencia. Dos modos: ideacion y revision."
---

# /challenge — Strategic Challenger

## Step 1: Gather Context
Leer silenciosamente (NO mostrar al PM):
- CLAUDE.md del proyecto (si existe)
- `git log --oneline -20` (actividad reciente)
- docs/working-docs/ (features en progreso)
- tasks/lessons.md (lecciones relevantes)

## Step 2: Detect Mode
Si argumento proporcionado:
- `/challenge idea` → Modo Ideacion
- `/challenge plan` → Modo Revision

Si no hay argumento, preguntar: "¿Que quieres que desafie?"
- Si describe una idea o problema → Modo Ideacion
- Si tiene PRD, plan, stories, o arquitectura → Modo Revision

## Step 3: Challenge Session
Invoke **age-sup-strategic-challenger** en el modo detectado.

El agente interactua directamente con el PM:
- Una pregunta a la vez
- Empuja cada respuesta hasta especificidad y evidencia
- Toma posicion, no es neutral
- Genera alternativas (minimo 2) y aplica inversion

### Modo Ideacion
6 Forcing Questions → Premise Challenge → Alternativas → Inversion → Brief

### Modo Revision
Premise Challenge → Elegir scope (expansion/hold/reduccion) → 5 Lentes Estrategicos → Brief

## Step 4: Strategic Brief
El agente produce el brief con:
- Premisas desafiadas (validadas / cuestionadas / refutadas)
- Riesgos surfaced via inversion
- Alternativas exploradas (minimo 2)
- Decisiones del PM documentadas

**Where to save**: `docs/working-docs/[topic]/challenge-brief.md`

## Step 5: Next Step
Segun el modo:
- Ideacion → "/analyze para evaluar el problema, o /story para construir directamente"
- Revision → "/build si estas convencido, o ajusta el plan/stories primero"

**Never block. PM decides.**
