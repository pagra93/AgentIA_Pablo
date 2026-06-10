# newsletter-system — System Overview

> Índice ligero del paquete. Leído por el orchestrator al inicio (per `rul-lazy-loading`). Lista cada entidad con UNA LÍNEA de descripción. Los archivos concretos solo se cargan cuando se necesitan.

**Dominio**: `editorial-content`
**Prefix**: `news`
**Flujo**: research → outline → draft → edit → publish

## Cómo arrancar

- Claude Code: `/news-<comando>` (los comandos del paquete tienen este prefix)
- Comandos transversales (sin prefix): `/save`, `/docs`, `/learned`, `/challenge`, `/unknown-unknowns`, `/hotfix`, `/code-review`, `/adversarial`
- Help contextual: `/help`

## Agentes especialistas (del paquete)

| Agent | Path | Role |
|-------|------|------|
| `age-spe-news-topic-researcher` | `agents/age-spe-news-topic-researcher/` | TODO (stub): Investiga tema del próximo número (tendencias, fuentes, ángulo editorial) |
| `age-spe-news-content-curator` | `agents/age-spe-news-content-curator/` | TODO (stub): Selecciona y valida fuentes (artículos, estudios, citas) |
| `age-spe-news-outline-architect` | `agents/age-spe-news-outline-architect/` | TODO (stub): Estructura el esqueleto del número (secciones, orden, longitudes objetivo) |
| `age-spe-news-editorial-writer` | `agents/age-spe-news-editorial-writer/` | TODO (stub): Redacta el primer draft completo basándose en el outline + fuentes |
| `age-spe-news-headline-architect` | `agents/age-spe-news-headline-architect/` | TODO (stub): Genera titulares y subtítulos optimizados (apertura + cada sección) |
| `age-spe-news-editor-in-chief` | `agents/age-spe-news-editor-in-chief/` | TODO (stub): Revisa, corrige, valida tono y coherencia, da OK final pre-publicación |

## Agentes supervisores (heredados, READ-ONLY)

| Agent | Path | Role |
|-------|------|------|
| `age-sup-auditor` | `agents/age-sup-auditor/` | Verifica compliance con rules |
| `age-sup-evaluator` | `agents/age-sup-evaluator/` | Puntúa fases en 4D |
| `age-sup-optimizer` | `agents/age-sup-optimizer/` | Detecta patrones, propone mejoras |
| `age-sup-cynic` | `agents/age-sup-cynic/` | Adversarial: desafía premisas |
| `age-sup-boundary-walker` | `agents/age-sup-boundary-walker/` | Adversarial: explora bordes |

## Skills (heredadas del arquitecto)

| Skill | Path | Use |
|-------|------|-----|
| `ski-plan-mode` | `skills/ski-plan-mode/` | Planning estructurado para tareas no triviales |
| `ski-doc-updater` | `skills/ski-doc-updater/` | Mantenimiento de docs |
| `ski-project-docs` | `skills/ski-project-docs/` | Generación de docs exportables |
| `ski-unknown-unknowns` | `skills/ski-unknown-unknowns/` | Detector de riesgos en 8 dimensiones |
| `ski-context-ledger` | `skills/ski-context-ledger/` | Escribir entradas en context-ledger/ |
| `ski-compression` | `skills/ski-compression/` | Comprimir docs largos en distillates |

## Rules (heredadas del arquitecto)

- `rul-naming-conventions` — convenciones de nomenclatura
- `rul-git-branch-management` — flujo Git/GitHub
- `rul-spanish-orthography` — ortografía española obligatoria
- `rul-llm-coding-discipline` — 4 principios anti-antipatterns LLM
- `rul-prompt-override` — respeto de prompt_override en HU/Epic
- `rul-scope-boundaries` — aislamiento entre paquetes
- `rul-lazy-loading` — cargar solo lo necesario

## Knowledge (heredada del arquitecto)

- `kno-mom-test` — metodología Mom Test
- `kno-strategic-thinking` — frameworks de pensamiento estratégico
- `kno-elicitation-methods` — técnicas de cuestionamiento (Socratic, Pre-Mortem, Red-Team, etc.)
- `kno-mcp-integration` — cómo añadir servidores MCP

## Outputs principales

Número de newsletter (.md y .html), métricas de envío

## Cross-session persistence

- `memory/MEMORY.md` — memoria persistente (preferencias, decisiones, referencias)
- `context-ledger/` — log append-only de pasos significativos (un archivo por sesión-agente)

## Reading strategy

Cuando trabajes en newsletter-system:

1. Lee este `system-overview.md` primero (índice).
2. Lee archivos individuales SOLO cuando el workflow lo indique.
3. Per `rul-scope-boundaries`: nunca leas dentro de otros paquetes desde este.
4. Per `rul-lazy-loading`: no cargues "todo por si acaso".

## Estado

- **Versión**: 0.1.0 (generado por arquitecto el 2026-05-15)
- **Agentes especialistas implementados**: 0 (todos en stub TODO inicial)
- **Maduro / Beta / Stub**: stub (esperando implementación)
