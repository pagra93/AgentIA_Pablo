---
description: "Orquestador gobernado — recorre el pipeline completo (research/definición → plan → build → review) de forma autónoma, parando en 3 gates donde el PM aprueba. Autonomía sin perder control."
---

# /auto — Pipeline autónomo gobernado

Recorre el pipeline de producto de punta a punta **solo**, encadenando los comandos y agentes reales, pero
**parando en 3 puntos de control** donde el PM aprueba antes de seguir. Entre gates, trabaja sin supervisión.

> **Filosofía**: autonomía dentro de fases acotadas + gates humanos en las decisiones que **componen** (scope,
> arquitectura, merge). NO es "fire-and-forget" total — eso contradice la gobernanza del sistema (PM controla
> el kanban, `rul-fail-loud`, auditabilidad). El push **nunca** es automático.

## Uso

```
/auto <feature | HU-XXX | idea o problema>
```

## Pre-flight: leer `prompt_override`

Antes de invocar cualquier agente sobre una HU/EPIC concreta, localiza su frontmatter en
`docs/<área>/features/<feature>/stories.md`, lee `prompt_override` y, si existe, inclúyelo como contexto
explícito a cada sub-agente. (Regla universal `rul-prompt-override`, ya precargada.)

## Reglas de toda la ejecución

- **`rul-fail-loud`**: en cada transición reporta qué se hizo, qué está verificado y qué se saltó. **Nunca**
  declares una fase "completada" si quedó parcial o sin verificar.
- **Estado del kanban**: mueve el item por los estados reales (`research → definicion → planning → build →
  review → hecho`) y **apárcalo en el estado del gate** esperando aprobación del PM.
- **Bloqueo**: si una fase no puede completarse (falta información, tests fallan tras 3 ciclos del
  test-engineer, dependencia sin resolver) → **PARA**, marca el item `bloqueada`, reporta la causa concreta.
  No fuerces el paso.
- **Commits**: `/build` hace commit atómico por story (ya es su comportamiento). El **push es manual** (`/save`).
- **Presupuesto**: en sesión interactiva el control de coste son los gates (el PM ve el avance y decide). Para
  un tope duro en dinero, lanza en modo headless: `claude -p "/auto <feature>" --max-budget-usd N --max-turns M`.

---

## Paso 0: Detección de entrada + estado

1. **Estado actual del item**: si ya existe en `pm/tasks.json`/stories, detecta en qué fase está y **reanuda
   desde ahí** (no rehagas fases ya hechas). Si ya hay stories válidas → salta a Planning. Si ya hay
   arquitectura → salta a Build. Etc.
2. **Tipo de input** (elige el camino del frente):
   - Hay **diseño Pencil** referenciado → camino diseño: `/design-discovery` (genera `functional-brief.md`) +
     `/design-to-prd` (genera stories + PRD).
   - **Problema/idea que necesita validación** → camino research: `/analyze` (researcher Mom Test +
     quality-guard) y luego `/define`.
   - **Idea pequeña y clara** → camino rápido: `/story` (story-builder autónomo).
   - **Ya hay stories** → directo a Planning.
3. **Anuncia el plan**: di qué camino tomaste y recuerda que pararás en 3 gates (Scope, Arquitectura, Done).

## Paso 1: Research / Definición

Ejecuta el frente según el camino del Paso 0. Termina **siempre** con stories válidas:
- Camino `/define`: **jtbd-architect** → **story-writer** → **quality-coach** (revisión) → **story-splitter**
  (divide las >3 días).
- Camino diseño: **design-discoverer** + **design-analyst**.
- Camino research: **researcher** + **quality-guard** antes de `/define`.
- **Opcional** (features grandes o arriesgadas): **strategic-challenger** (`/challenge`) para presionar
  premisas antes de comprometer scope.

### ⛔ GATE 1 — Scope
**PARA. Pide aprobación del PM.** Presenta:
- Las stories generadas con su **6D scoring**.
- El **veredicto del quality-coach**.
- Si se corrió, los **hallazgos del strategic-challenger**.
- **Asunciones de baja confianza** marcadas (`rul-fail-loud`).

No avances a Planning hasta que el PM apruebe o ajuste el scope.

## Paso 2: Planning

Ejecuta `/plan`:
- **tech-architect** — diseña arquitectura. **Lee primero `docs/general/architecture-map.json`** (vía
  `ski-architecture-map` READ) para **extender, no duplicar** lo existente. Genera ADRs.
- **sprint-planner** — prioriza stories y crea el sprint con dependencias.

### ⛔ GATE 2 — Arquitectura (el más importante)
**PARA. Pide aprobación del PM.** Presenta los **ADRs** (decisiones + alternativas) y el **sprint**. La
arquitectura es lo más caro de equivocar — no construyas hasta que el PM apruebe.

## Paso 3: Build

Ejecuta `/build`:
- Un **sub-agente por story** con contexto fresco (200k), que lee story + diseño + arquitectura, implementa y
  hace **commit atómico**.
- Autónomo entre stories (cada una está acotada y commiteada → no hace falta gate entre ellas).
- Si una story se **bloquea** (stubs sin resolver, verificación estructural falla): aplica la regla de bloqueo
  (PARA, `bloqueada`, reporta).

## Paso 4: Review

Ejecuta `/review`:
- **test-engineer** (loop de validación, máx 3 ciclos) → **code-reviewer** (calidad/perf + **pasada de
  seguridad** `kno-security-review`) → **auditor** → **evaluator** → **optimizer** → doc-updater
  (+ **UPDATE del `architecture-map`**).

### ⛔ GATE 3 — Done / Merge
**PARA. Pide aprobación del PM.** Presenta:
- Resultados de review (tests, cobertura, regresiones).
- **Hallazgos de seguridad** por severidad (si hay Crítica/Alta sin aceptar, dilo claramente).
- Estado de la Definition of Done.

No marques el item `hecho` ni sugieras `/save` hasta que el PM apruebe. **El push lo hace el PM** (`/save`).

---

## Cuándo NO usar `/auto`

- Bug suelto → `/hotfix` (pipeline ligero aparte).
- Una sola fase concreta → el comando directo (`/define`, `/plan`, etc.).
- Trabajo transversal (wiki, docs) → su comando.

## Auto-sync con PM (tras cada fase, automático)

Al completar cada fase (no solo al final), ejecuta **age-spe-pm-producto** en modo `sync` + `dossier all`
para que el dashboard refleje el nuevo estado (kanban + tabla + dossiers) sin intervención. Reporta drift solo
si lo detecta.

## Futuro (no en v1)
- Modo `express` con menos gates (p.ej. solo el de arquitectura) cuando haya confianza acumulada en el flujo.
