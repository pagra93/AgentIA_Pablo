---
description: "Initialize a new project (or add PM x10 to existing one) with CLAUDE.md, docs, tasks, memory, QA, and working-docs structure."
---

# /new-project — Project Initializer

Works for NEW projects and EXISTING ones. Only adds management files — never touches your code.

## Step 1: Interview

Ask the user:
1. **Project name**: "What's the project called?"
2. **Description**: "Describe it in 1-2 sentences"
3. **Tech stack**: "What technologies? (e.g., Next.js + PostgreSQL + Supabase)"
4. **Platform**: "Web, mobile, API, or combination?"
5. **Team context**: "Solo with AI, or is there a team?"
6. **Test setup**: "Do you have a test framework already? (e.g., Jest, Vitest, Pytest, none yet)"

## Step 2: Create Structure

Create ALL of the following. If a file/folder already exists, SKIP it (don't overwrite).

### .claude/CLAUDE.md (or update existing)

If CLAUDE.md already exists, ADD the PM x10 sections to it (don't replace existing content).
If it doesn't exist, generate from scratch:

```markdown
# [Project Name]

## What This Project Does
[User's description]

## Tech Stack (non-negotiable)
[User's stack — agents MUST respect this]

## Navigation
### Global (installed in ~/.claude/)
- Agents: 14 specialized agents (10 specialists + 4 supervisors)
- Skills: 7 (PRD builder, competitive analysis, plan mode, doc updater, unknown unknowns, project docs, impeccable guide)
- Rules: 6 (definition of done/ready, antipatterns, scoring, naming, git branching)
- Knowledge: 5 (JTBD framework, Mom Test, story splitting, testing strategy, story ticket template)
- Commands: 14 slash commands

### Project (this project)
- Project docs: docs/PROJECT_KNOWLEDGE.md — READ THIS FIRST when returning
- Working docs: docs/working-docs/[feature]/ — artifacts per feature
- Current tasks: tasks/todo.md — sprint plan and progress
- Lessons learned: tasks/lessons.md — patterns and mistakes
- Working memory: memory/MEMORY.md — agent observations across sessions
- QA reports: qa-reports/ — audit trail

## Orchestration Rules
1. Start every non-trivial task in plan mode (>3 steps)
2. Write plans to tasks/todo.md before executing
3. Commit after each completed story (/save)
4. /review after completing features (tests + QA + asks about docs)
5. Consult tasks/lessons.md at start of each session
6. Read memory/MEMORY.md for patterns from previous sessions
7. Save artifacts to docs/working-docs/[feature]/ organized by feature

## Available Commands
/analyze            Evaluate problem/PRD (Quality Guard + Research)
/define             Create JTBDs + stories (with quality review)
/plan               Architecture + sprint plan
/story              Build story from idea (no PRD, autonomous agent)
/build              Implement stories (Claude Code directly)
/save               Commit + push to GitHub (validates branch, detects secrets)
/review             QA pipeline + feature docs (ALWAYS asks about documentation)
/hotfix             Bug fix with learning (only saves when PM confirms resolved)
/code-review        Just code review
/design-to-prd      Pencil designs → PRDs per feature (6-layer analysis)
/unknown-unknowns   Detect hidden risks (8 dimensions)
/docs               Generate/update project documentation
/learned            Save a learning anytime (bug resolved, discovery, mistake)

## Testing
### Framework
[Based on stack — e.g., Vitest for Vite projects, Jest for React/Node, Pytest for Python]

### Test File Location
[Based on stack — e.g., co-located __tests__/ for React, tests/ for Python]

### Test Commands
- Unit/Integration: [e.g., npm test, pytest]
- E2E: [e.g., npx playwright test]
- Coverage: [e.g., npm test -- --coverage]

### Test Data
[Based on stack — e.g., factories with faker.js, MSW for API mocking]

## Coding Standards
[Based on stack — generate appropriate for the tech]

## Core Principle
Analysis Informs, Never Blocks. Agents identify risks. PM always decides.
```

### docs/PROJECT_KNOWLEDGE.md
```markdown
# Project Knowledge — [Name]
Last updated: [today]

## What This Project Does
[Description]

## Architecture Overview
[To be filled after /plan]

## Features Implemented
| Feature | Date | Status | Notes |
|---------|------|--------|-------|

## Key Decisions
| Decision | Date | Why |
|----------|------|-----|

## How Things Work
[To be filled as features are built]

## Known Issues & Tech Debt
| Issue | Priority | Notes |
|-------|----------|-------|
```

### docs/working-docs/ (empty directory)
This is where feature artifacts will be organized:
```
docs/working-docs/
└── [feature-name]/          ← created by /design-to-prd, /analyze, /define
    ├── design-analysis.md   ← from /design-to-prd
    ├── prd.md               ← from /design-to-prd or /analyze
    ├── research.md          ← from /analyze
    ├── jtbds.md             ← from /define
    ├── stories.md           ← from /define
    └── architecture.md      ← from /plan
```

### tasks/todo.md
```markdown
# Tasks — [Name]
Status: INITIALIZED

## Current Sprint
[No sprint yet. Use /analyze → /define → /plan to create one.]
```

### tasks/lessons.md
```markdown
# Lessons Learned — [Name]

## Patterns to Follow
[Populated by QA Optimizer and /learned]

## Mistakes to Avoid
[Populated by /hotfix and /learned after resolving issues]
```

### memory/MEMORY.md
```markdown
# Working Memory — [Name]
Last updated: [today]

## Project Patterns
(Populated by Code Reviewer after /review cycles)

## Recurring Issues
(Populated by Optimizer after detecting patterns in QA reports)

## Recent Decisions
- [today]: Project initialized with PM x10 Agent System

## Open Questions
(None yet)
```

### qa-reports/ (empty directory)

## Step 3: Confirm

Tell the user:

"Project initialized with PM x10 Agent System.

Created:
- .claude/CLAUDE.md — Project config with all commands listed
- docs/PROJECT_KNOWLEDGE.md — Living knowledge (read this when returning)
- docs/working-docs/ — Feature artifacts (filled by /design-to-prd, /analyze, /define)
- tasks/todo.md — Sprint plan and progress
- tasks/lessons.md — Patterns and mistakes
- memory/MEMORY.md — Agent observations across sessions
- qa-reports/ — QA audit trail

Available commands:
- /design-to-prd    Pencil designs → PRDs per feature
- /analyze          Evaluate a problem or PRD
- /define           Create JTBDs and user stories
- /plan             Architecture and sprint plan
- /build            Implement stories
- /save             Commit and push to GitHub
- /review           QA pipeline + feature docs
- /hotfix           Bug fix with learning
- /unknown-unknowns Detect hidden risks
- /docs             Generate project documentation
- /learned          Save a learning anytime

Tip: For small tasks (<30 sec), just ask directly — no commands needed.
For features: /analyze → /define → /plan → /build → /save → /review
If you have designs: start with /design-to-prd"
