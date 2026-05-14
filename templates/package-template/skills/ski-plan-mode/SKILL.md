---
name: ski-plan-mode
description: "Structured planning for non-trivial tasks (>3 steps or >3 files). Write plan before executing."
license: MIT
allowed-tools: Read Write
user-invocable: false
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: workflow
---

# Plan Mode

## When to Activate

- Task requires >3 steps
- Involves architectural decisions
- Modifies >3 files
- Something went wrong — STOP and re-plan

## Process

### 1. Write Plan to tasks/todo.md

```markdown
## Plan: [Task Name]
Date: [today]
Status: PLANNING

### Steps
- [ ] Step 1: [description] — [expected outcome]
- [ ] Step 2: [description] — [expected outcome]
- [ ] Step 3: [description] — [expected outcome]

### Verification
- [ ] How will we know each step worked?

### Risks
- [What could go wrong + fallback]
```

### 2. Confirm
Present plan, wait for PM confirmation.

### 3. Execute
Follow plan step by step. Mark completed items.

### 4. If Something Goes Wrong
**STOP immediately.** Return to step 1, re-plan.

## Rules

- NEVER skip planning for non-trivial tasks
- Plans must have VERIFIABLE outcomes per step
- If plan changes during execution, UPDATE tasks/todo.md
- Mark progress as you go
