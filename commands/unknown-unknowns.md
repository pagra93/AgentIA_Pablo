---
description: "Detect hidden risks, blind spots, and unknown unknowns in the current project. Full audit across 8 dimensions. Can run anytime, standalone."
---

# /unknown-unknowns — Risk Discovery Audit

Scans the project to surface what you don't know you're missing. Works at any stage: planning, development, pre-launch, or post-launch.

## When to Use

- Starting a new project and want to plan well
- Before a launch or major release
- After building something and want a sanity check
- Anytime you wonder "what am I missing?"
- Architecture review before scaling
- Due diligence before investment/partnership

## How It Works

### Step 1: Mode Detection
Automatically detects:
- **Mode A (Code Exists)**: Scans codebase structure, dependencies, configs, auth, APIs, DB, business logic (8-12 critical files max)
- **Mode B (Planning)**: Asks contextual questions about the concept

### Step 2: Context Questions
Asks only what the code can't answer:
- Project stage and timeline
- Business model and revenue
- Scale expectations
- Team structure and experience

### Step 3: Choose Dimensions
Presents 8 analysis dimensions — pick which ones to audit:

1. Security & vulnerabilities
2. Architecture & scalability
3. Legal / compliance / regulatory
4. Costs & operations
5. UX & accessibility
6. Data management & privacy
7. Product & business blind spots
8. AI-specific risks (auto-enabled if LLMs/agents detected)

### Step 4: Analysis
For each dimension, surfaces findings in 3 tiers:
- **CRITICAL** — Could kill the project. Address before launch.
- **IMPORTANT** — Will cause pain. Address before scaling.
- **WORTH KNOWING** — Matters when scaling.

Each finding includes: blind spot, why it matters, how to fix it, effort estimate.

### Step 5: Action Plan
Top 5 prioritized actions — not a wall of text, just what to do next.

## Output

Saved to `docs/working_docs/risk-audit/` if docs/ exists.

## Standalone vs Pipeline

| Mode | How | When |
|------|-----|------|
| **Standalone** | `/unknown-unknowns` | Anytime, any project |
| **In /analyze** | Auto after Quality Guard | Part of problem analysis |
| **In /plan** | Auto after Tech Architect | Part of architecture review |

## Skill Reference

Uses `ski-unknown-unknowns` with 6 reference domains:
- references/security.md
- references/architecture.md
- references/legal.md
- references/costs.md
- references/product.md
- references/ai-agents.md
