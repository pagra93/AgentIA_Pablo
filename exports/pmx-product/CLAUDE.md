# PM x10 — Quick Reference

Sistema operativo de Product Management con IA. Paquete first-class del arquitecto (`AgentArchitect/exports/pmx-product/`).

> Generado el 2026-05-18 como parte de la migración al arquitecto. Si vienes de la versión anterior de PM x10, todo sigue funcionando idéntico — esto es solo un quick-reference añadido.

## Identidad

Paquete: `pmx-product`
Prefix: `pmx` (los agentes de PM x10 NO usan prefix consistente — son `age-spe-pm-producto`, `age-spe-story-builder`, `age-sup-auditor`, etc. — predates la convención del arquitecto)
Dominio: `product-management`
Versión: 2.3.0
Estado: producción

## Los 19 agentes

**Especialistas (14)**:
- `age-spe-design-discoverer` — Discovery funcional sobre diseños: entrevista al PM una pregunta por turno antes del PRD (Trigger: `/design-discovery`)
- `age-spe-quality-guard` — Evalúa PRDs (Trigger: `/analyze`)
- `age-spe-researcher` — Investiga gaps con Mom Test (Trigger: `/analyze`)
- `age-spe-design-analyst` — Analiza diseños Pencil → stories verticales (Trigger: `/design-to-prd`)
- `age-spe-jtbd-architect` — Research → JTBDs (Trigger: `/define`)
- `age-spe-story-writer` — JTBDs → stories (Trigger: `/define`)
- `age-spe-story-builder` — Story autónomo desde idea (Trigger: `/story`)
- `age-spe-story-splitter` — Descompone stories >3 días (Trigger: `/define`, `/story`)
- `age-spe-tech-architect` — Diseña arquitectura desde stories (Trigger: `/plan`)
- `age-spe-sprint-planner` — Prioriza stories y crea sprint plan (Trigger: `/plan`)
- `age-spe-test-engineer` — Validation loop: tests, coverage (Trigger: `/review`)
- `age-spe-code-reviewer` — Code review con memoria persistente (Trigger: `/review`, `/code-review`)
- `age-spe-pm-producto` — PM de Producto: índice + buzón + dossiers (Trigger: `/pm`)
- `age-spe-wiki-curator` — Wiki transversal de empresa (Trigger: `/wiki`)

**Supervisores (5)**:
- `age-sup-quality-coach` — Evalúa stories sin modificar (Trigger: `/define`)
- `age-sup-strategic-challenger` — Sparring estratégico (Trigger: `/challenge`)
- `age-sup-auditor` — Verifica compliance, read-only (Trigger: `/review`)
- `age-sup-evaluator` — Puntúa fases en 4D, read-only (Trigger: `/review`)
- `age-sup-optimizer` — Detecta patrones, propone mejoras, read-only (Trigger: `/review`)

## Los 19 comandos

| Comando | Para qué |
|---|---|
| `/auto` | **(NUEVO)** Orquestador gobernado: recorre research/def → plan → build → review solo, parando en 3 gates (scope, arquitectura, done). Push manual |
| `/design-discovery` | **(NUEVO V2.3)** Entrevista funcional al PM sobre diseño, una pregunta por turno → genera `docs/producto/functional-brief.md` |
| `/analyze` | Evaluar problema/PRD con Quality Guard |
| `/define` | JTBDs → stories → quality coach |
| `/story` | Story autónomo desde idea, 7 fases internas |
| `/plan` | Arquitectura + sprint plan |
| `/build` | Implementar stories con sub-agentes |
| `/review` | QA pipeline (test + code-review + audit + evaluate + optimize) |
| `/hotfix` | Bug fix ligero con learning |
| `/code-review` | Code review standalone |
| `/design-to-prd` | Analizar diseños Pencil → stories verticales (lee functional-brief si existe) |
| `/save` | Commit + push a GitHub |
| `/docs` | Generar/actualizar documentación |
| `/learned` | Loguear lección aprendida |
| `/challenge` | Sparring estratégico |
| `/unknown-unknowns` | Detector de riesgos en 8 dimensiones |
| `/new-project` | Inicializar proyecto cliente |
| `/pm` | PM de Producto (índice + buzón + dossiers) |
| `/wiki` | Wiki de empresa (artículos, reuniones, notas) |

