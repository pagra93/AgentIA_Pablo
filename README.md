# PM x10 Agent System

Tu sistema operativo de Product Management con IA. Orquesta 14 agentes especializados para cubrir el ciclo completo: desde diseños en Pencil hasta codigo deployado con QA verificado. Engineering: Claude Code implementa directamente + Impeccable para frontend design quality.

## Quick Start

```bash
chmod +x install.sh
./install.sh
```

Luego en cualquier proyecto con Claude Code:
```
/new-project         # Inicializar proyecto
/design-to-prd       # Analizar diseños → PRDs por feature
/analyze             # Evaluar problema/PRD + investigar gaps
/define              # Crear JTBDs y user stories
/plan                # Arquitectura y sprint plan
/build               # Implementar stories del sprint
/save                # Commit + push a GitHub
/review              # QA completo + documentar feature
/hotfix              # Bug fix rapido con learning
/code-review         # Solo revision de codigo
/unknown-unknowns    # Detectar riesgos ocultos en 8 dimensiones
/docs                # Generar documentacion completa del proyecto
/learned             # Guardar un aprendizaje en cualquier momento
```

## Segun el Tamano de la Tarea

| Tamano | Que usar | Ejemplo |
|--------|----------|---------|
| Trivial (<30 seg) | Prompt directo | "Cambia el color del boton" |
| Pequeno (1-4h) | /define + /build | "Exportar pedidos a PDF" |
| Mediano (1-3 dias) | /analyze + /define + /plan + /build + /review | "Notificaciones push" |
| Grande (1+ semana) | /design-to-prd + pipeline completo por feature | "Modulo de facturacion" |
| Bug fix | /hotfix o prompt directo | "Los pedidos no se guardan" |

## Architecture

```
pm-agent-system/
├── agent.yaml              # Manifest (gitagent spec extendida)
├── SOUL.md                 # Identidad del sistema (5 secciones)
├── RULES.md                # Constraints globales + anti-bloat rules
├── DUTIES.md               # Segregacion de responsabilidades + conflict matrix
│
├── agents/                 # 14 agentes (todos con agent.yaml + SOUL.md + DUTIES.md)
│   ├── age-spe-*           #   10 Especialistas (generan output)
│   └── age-sup-*           #   4 Supervisores (read-only, diagnostican y proponen)
│
├── skills/                 # 6 capacidades reutilizables (ski-*)
│   ├── ski-prd-builder/    #   Template PRD Quality Guard compliant
│   ├── ski-competitive-analysis/
│   ├── ski-plan-mode/
│   ├── ski-doc-updater/
│   ├── ski-unknown-unknowns/   # Detector riesgos ocultos (8 dimensiones, 6 references)
│   └── ski-project-docs/       # Documentacion completa para humanos
│
├── rules/                  # 6 reglas modulares (rul-*)
│   ├── rul-antipatterns    #   7 story + 5 PRD antipatterns (Mercadona methodology)
│   ├── rul-scoring-dimensional  # System A: PRD (3D, minimo) + System B: Stories (6D, promedio)
│   ├── rul-definition-of-done
│   ├── rul-definition-of-ready
│   ├── rul-naming-conventions
│   └── rul-git-branch-management
│
├── knowledge/              # 3 bases de conocimiento (kno-*)
│   ├── kno-jtbd-framework  #   JTBD Reforzado (8 elementos) + Wendel + Behavior Change
│   ├── kno-mom-test         #   Mom Test + Gap Detection + Interview Guides
│   └── kno-story-splitting  #   9 heuristicas Eduardo Ferro
│
├── workflows/              # 13 workflows DAG (wor-*)
├── commands/               # 13 slash commands para Claude Code
│
├── memory/                 # Estado persistente cross-session
│   ├── MEMORY.md           #   Working memory (max 200 lineas)
│   ├── memory.yaml         #   Config: quien lee/escribe, archive policy
│   └── archive/            #   Historial mensual
│
├── qa/                     # QA Layer (3 supervisores: audit → evaluate → optimize)
│   ├── qa-config.yaml      #   Tier (none/light/full), weights, thresholds
│   ├── qa-report.md        #   Append-only audit trail
│   └── README.md           #   Como funciona el QA cycle
│
├── hooks/                  # Lifecycle event handlers
├── examples/               # Calibracion (good/bad outputs + scenarios)
├── config/                 # default.yaml + production.yaml
├── compliance/             # Para proyectos regulados (opcional)
├── templates/              # CLAUDE-template.md para /new-project
└── install.sh              # Instalacion safe a ~/.claude/
```

