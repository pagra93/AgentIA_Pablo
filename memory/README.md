# Memory System — How It Works in Claude Code

## Overview

The memory system gives agents **persistent knowledge across conversations**. Without it, each Claude Code session starts from zero. With it, agents remember patterns, decisions, and lessons from previous sessions.

## How It Works (Step by Step)

### 1. Agent Starts a Session
The agent reads these files before doing anything:
- `memory/MEMORY.md` — working memory (recent context, max 200 lines)
- `tasks/lessons.md` — lessons learned from QA Optimizer
- `docs/PROJECT_KNOWLEDGE.md` — project state and decisions

### 2. Agent Does Its Work
During the session, the agent accumulates observations:
- Code Reviewer notices a recurring pattern
- Optimizer detects a trend in audit scores
- Any agent finds something worth remembering

### 3. Agent Ends the Session
Before finishing, the agent writes back to memory:
- Updates `memory/MEMORY.md` with new findings
- Updates `tasks/lessons.md` with new lessons (via Optimizer)
- Updates `docs/PROJECT_KNOWLEDGE.md` with project changes (via Doc Updater)

## Who Reads and Writes What

| File | Who Reads | Who Writes | When |
|------|-----------|------------|------|
| `memory/MEMORY.md` | All agents at session start | Code Reviewer, Optimizer | After review cycles |
| `tasks/lessons.md` | All agents at session start | Optimizer only | After /review |
| `docs/PROJECT_KNOWLEDGE.md` | All agents at session start | Doc Updater skill | After feature completion |

## MEMORY.md Format

This is the **working memory** — a rolling summary (max 200 lines) of what matters NOW.

```markdown
# Working Memory
Last updated: [date]

## Project Patterns
- [Pattern discovered by Code Reviewer across sessions]
- [Convention established by the team]

## Recurring Issues
- [Issue that keeps appearing in audits]
- [Common mistake to watch for]

## Recent Decisions
- [Decision made in last session with context]

## Open Questions
- [Unresolved question that needs PM input]

## Agent Notes
### Code Reviewer
- [Patterns accumulated via memory: project]

### Optimizer
- [Trends detected across QA reports]
```

## Which Agents Have Persistent Memory

Only **age-spe-code-reviewer** has `memory: project` in its agent.yaml. This means Claude Code automatically loads and saves its memory across sessions.

All other agents get context through:
1. Reading `MEMORY.md` explicitly at session start
2. Reading `tasks/lessons.md` and `docs/PROJECT_KNOWLEDGE.md`
3. These files act as **shared memory** across all agents

## Archive System

When MEMORY.md grows too long (>200 lines):
1. Move older entries to `memory/archive/[YYYY-MM].yaml`
2. Keep only recent/active items in MEMORY.md
3. Archive files are retained for 1 year

Archive format:
```yaml
# memory/archive/2026-03.yaml
month: 2026-03
entries:
  - date: 2026-03-15
    source: age-spe-code-reviewer
    type: pattern
    content: "API endpoints consistently missing rate limiting"
  - date: 2026-03-20
    source: age-sup-optimizer
    type: lesson
    content: "Stories with score <6 on Behavior Change always needed rework"
```

## In Claude Code Specifically

Claude Code has its own memory system at `~/.claude/`. Our memory system is **project-level** — it lives inside the project repo and travels with git.

- `~/.claude/` = global preferences, user profile (managed by Claude Code)
- `memory/` = project knowledge, patterns, lessons (managed by our agents)
- These don't conflict — they complement each other
