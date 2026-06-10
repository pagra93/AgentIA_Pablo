---
name: rul-naming-conventions
description: "Convenciones de nomenclatura para todas las entidades del sistema. Usado por todos los agentes al crear o referenciar archivos."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: standards
  loaded-by: all_agents
---

# Naming Conventions

## Entity Prefixes

| Entity Type | Prefix | Directory | Format |
|-------------|--------|-----------|--------|
| Agent Specialist | `age-spe-` | `agents/` | Directory (agent.yaml + SOUL.md) |
| Agent Supervisor | `age-sup-` | `agents/` | Single .md file (lightweight) |
| Skill | `ski-` | `skills/` | Directory (SKILL.md + references/) |
| Rule | `rul-` | `rules/` | Single .md file |
| Knowledge Base | `kno-` | `knowledge/` | Single .md file |
| Workflow | `wor-` | `workflows/` | .yaml file (DAG format) |
| Command | (no prefix) | `commands/` | Single .md file |

## Naming Rules

1. **All names use kebab-case**: `age-spe-story-writer`, not `age_spe_story_writer` or `ageSpeStoryWriter`
2. **Max 64 characters** for the name (excluding prefix)
3. **Descriptions follow "what + when" pattern**: "Evalua calidad de stories. Trigger: /define" — what it does + when it activates
4. **Max 250 characters** for descriptions

## Agent Naming

### Specialists (`age-spe-*`)
Deep execution expertise in one domain. They generate output.

Pattern: `age-spe-{domain}-{specialty}`
- `age-spe-quality-guard` — quality evaluation
- `age-spe-story-writer` — story creation
- `age-spe-frontend-dev` — frontend development
- `age-spe-code-reviewer` — code review

### Supervisors (`age-sup-*`)
Read-only observers. They score, detect patterns, and propose. They NEVER modify.

Pattern: `age-sup-{function}`
- `age-sup-quality-coach` — story quality evaluation
- `age-sup-auditor` — compliance verification
- `age-sup-evaluator` — phase scoring
- `age-sup-optimizer` — improvement proposals

## Skill Naming (`ski-*`)

Reusable capabilities that agents can load.

Pattern: `ski-{capability}`
- `ski-prd-builder` — PRD generation
- `ski-competitive-analysis` — competitive landscape
- `ski-plan-mode` — structured planning
- `ski-doc-updater` — documentation maintenance

## Rule Naming (`rul-*`)

Constraints and checklists that agents reference.

Pattern: `rul-{topic}`
- `rul-definition-of-done` — completion checklist
- `rul-definition-of-ready` — readiness checklist
- `rul-antipatterns` — pattern catalog to avoid
- `rul-scoring-dimensional` — scoring rubric

## Knowledge Naming (`kno-*`)

Reference frameworks and methodologies.

Pattern: `kno-{framework}`
- `kno-jtbd-framework` — Jobs-to-be-Done methodology
- `kno-mom-test` — Mom Test interview technique
- `kno-story-splitting` — Story splitting heuristics

## Workflow Naming (`wor-*`)

Multi-agent orchestration workflows.

Pattern: `wor-{action}`
- `wor-analyze` — problem analysis pipeline
- `wor-define` — definition pipeline
- `wor-build` — development pipeline
- `wor-review` — QA pipeline

## File Extension Rules

| Content Type | Extension |
|-------------|-----------|
| Agent/Skill/Rule/Knowledge/Command content | `.md` |
| Workflow definitions (DAG) | `.yaml` |
| Configuration | `.yaml` |
| Memory index | `.yaml` |
| Knowledge index | `.yaml` |
| Scripts | `.sh` |
