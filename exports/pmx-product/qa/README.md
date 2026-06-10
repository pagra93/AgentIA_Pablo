# QA Layer — How It Works

## Overview

The QA Layer is a 3-agent cycle that runs after every `/review` command. It verifies quality, scores the work, and proposes improvements. No other agent system has this.

## The 3-Agent Cycle

```
/review triggers:
  1. age-spe-test-engineer  → Run tests, verify acceptance criteria
  2. age-spe-code-reviewer  → Review code quality, security, performance

Then the QA cycle:
  3. age-sup-auditor        → Check compliance with rules (read-only)
  4. age-sup-evaluator      → Score the phase on 4 dimensions (read-only)
  5. age-sup-optimizer      → Detect patterns, propose improvements (read-only)
```

## What Each Agent Does

### Auditor (age-sup-auditor)
- **Reads**: All `rul-*.md` files from `rules/`
- **Checks**: Each rule point against the actual work
- **Output**: Compliance report (X/Y compliant, Z%)
- **Writes to**: `qa/qa-report.md` (appends)
- **NEVER modifies code** — read-only

### Evaluator (age-sup-evaluator)
- **Reads**: Auditor's report + the work being evaluated
- **Scores**: 4 dimensions, each 0-10:
  - Completeness (30%) — Was everything planned delivered?
  - Quality (30%) — Is the output well-crafted?
  - Compliance (25%) — Follows the rules?
  - Efficiency (15%) — Done without waste?
- **Output**: Phase scorecard with weighted average
- **Writes to**: `qa/qa-report.md` (appends)

### Optimizer (age-sup-optimizer)
- **Reads**: All previous entries in `qa/qa-report.md`
- **Detects**: Recurring patterns across multiple review cycles
- **Proposes**: Prioritized improvements (ranked by impact x frequency)
- **Writes to**:
  - `qa/qa-report.md` (appends optimization report)
  - `tasks/lessons.md` (new lessons learned)
  - `docs/PROJECT_KNOWLEDGE.md` (process improvements)
- **NEVER applies changes** — only proposes. PM decides.

## QA Tiers

Configured in `qa/qa-config.yaml`:

| Tier | What Runs | When to Use |
|------|-----------|-------------|
| `none` | Nothing | Prototyping, throwaway code |
| `light` | Auditor only | Small changes, hotfixes |
| `full` | Auditor → Evaluator → Optimizer | Sprint reviews, feature completion |

## How Reports Accumulate

`qa/qa-report.md` is **append-only**. Each /review cycle adds a new section:

```markdown
---
## Audit Report — 2026-03-24
[Auditor output]

## Phase Scorecard — 2026-03-24
[Evaluator output]

## Optimization Report — 2026-03-24
[Optimizer output]
---

## Audit Report — 2026-04-01
[Next cycle...]
```

Over time, the Optimizer reads ALL previous entries to detect trends:
- "Error handling issues appeared in 3 of last 5 audits"
- "Quality score trending up: 6.2 → 7.1 → 7.8"

## Key Principle

**Supervisors observe, never impose.** The QA agents flag issues and propose improvements. The PM always decides what to accept. This is NOT a gate — it's a quality feedback loop.
