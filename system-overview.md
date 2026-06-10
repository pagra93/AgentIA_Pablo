# PM x10 — System Overview

> Índice ligero del paquete. Per `rul-lazy-loading`: el orquestador lee este archivo primero al inicio de sesión y luego carga archivos individuales solo cuando los necesita.

**Paquete**: `pmx-product`
**Dominio**: `product-management`
**Versión**: 2.3.0

## Cómo arrancar

```
/pm                          ← PM de Producto (índice + buzón + dossiers)
/story                       ← Story builder autónomo (idea → story)
/analyze                     ← Quality Guard sobre problema/PRD
/define                      ← JTBDs → stories
/plan                        ← Arquitectura + sprint plan
/build                       ← Implementar stories
/review                      ← QA pipeline completo
```

## Agentes (19 total)

### Especialistas (14)

| Agent | Path | Role |
|---|---|---|
| `age-spe-design-discoverer` | `agents/age-spe-design-discoverer/` | Discovery funcional sobre diseños: entrevista al PM antes de `/design-to-prd` y genera Functional Brief |
| `age-spe-quality-guard` | `agents/age-spe-quality-guard/` | Evalúa calidad de PRDs y definiciones de problema |
| `age-spe-researcher` | `agents/age-spe-researcher/` | Investiga gaps de conocimiento con Mom Test |
| `age-spe-design-analyst` | `agents/age-spe-design-analyst/` | Analiza diseños y genera stories verticales completas |
| `age-spe-jtbd-architect` | `agents/age-spe-jtbd-architect/` | Transforma research en JTBDs |
| `age-spe-story-writer` | `agents/age-spe-story-writer/` | Convierte JTBDs en user stories deployables |
| `age-spe-story-builder` | `agents/age-spe-story-builder/` | Story Builder autónomo (7 fases internas) |
| `age-spe-story-splitter` | `agents/age-spe-story-splitter/` | Descompone stories >3 días |
| `age-spe-tech-architect` | `agents/age-spe-tech-architect/` | Diseña arquitectura desde stories |
| `age-spe-sprint-planner` | `agents/age-spe-sprint-planner/` | Prioriza stories y crea sprint plan |
| `age-spe-test-engineer` | `agents/age-spe-test-engineer/` | Validation loop: tests, coverage, iteración |
| `age-spe-code-reviewer` | `agents/age-spe-code-reviewer/` | Code review con memoria persistente |
| `age-spe-pm-producto` | `agents/age-spe-pm-producto/` | PM de Producto: índice + buzón + dossiers |
| `age-spe-wiki-curator` | `agents/age-spe-wiki-curator/` | Wiki transversal de empresa |

### Supervisores (5) — READ-ONLY

| Agent | Path | Role |
|---|---|---|
| `age-sup-quality-coach` | `agents/age-sup-quality-coach/` | Evalúa calidad de stories sin modificar |
| `age-sup-strategic-challenger` | `agents/age-sup-strategic-challenger/` | Sparring partner estratégico |
| `age-sup-auditor` | `agents/age-sup-auditor/` | Verifica compliance con rules |
| `age-sup-evaluator` | `agents/age-sup-evaluator/` | Puntúa fases en 4 dimensiones |
| `age-sup-optimizer` | `agents/age-sup-optimizer/` | Detecta patrones recurrentes, propone mejoras |

## Comandos (18)

| Comando | Path | Workflow |
|---|---|---|
| `/design-discovery` | `commands/design-discovery.md` | design-discoverer: entrevista funcional al PM sobre diseño, una pregunta por turno |
| `/analyze` | `commands/analyze.md` | Quality Guard → researcher |
| `/define` | `commands/define.md` | jtbd-architect → story-writer → quality-coach → story-splitter |
| `/story` | `commands/story.md` | story-builder autónomo |
| `/plan` | `commands/plan.md` | tech-architect → sprint-planner |
| `/build` | `commands/build.md` | Implementación con sub-agentes |
| `/review` | `commands/review.md` | test-engineer → code-reviewer → auditor → evaluator → optimizer |
| `/hotfix` | `commands/hotfix.md` | Bug fix ligero con learning |
| `/code-review` | `commands/code-review.md` | Code review standalone |
| `/design-to-prd` | `commands/design-to-prd.md` | design-analyst sobre diseños Pencil (lee functional-brief.md si existe) |
| `/save` | `commands/save.md` | Commit + push seguro |
| `/docs` | `commands/docs.md` | doc-updater |
| `/learned` | `commands/learned.md` | Log de lección aprendida |
| `/challenge` | `commands/challenge.md` | strategic-challenger |
| `/unknown-unknowns` | `commands/unknown-unknowns.md` | Detector de riesgos 8D |
| `/new-project` | `commands/new-project.md` | Inicializa estructura completa en proyecto cliente |
| `/pm` | `commands/pm.md` | pm-producto |
| `/wiki` | `commands/wiki.md` | wiki-curator |

