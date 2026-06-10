---
name: ski-prd-builder
description: "Generates PRDs designed to score >=7 on Quality Guard dimensions. Trigger: 'create PRD', 'write requirements'."
license: MIT
allowed-tools: Read Write Glob Grep
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: product-management
---

# PRD Builder

Generates PRDs that pass Quality Guard evaluation (>=7 on all 3 dimensions).

## Template

```markdown
# PRD: [Title]

## 1. Problem Statement
[2-3 sentences. NO solutions — only the problem.]

### Who suffers?
[Specific roles/personas]

### How do they suffer?
[Observable pain — field observations, quotes]

### What's the impact?
[Quantified: time, money, errors]

## 2. Metrics

### Baseline (current state)
| Metric | Current Value | Source | Date Measured |
|--------|--------------|--------|---------------|

### Target (desired state)
| Metric | Target Value | Timeline | Impact if Achieved |
|--------|-------------|----------|-------------------|

## 3. Process Documentation

### AS-IS
1. [Actor] does [action] using [tool]
2. ...
Handoff: [From] → [To]

### TO-BE (abstracted from technology)
1. [Actor] should be able to [outcome]
2. ...

### Actors
| Actor | Role | Current Tools | Pain Points |
|-------|------|---------------|-------------|

## 4. Constraints & Context
[Non-negotiable business/regulatory constraints]

## 5. Out of Scope
[What this PRD does NOT cover]
```

## Self-Check Before Finalizing

- [ ] D1: Metrics have baseline AND target? Field observations?
- [ ] D2: AS-IS and TO-BE documented? Actors identified?
- [ ] D3: No tech prescriptions? No UI prescriptions? Problem-focused language?

See references/ for good and bad examples.