## Agents (17)

### Specialists (10) — generan output
| Agent | Model | Phase | What it does |
|-------|-------|-------|-------------|
| design-analyst | opus | Analysis | Lee diseños de Pencil, extrae funcionalidad 6 capas (UI/DB/API/Logic/Integrations/Edge Cases) |
| quality-guard | opus | Analysis | Evalua PRDs en 3 dimensiones (Mercadona). Score = MINIMO. PASS/CONDITIONAL/FAIL |
| researcher | opus | Analysis | Mom Test, Gap Detection (3 categorias), JTBD Reforzado, Wendel Checklist |
| jtbd-architect | opus | Definition | JTBD Reforzado (8 elementos), Wendel, Behavior Change, 3 rangos |
| story-writer | opus | Definition | Stories con Given-When-Then, START/STOP/DIFFERENT, scoring 6D |
| story-splitter | sonnet | Definition | 9 heuristicas Eduardo Ferro, siempre vertical |
| tech-architect | opus | Planning | Arquitectura + ADRs + unknown-unknowns scan |
| sprint-planner | sonnet | Planning | Value/Effort, Definition of Ready, tasks/todo.md |
| test-engineer | sonnet | Testing | Tests desde acceptance criteria, ejecuta (no solo genera) |
| code-reviewer | opus | Testing | Memoria persistente, acumula patrones entre sesiones |

### Engineering — Sin agentes dedicados
Claude Code implementa directamente. Lee CLAUDE.md, sigue patrones existentes, incluye tests.

### Herramienta Externa Recomendada: Impeccable (no incluida, se instala aparte)
Para frontend design quality. NO es parte de este sistema — es un paquete externo.
- Instalar: `npx skills add pbakaus/impeccable`
- Web: https://impeccable.style/
- Comandos utiles despues de /build:
  - `/impeccable:audit` — evaluar calidad visual
  - `/impeccable:polish` — refinamiento general
  - `/impeccable:critique` — feedback de UX
  - `/impeccable:adapt` — responsive multi-device

### Supervisors (4) — read-only, diagnostican y proponen
| Agent | Model | Phase | What it does |
|-------|-------|-------|-------------|
| quality-coach | opus | Definition | Entrenador de Calidad: 6D scoring con hard rules, 7 antipatrones, reescrituras sugeridas |
| auditor | haiku | QA | Verificacion binaria de compliance (compliant/non-compliant) |
| evaluator | haiku | QA | Scoring 4 dimensiones ponderadas + trend analysis |
| optimizer | sonnet | QA | Memoria institucional, detecta patrones, propone mejoras |

## Design Principles

1. **Analysis Informs, Never Blocks** — Agents recommend, PM decides
2. **Vertical Value Delivery** — Every increment delivers end-to-end user value
3. **Supervisors Observe, Never Impose** — age-sup-* agents are read-only
4. **Evidence Over Assumptions** — All recommendations cite evidence
5. **QUE/COMO Separation** — Business defines the problem, Product designs the solution
6. **Anti-Bloat** — No duplicate docs, only save when resolved, threshold of significance
7. **PM Validates** — Tests passing != bug fixed. PM confirms from user perspective.

## Documentation Flow

```
During pipeline:  docs/working-docs/[feature]/  ← artefactos del proceso (automatico)
After /review:    docs/project-docs/features/    ← doc completa para humanos (pregunta)
Always:           docs/PROJECT_KNOWLEDGE.md      ← memo de Claude (automatico)
Any time:         tasks/lessons.md               ← aprendizajes (/learned, /hotfix, optimizer)
```

## Origin

Best-of-breed synthesis of:
- **GitAgent spec** — Structural foundation (agent.yaml, SOUL.md, RULES.md, DUTIES.md, hooks, workflows, memory)
- **PM Agent System (Mercadona)** — Domain methodology (Quality Guard, Mom Test, JTBD Reforzado, 6D scoring, QA Layer)
- **Architect** — UX philosophy ("show don't tell", practical approach)
- **Unknown Unknowns** — Risk detection across 8 dimensions (by Gaston Foncea)