## Cómo se usa

PM x10 se instala globalmente en `~/.claude/` vía el `install.sh` del paquete. Después, los comandos `/pm`, `/define`, etc. están disponibles en cualquier proyecto que abras con Claude Code.

```bash
cd "<este-paquete>"
./install.sh
```

Para desplegar PM x10 como pestaña en un proyecto cliente (modelo multi-paquete del arquitecto):

```bash
bash deploy.sh /ruta/al/proyecto-cliente
```

Para el flow original de PM x10 (crear estructura completa en un proyecto cliente, con dashboard propio):

```bash
# Desde Claude Code en el proyecto cliente:
/new-project
```

## Estructura

```
pmx-product/
├── CLAUDE.md                  ← este archivo (quick reference)
├── SOUL.md                    ← identidad y filosofía
├── DUTIES.md                  ← segregación de roles
├── RULES.md                   ← reglas operativas
├── agent.yaml                 ← manifest principal
├── README.md                  ← README del paquete
├── system-overview.md         ← índice ligero (rul-lazy-loading)
├── install.sh                 ← compila a ~/.claude/
├── deploy.sh                  ← despliega como pestaña en proyecto cliente
├── dashboard-section.yaml     ← pestaña 'Producto' del dashboard multi-paquete
├── guia-de-uso.html           ← symlink → pm-agent-system-guia-de-uso.html
├── pm-agent-system-guia-de-uso.html  ← guía visual completa
├── .gitignore
│
├── agents/                    ← 19 agentes
├── commands/                  ← 18 comandos
├── skills/, rules/, knowledge/  ← skills/rules/knowledge propios de PM x10
├── templates/                 ← templates de producto (PRD, story, dossier, etc.)
├── docs/                      ← documentación
├── memory/                    ← memoria persistente
├── compliance/                ← reglas de compliance específicas
├── config/                    ← configuración
├── examples/                  ← ejemplos
├── hooks/                     ← hooks event-driven
├── qa/                        ← QA reports
├── workflows/                 ← workflows DAG
├── scripts/                   ← scripts de mantenimiento + pmx10.template
├── dashboard-template/        ← dashboard ORIGINAL de PM x10 (sigue funcionando)
└── context-ledger/            ← log append-only por sesión
```

## Relación con el arquitecto

Este paquete vive en `AgentArchitect/exports/pmx-product/` desde 2026-05-18. Antes vivía en `Proyectos/Agente IA/`.

**Lo que conserva del estado anterior**:
- Repo Git propio con todo el historial (`pagra93/AgentIA_Pablo` en GitHub)
- Los 18 agentes intactos
- Los 17 comandos intactos
- Su `dashboard-template/` original (que se copia a proyectos clientes vía `/new-project`)
- Todas las carpetas extra (compliance, qa, workflows, examples, hooks, config, scripts, templates)
- Funcionalidad idéntica desde Claude Code

**Lo que añade por ser first-class del arquitecto**:
- Está registrado en `~/.claude/packages-registry.txt`
- Aparece en el catálogo `exports/README.md` del arquitecto
- Puede aportar pestaña al dashboard multi-paquete del arquitecto (vía `dashboard-section.yaml` + `deploy.sh`)
- Puede recibir propagaciones de cambios genéricos desde el arquitecto vía `/arc-propagate`
- Es auditable con `/arc-audit`

## Documentación detallada

- **`pm-agent-system-guia-de-uso.html`** (también accesible como `guia-de-uso.html`): guía visual completa del sistema. Abre con doble-click en el navegador.
- **`SOUL.md`**: identidad, valores y principios del sistema
- **`DUTIES.md`**: segregación de roles entre agentes
- **`RULES.md`**: reglas operativas globales

## CLI wrappers

```bash
bash ~/.claude/pmx10 help    # wrapper de operaciones PM x10
bash ~/.claude/arc help      # wrapper del arquitecto
```
