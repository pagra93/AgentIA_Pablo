---
name: ski-doc-updater
description: "Updates project documentation after feature completion. Maintains PROJECT_KNOWLEDGE.md. Trigger: /review, 'update docs'."
license: MIT
allowed-tools: Read Write Edit Glob Grep
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: documentation
---

# Documentation Updater

## What Gets Updated

### 1. docs/PROJECT_KNOWLEDGE.md (Priority)

The KEY file. When someone returns to the project, this tells them everything.

```markdown
# Project Knowledge — [Project Name]
Last updated: [date]

## What This Project Does
## Architecture Overview
## Features Implemented
| Feature | Date | Status | Notes |
## Key Decisions
| Decision | Date | Why | Alternative |
## How Things Work
### [Feature/Area]
[How it works, where the code is, gotchas]
## Known Issues & Tech Debt
| Issue | Priority | Notes |
```

### 2. Changelog
```markdown
## [Date] — [Feature Name]
- What changed
- Why
- Impact
```

### 3. ADRs (if significant decisions made)

### 4. API Documentation (if APIs changed)

### 5. docs/project-registry.md (if stories have "Dependencias del Proyecto > Crea")
Promote verified assets from `planned` to `active`. Add Path column with real codebase paths.
Update Quick Reference summary block and total asset count.

## When to Run

- After EVERY feature completion (part of /review)
- After architectural decisions
- After bug fixes that change behavior

## Rules

1. PROJECT_KNOWLEDGE.md is PRIORITY — always update first
2. Keep CONCISE — link to details, don't duplicate
3. Document the WHY, not just the WHAT
4. If feature changed since last documented, UPDATE the entry
5. Never leave docs contradicting the code
