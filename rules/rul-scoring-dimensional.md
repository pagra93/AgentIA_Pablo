---
name: rul-scoring-dimensional
description: "Scoring systems for PRD evaluation (Quality Guard, 3 dimensions) and story quality (6 dimensions). Unified language across all quality agents."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "2.0.0"
  category: quality
  source: "AI Mercadona User Story Framework"
  loaded-by: [age-spe-quality-guard, age-spe-story-writer, age-sup-quality-coach, age-sup-auditor]
---

# Scoring Systems

This file defines TWO scoring systems used by different agents.

---

# System A: PRD Scoring (Quality Guard — 3 Dimensions)

Used by age-spe-quality-guard to evaluate PRDs before product starts designing.

**CRITICAL: Score final = MINIMO de las 3 dimensiones (no promedio).**

## PRD-D1: Completitud del Problema (0-10)

Existe suficiente informacion cuantitativa y cualitativa?

Verifica: (a) Metricas baseline+target, (b) Observaciones de campo con verbatim, (c) Impacto en personas/procesos/herramientas.

- 9-10: Metricas baseline+target claras, Gemba walk reciente con verbatim, impacto cuantificado
- 7-8: Metricas parciales (baseline sin target o viceversa), observaciones presentes
- 5-6: Datos parciales, impacto vago, pocas observaciones
- 3-4: Algun numero suelto, sin observaciones de campo
- 0-2: Sin metricas ni claridad. Solo opiniones.

## PRD-D2: Calidad del Proceso (0-10)

Esta documentado como funciona hoy y como deberia funcionar?

Verifica: (a) AS-IS detallado con pasos/actores/herramientas, (b) TO-BE idealizado sin prescribir tecnologia, (c) Actores y handoffs claros.

- 9-10: AS-IS detallado, TO-BE idealizado, actores claros con handoffs
- 7-8: AS-IS presente, TO-BE parcial, actores identificados
- 5-6: Descripcion superficial del proceso
- 3-4: Descripcion vaga sin actores
- 0-2: Sin descripcion de proceso

## PRD-D3: Separacion QUE/COMO (0-10, deductivo)

Empieza en 10. Resta por cada antipattern de contaminacion detectado (ver rul-antipatterns Part A).

- Critical antipattern: -3 (JTBDs in PRD, Technical Prescriptions)
- High antipattern: -2 (UI/UX Prescriptions, Solution Language)
- Medium antipattern: -1 (Hypothesis as Requirement)

Apply Alternative Tool Test: if replacing digital with paper/manual and description still works, it's a legitimate problem.

## PRD Verdicts

- **PASS** (>= 7.0): Listo. Producto puede disenar con confianza.
- **CONDITIONAL** (5.0 - 6.99): Cerca pero con agujeros. Generar handoff document.
- **FAIL** (< 5.0): Muy lejos. Generar escalation document.

---

# System B: Story Scoring (Story Writer / Quality Coach — 6 Dimensions)

Used by age-spe-story-writer and age-sup-quality-coach to evaluate user stories.

**Score final = PROMEDIO de las 6 dimensiones.**

Every story is scored 0-10 on 6 dimensions. This is the unified quality language.

## D1: JTBD Context (0-10)
Qualitative and quantitative evidence of the problem?
- 9-10: Rich evidence — field observations, metrics with baseline+target, user quotes
- 7-8: Good evidence, minor gaps
- 5-6: Partial evidence
- 3-4: Mostly assumptions
- 0-2: No evidence

## D2: User Specificity (0-10)
Answers the 4 Wendel Checklist questions?
- 9-10: All 4 answered with evidence
- 7-8: 3 of 4 clear
- 5-6: 2 of 4
- 3-4: Generic persona
- 0-2: No user specification

## D3: Behavior Change (0-10)
What will the user do differently? Quantified?
- 9-10: Quantified START/STOP/DIFFERENT with frequency
- 7-8: Clear change, partially quantified
- 5-6: Vague ("will be faster")
- 3-4: Implicit only
- 0-2: No behavior change (tech task)

## D4: Zone of Control (0-10)
Team controls the deliverable?
- 9-10: 100% team controlled
- 7-8: >80%, minor external dependency
- 5-6: >60%, significant dependency
- 3-4: Shared control
- 0-2: External dependency dominates

## D5: Time Constraints (0-10)
Is the urgency real?
- 9-10: Real deadline with documented consequences
- 7-8: Reasonable urgency with business driver
- 5-6: Vague urgency
- 3-4: No real urgency
- 0-2: Artificial urgency

## D6: Survivable Experiment (0-10)
What happens if we're wrong?
- 9-10: Minimal impact, easy to revert, learning is valuable
- 7-8: Recoverable with moderate effort
- 5-6: Moderate impact, manageable
- 3-4: Significant impact, hard to revert
- 0-2: Catastrophic, irreversible

## Story Scoring Rules

- **Average >= 7**: Ready (passes Definition of Ready)
- **Average 4-6**: Needs improvement before sprint
- **Average < 4**: Not ready, significant rework needed
- **Any dimension < 3**: Automatic flag regardless of average

---

# Summary: When to Use Which System

| Context | System | Dimensions | Score Method | Verdicts |
|---------|--------|------------|-------------|----------|
| Evaluating a PRD | System A (Quality Guard) | 3: Completitud, Proceso, QUE/COMO | MINIMO | PASS/CONDITIONAL/FAIL |
| Evaluating user stories | System B (Story Quality) | 6: JTBD, User, Behavior, Control, Time, Experiment | PROMEDIO | Ready/Improve/Not Ready |
