---
description: "Launch QA phase — test, code review, audit, evaluate, optimize, document, and optionally generate full feature docs."
---

# /review — Testing & QA Pipeline

## Step 1: Testing (Validation Loop)
Invoke **age-spe-test-engineer**: generate tests, execute full suite, verify coverage, iterate (max 3 cycles).

The test-engineer will:
1. Detect test framework from CLAUDE.md / project config
2. Generate tests from acceptance criteria (Given-When-Then → unit / integration / E2E)
3. Execute full test suite (existing + new — not just new tests)
4. Check branch coverage on business logic (target 80%+)
5. Iterate if failures are test bugs (max 3 cycles)
6. Report: results, coverage, regressions, app bugs vs test bugs

## Step 2: Code Review
Invoke **age-spe-code-reviewer**: review for quality, security, performance.
If critical issues → fix before continuing.

## Step 3: QA Audit Cycle (sequential)

### 3a: Audit
Invoke **age-sup-auditor**: verify compliance with Definition of Done.

### 3b: Evaluate
Invoke **age-sup-evaluator**: score phase on Completeness, Quality, Compliance, Efficiency.

### 3c: Optimize
Invoke **age-sup-optimizer**: review history, propose improvements.
Updates `tasks/lessons.md`, `memory/MEMORY.md`, and `docs/PROJECT_KNOWLEDGE.md`.

## Step 4: Auto Documentation
Use **ski-doc-updater** to update PROJECT_KNOWLEDGE.md, changelog, API docs.

## Step 5: Final Verification
- [ ] Tests pass
- [ ] Code review approved
- [ ] Audit passed
- [ ] Docs updated
- [ ] Changes committed

All pass: "DONE. Sprint stories verified and documented."
Any fail: Report what's missing.

## Step 6: Feature Documentation (ALWAYS ask)

**ALWAYS ask the PM after Step 5 passes:**

"Feature completada y verificada. ¿Genero documentación completa de esta feature?"

**If PM says yes:**
1. Detect which feature was just completed (from tasks/todo.md or ask PM)
2. Read ALL working docs from `docs/working-docs/[feature]/`:
   - design-analysis.md (if exists — from /design-to-prd)
   - prd.md (problem definition)
   - research.md (Mom Test findings)
   - jtbds.md (Jobs-to-be-Done)
   - stories.md (user stories with scoring)
   - architecture.md (ADRs, components)
3. Read the actual implementation (code, tests, configs)
4. Generate `docs/project-docs/features/[feature].md` using **ski-project-docs** with:
   - What it does (user-facing description)
   - How it works (technical: architecture, data flow, key components)
   - How to use it (examples, configuration)
   - API endpoints (if applicable)
   - Known limitations
   - Related features
   - Evidence trail (linked to working-docs)
5. Update `docs/project-docs/features/_index.md` (feature list)
6. Update `docs/project-docs/changelog.md`

**If PM says no:**
Skip. Documentation can be generated later with `/docs [feature-name]`.

## Why Always Ask

The working-docs folder has EVERYTHING: the design analysis, PRD, research, JTBDs, stories, and architecture. Right after /review is the best moment to generate docs because:
- All context is fresh
- All artifacts exist
- The feature was just verified
- Nothing has been forgotten yet

Generating docs later is possible (`/docs [feature]`) but you'll have less context in the conversation.