## Skills (propias de PM x10)

| Skill | Path | Uso |
|---|---|---|
| `ski-prd-builder` | `skills/ski-prd-builder/` | Genera PRDs con Quality Guard score ≥7 |
| `ski-competitive-analysis` | `skills/ski-competitive-analysis/` | Análisis competitivo estructurado |
| `ski-plan-mode` | `skills/ski-plan-mode/` | Planning estructurado |
| `ski-doc-updater` | `skills/ski-doc-updater/` | Mantenimiento docs/PROJECT_KNOWLEDGE.md |
| `ski-unknown-unknowns` | `skills/ski-unknown-unknowns/` | Detector de riesgos en 8 dimensiones |
| `ski-project-docs` | `skills/ski-project-docs/` | Generación docs/project-docs/ |
| `ski-impeccable-guide` | `skills/ski-impeccable-guide/` | Frontend design quality (Impeccable) |

## Rules

| Rule | Path |
|---|---|
| `rul-definition-of-done` | `rules/rul-definition-of-done.md` |
| `rul-definition-of-ready` | `rules/rul-definition-of-ready.md` |
| `rul-antipatterns` | `rules/rul-antipatterns.md` |
| `rul-scoring-dimensional` | `rules/rul-scoring-dimensional.md` |
| `rul-naming-conventions` | `rules/rul-naming-conventions.md` |
| `rul-git-branch-management` | `rules/rul-git-branch-management.md` |
| `rul-spanish-orthography` | `rules/rul-spanish-orthography.md` |
| `rul-llm-coding-discipline` | `rules/rul-llm-coding-discipline.md` |
| `rul-prompt-override` | `rules/rul-prompt-override.md` |

## Knowledge base

| Knowledge | Path |
|---|---|
| `kno-jtbd-framework` | `knowledge/kno-jtbd-framework.md` |
| `kno-mom-test` | `knowledge/kno-mom-test.md` |
| `kno-story-splitting` | `knowledge/kno-story-splitting.md` |
| `kno-testing-strategy` | `knowledge/kno-testing-strategy.md` |
| `kno-story-ticket-template` | `knowledge/kno-story-ticket-template.md` |
| `kno-strategic-thinking` | `knowledge/kno-strategic-thinking.md` |
| `kno-elicitation-methods` | `knowledge/kno-elicitation-methods.md` |

## Carpetas especiales

| Carpeta | Para qué |
|---|---|
| `templates/` | Templates de producto (PRD skeleton, story ticket, dossier, raw sources, wiki templates, etc.) |
| `dashboard-template/` | Dashboard original de PM x10 (se copia a cada proyecto cliente vía `/new-project`) |
| `scripts/` | Scripts de mantenimiento (upgrade-project.sh, migrate-states-v2.sh, regenerate-dossiers.sh, etc.) + `pmx10.template` |
| `compliance/`, `qa/`, `workflows/`, `examples/`, `hooks/`, `config/`, `docs/`, `memory/` | Estructura interna del sistema |
| `context-ledger/` | Log append-only por sesión (heredado de la convención del arquitecto) |

## Cross-session persistence

- `memory/MEMORY.md` — memoria persistente (preferencias, decisiones, referencias)
- `context-ledger/` — log append-only de pasos significativos

## Reading strategy

Cuando trabajes en PM x10:

1. Lee este `system-overview.md` primero (índice).
2. Lee `CLAUDE.md` para quick reference.
3. Lee archivos individuales SOLO cuando el workflow lo indique.
4. Para entender filosofía completa: `SOUL.md`, `DUTIES.md`, `RULES.md`.
5. Para una visión visual completa: abre `guia-de-uso.html` en navegador.

## Estado

- **Versión**: 2.3.0 (estable, producción)
- **Localización**: `AgentArchitect/exports/pmx-product/` desde 2026-05-18
- **Git remote**: `pagra93/AgentIA_Pablo` (historial completo preservado)
- **Maduro / Beta / Stub**: maduro
- **V2.3 (2026-05-28)**: añadido `age-spe-design-discoverer` + `/design-discovery` para discovery funcional sobre diseños antes de `/design-to-prd`. Genera `docs/producto/functional-brief.md` que el design-analyst usa para marcar secciones como `[VALIDADO via functional-brief]` en vez de `[DERIVADO]`.
