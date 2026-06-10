# Segregation of Duties

## Roles

| Role ID | Description | Permissions |
|---------|-------------|-------------|
| `analyst` | Evaluates problems, researches gaps, produces findings | read, analyze, research, score, report |
| `definer` | Transforms research into JTBDs and stories | read, create-jtbd, create-story, score |
| `architect` | Designs technical architecture and sprint plans | read, create-architecture, create-plan |
| `engineer` | Implements code following stories and architecture | read, write-code, run-tests, commit |
| `reviewer` | Reviews code quality, security, performance | read, review, approve, request-changes |
| `supervisor` | Observes, scores, proposes improvements (READ-ONLY) | read, score, propose |

## Agent-Role Assignments

| Agent | Role(s) | Phase |
|-------|---------|-------|
| `age-spe-quality-guard` | analyst | Analysis |
| `age-spe-researcher` | analyst | Analysis |
| `age-sup-strategic-challenger` | supervisor | Analysis |
| `age-spe-jtbd-architect` | definer | Definition |
| `age-spe-story-writer` | definer | Definition |
| `age-spe-story-builder` | definer | Definition |
| `age-sup-quality-coach` | supervisor | Definition |
| `age-spe-story-splitter` | definer | Definition |
| `age-spe-tech-architect` | architect | Planning |
| `age-spe-sprint-planner` | architect | Planning |
| (Claude Code directly) | engineer | Engineering |
| `age-spe-test-engineer` | reviewer | Testing |
| `age-spe-code-reviewer` | reviewer | Testing |
| `age-sup-auditor` | supervisor | QA |
| `age-sup-evaluator` | supervisor | QA |
| `age-sup-optimizer` | supervisor | QA |

## Conflict Matrix

These role pairs CANNOT coexist in the same agent:

| Role A | Role B | Reason |
|--------|--------|--------|
| `engineer` | `reviewer` | Who writes the code cannot review it |
| `engineer` | `supervisor` | Who writes the code cannot audit it |
| `definer` | `supervisor` | Who defines stories cannot evaluate their quality |

## Handoff Workflows

### Challenge -> Any Phase (via /challenge)
```
age-sup-strategic-challenger (supervisor, interactive debate)
  -> PM receives challenge brief
  -> PM decides next step: /analyze, /define, /plan, or /build
```

### Analysis -> Definition
```
age-spe-quality-guard (analyst)
  -> PM approves findings
  -> age-spe-researcher (analyst)
  -> PM approves brief
  -> age-spe-jtbd-architect (definer)
```

### Definition -> Planning (via /define)
```
age-spe-story-writer (definer)
  -> age-sup-quality-coach (supervisor, READ-ONLY review)
  -> PM approves stories
  -> age-spe-story-splitter (definer, if stories >3 days)
  -> age-spe-tech-architect (architect)
```

### Story Builder -> Design -> Planning (via /story, iterative flow)
```
PM (idea/problem, no PRD required)
  -> age-spe-story-builder (definer, autonomous — 7 internal phases, includes 6-layer design analysis [DERIVADO])
  -> PM confirms story draft
  -> PM creates design in Pencil (optional but recommended, based on story draft)
  -> /design-to-prd (enriches story with real 6-layer analysis from design)
  -> PM reviews: update story if design revealed new requirements
  -> age-spe-story-splitter (definer, if story >3 days)
  -> age-spe-tech-architect (architect)
```

### Planning -> Engineering
```
age-spe-sprint-planner (architect)
  -> PM approves sprint plan
  -> age-spe-frontend-dev / age-spe-backend-arch / age-spe-mobile-builder (engineer)
```

### Engineering -> QA
```
age-spe-test-engineer (reviewer)
  -> age-spe-code-reviewer (reviewer)
  -> age-sup-auditor (supervisor, READ-ONLY)
  -> age-sup-evaluator (supervisor, READ-ONLY)
  -> age-sup-optimizer (supervisor, READ-ONLY, proposes improvements)
```

## Isolation Policy

- **State**: Agents within the same phase share context. Agents across phases receive only the output artifacts from the previous phase (docs, stories, plans), not raw conversation.
- **Memory**: Only `age-spe-code-reviewer` has persistent memory (`memory: project`). All other agents are stateless between sessions.
- **Credentials**: All agents operate under the same user permissions. No separate credential isolation required (non-regulated environment).

## Enforcement

**Mode: advisory**

The system logs violations but does not prevent execution. If an engineer agent is asked to review its own code, the system warns the PM but proceeds if the PM explicitly confirms. This aligns with the core principle: "Analysis Informs, Never Blocks."
