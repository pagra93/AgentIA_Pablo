---
description: "Implement stories from sprint plan. Claude Code builds directly — no engineering sub-agents. Use Impeccable for frontend design quality."
---

# /build — Development

## Step 1: Read Sprint
Read `tasks/todo.md` for current sprint plan. Identify stories to build.
If `docs/working-docs/[feature]/` exists, also read:
- `stories.md` — acceptance criteria and behavior change
- `design-analysis.md` — 6 capas (UI, DB, API, Logic, Integrations, Edge Cases)
- `architecture.md` — ADRs and component design

## Step 2: Implement

Build directly — no sub-agents needed. Claude Code already knows the stack from CLAUDE.md.

**For each story:**
1. Read the acceptance criteria (Given-When-Then)
2. Read the design-analysis if exists (what DB tables, APIs, logic)
3. Implement following CLAUDE.md conventions
4. Include tests (unit at minimum)
5. Follow rul-definition-of-done checklist
6. Follow rul-git-branch-management

**For frontend work — use Impeccable for design quality:**
- `/polish` — general design refinement after building UI
- `/audit` — evaluate design quality (typography, color, spacing)
- `/typeset` — fix typography with proper scales
- `/arrange` — fix layout and spacing

See https://impeccable.style/ — install with: `npx skills add pbakaus/impeccable`

## Step 3: Track Progress
After each story:
1. Update `tasks/todo.md` marking it as done
2. Commit with descriptive message
3. Note implementation decisions that differ from plan in working-docs/

## Step 4: When All Stories Done — ALWAYS Remind

"Sprint stories built and committed.

**Next step: /review** — runs tests, code review, QA audit, and asks if you want full feature docs.

If you skip /review:
- No tests verified
- No code review
- No QA audit
- No lessons learned saved
- No feature documentation generated
- PROJECT_KNOWLEDGE.md won't be updated"

## Important
- Tasks <30 seconds: just do them directly, no /build needed
- Commit after each completed story
- For frontend: Impeccable skills are optional but recommended for design quality
