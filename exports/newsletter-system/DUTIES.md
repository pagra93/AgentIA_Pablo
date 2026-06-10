# Segregation of Duties — newsletter-system

## Roles del paquete

| Role ID | Description | Permissions |
|---------|-------------|-------------|
| `<role-1>` | (TODO: definir cuando se implementen los agentes específicos) | read, ... |
| `<role-2>` | (TODO) | read, ... |
| `supervisor` | Observa, scoring, propone. Read-only. | read, score, propose |

## Agent-Role Assignments

| Agent | Role | Phase |
|-------|------|-------|
| `age-spe-news-topic-researcher` | TODO: definir | research |
| `age-spe-news-content-curator` | TODO: definir | research |
| `age-spe-news-outline-architect` | TODO: definir | outline |
| `age-spe-news-editorial-writer` | TODO: definir | draft |
| `age-spe-news-headline-architect` | TODO: definir | draft |
| `age-spe-news-editor-in-chief` | TODO: definir | edit |

## Supervisores QA (heredados, READ-ONLY)

| Agent | Role | Trigger |
|-------|------|---------|
| `age-sup-auditor` | supervisor | `/review` |
| `age-sup-evaluator` | supervisor | `/review` |
| `age-sup-optimizer` | supervisor | `/review` |
| `age-sup-cynic` | supervisor | `/adversarial` |
| `age-sup-boundary-walker` | supervisor | `/adversarial` |

## Conflict Matrix

| Role A | Role B | Reason |
|--------|--------|--------|
| `engineer` | `supervisor` | Quien escribe el código no debe auditarlo |
| `definer` | `supervisor` | Quien define no debe evaluar la calidad de la definición |

## Handoff Workflows

(Cuando se implementen los agentes específicos, definir aquí el flujo:
ejemplo: `Stage 1 -> Stage 2 -> ... -> Output`)

### Flujo principal: research → outline → draft → edit → publish

```
(TODO: dibujar handoffs entre agentes según los stages)
```

## Isolation Policy

- **State**: agentes dentro del paquete comparten contexto del paquete. Agentes de otros paquetes NO ven nada de este paquete (`rul-scope-boundaries`).
- **Memory**: cada agente puede tener `memory: project` si lo declara en `agent.yaml`. Por defecto stateless.
- **Cross-package**: este paquete NO referencia agentes/skills de otros paquetes. Si necesita capacidad común, se hereda del arquitecto (skills/rules/knowledge propagados).

## Enforcement

**Mode: advisory** (igual que PM x10 y el arquitecto). El sistema avisa de violaciones, pero el PM decide.
