---
description: "Implement stories from sprint plan using context-engineered sub-agents. Each story gets a fresh context window for consistent PEAK quality."
---

# /build — Development (Context-Engineered)

## Context Engineering Principle

**The orchestrator (you) stays lean. Sub-agents do the heavy lifting.**

Each story runs in a fresh sub-agent with its own 200k context window. You coordinate — read the sprint plan, spawn agents, collect results, track state. You NEVER read story content, design docs, or architecture yourself. Sub-agents read their own context.

```
You (orchestrator): ~15% context → spawn Task per story → collect results
Sub-agent (story):  fresh 200k  → read story + design + arch → implement → commit
```

This prevents context rot: story 5 gets the same PEAK quality as story 1.

### Context Budget
| Your Usage | Action |
|------------|--------|
| 0-30% | Normal operation |
| 30-50% | Continue, but monitor |
| 50%+ | STOP — save state to tasks/build-state.md, inform PM to run /build again |

---

## Step 0: Session Recovery

If `tasks/build-state.md` exists, read it FIRST.
- Resume from last completed story — skip already-done work.
- Do NOT re-read stories already marked as Done.
- If the file shows a story was in progress but not committed, restart that story.

---

## Step 1: Read Sprint Plan (METADATA ONLY)

Read `tasks/todo.md` to identify:
- What stories exist and their IDs (HU-XX)
- Their execution order and dependencies
- Which are already done vs pending

**CRITICAL**: Do NOT read any of these yourself:
- `docs/working-docs/[feature]/stories.md` — the sub-agent reads this
- `docs/working-docs/[feature]/design-analysis.md` — the sub-agent reads this
- `docs/working-docs/[feature]/architecture.md` — the sub-agent reads this

You only need to know WHAT stories exist and WHERE their files are. Not what's IN them.

Create `tasks/build-state.md` if it doesn't exist:
```markdown
# Build State
Sprint: [name from todo.md]
Started: [today's date]
Stories: [total] total, 0 done, [total] pending

## Last Activity
[date] — Sprint started

## Completed
| Story | Commit | Status |
|-------|--------|--------|

## Next
[first story ID] — [title from todo.md]
```

---

## Step 2: Build Each Story with Fresh Context

For each pending story, spawn a **Task sub-agent** (subagent_type: "general-purpose"):

```
Task prompt for each story:
"You are implementing a user story. Read these files FIRST, then implement.

FILES TO READ:
1. [project CLAUDE.md path] — project conventions, stack, patterns
2. docs/working-docs/[feature]/stories.md — find story HU-XX, read its:
   - Acceptance criteria (Given-When-Then)
   - Design section (anatomy, navigation, interaction)
   - Technical notes (data model, API endpoints, business logic, edge cases)
   - Verificacion Estructural (if exists — what must be TRUE, EXIST, and WIRED)
3. docs/working-docs/[feature]/design-analysis.md — if exists, 6-layer analysis
4. docs/working-docs/[feature]/architecture.md — if exists, ADRs and component design

IMPLEMENT:
- Follow CLAUDE.md conventions strictly
- Write tests alongside implementation:
  - TDD for pure logic (calculations, state, transformations): test FIRST
  - Implementation-first for UI: build component, then integration tests
  - Map each Given-When-Then to appropriate test type (unit/integration/e2e)
  - See kno-testing-strategy for Testing Trophy methodology
- Follow rul-definition-of-done checklist
- Follow rul-git-branch-management

ANALYSIS PARALYSIS GUARD:
If you make 5+ consecutive Read/Grep/Glob calls without any Edit/Write/Bash action:
STOP. State in one sentence why you haven't written anything yet. Then either:
1. Write code (you have enough context), or
2. Report 'blocked' with the specific missing information.
Do NOT continue reading. Analysis without action is a stuck signal.

FIX ATTEMPT LIMIT:
Track fix attempts per failing test or error. After 3 attempts on the same issue:
- STOP fixing
- Document the issue in your report under 'Deferred Issues'
- Continue to the next task
- Do NOT restart the build or keep retrying

DEVIATION RULES (unexpected work during implementation):
| Rule | Trigger | Action |
|------|---------|--------|
| 1: Bug | Broken behavior, test failures from your changes | Fix automatically, verify |
| 2: Missing Critical | Missing error handling, auth, validation | Add it, test, verify |
| 3: Blocking | Missing dependency, wrong types, broken import | Fix the blocker, verify |
| 4: Architectural | New DB table, schema change, new service | STOP — report to PM, do NOT proceed |
Priority: Rule 4 (STOP) > Rules 1-3 (auto-fix) > Unsure → treat as Rule 4.
Scope: Only auto-fix issues DIRECTLY caused by the current story's changes.

STUB CHECK:
Before declaring done, scan all files you created/modified for:
- Empty arrays/objects (=[], ={}) that flow to rendering
- Placeholder text: 'TODO', 'FIXME', 'placeholder', 'coming soon', 'not available'
- Components with no data source wired
- Functions returning hardcoded values
If stubs exist that prevent the story's goals from being achieved, FIX them.

COMMIT:
Make an atomic commit for this story:
  feat(HU-XX): [what was built]

REPORT:
When done, report back:
- Files created/modified (list)
- Tests written and results (pass/fail)
- Commit hash
- Any stubs remaining (with file:line)
- Any deferred issues (from fix attempt limit)
- Any deviations from the story spec (with Rule number)
"
```

### Anti-Reflexive Chaining Rule

When spawning the sub-agent for story N:
- **IF story N depends on a previous story** (imports types, calls its API): include in the prompt "Also read [specific file from previous story] for [specific reason]"
- **IF story N is independent**: pass ZERO references to other stories' work. Clean context.

**NEVER** reflexively chain: "Read summaries of HU-01, HU-02, HU-03 before implementing HU-04" — unless HU-04 actually depends on them.

### Collecting Results

When the sub-agent returns:
1. Read its report (files, tests, commit, stubs, issues)
2. Update `tasks/build-state.md` with the completion
3. Update `tasks/todo.md` marking the story as done
4. If the sub-agent reports stubs or issues, note them in build-state.md
5. Move to next story

---

## Step 3: Frontend Quality (Optional)

After completing stories with UI work, suggest Impeccable for design quality:
- `/polish` — general design refinement
- `/audit` — evaluate design quality (typography, color, spacing)
- `/typeset` — fix typography with proper scales
- `/arrange` — fix layout and spacing

See https://impeccable.style/ — install with: `npx skills add pbakaus/impeccable`

---

## Step 4: When All Stories Done — ALWAYS Remind

Update `tasks/build-state.md` with final status, then:

"Sprint stories built and committed. Each story was implemented with a fresh context window.

**Build Summary:**
| Story | Commit | Stubs | Issues |
|-------|--------|-------|--------|
| HU-XX | abc123 | Clean | None |
| ... | ... | ... | ... |

**Next step: /review** — runs tests, code review, structural verification, QA audit, and asks if you want full feature docs.

If you skip /review:
- No tests verified against full suite
- No code review
- No structural verification (must-haves not checked)
- No QA audit
- No lessons learned saved
- No feature documentation generated
- PROJECT_KNOWLEDGE.md won't be updated"

---

## Important

- **Tasks <30 seconds**: Just do them directly, no /build needed
- **Single story sprint**: Still use the sub-agent pattern — it ensures clean context
- **Sub-agent fails**: If a Task sub-agent fails or returns an error, report the issue to the PM. Do NOT try to implement the story yourself (that defeats the context engineering).
- **Impeccable**: Optional but recommended for frontend design quality
