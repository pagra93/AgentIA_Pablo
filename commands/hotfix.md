---
description: "Quick bug fix pipeline — lightweight analysis, fix, test, verify. Only saves learning when RESOLVED."
---

# /hotfix — Bug Fix Pipeline

## Step 1: Understand
Ask: "Describe the bug — error messages, steps to reproduce, expected vs actual."

## Step 2: Quick Quality Guard
Invoke **age-spe-quality-guard** in lightweight mode:
"Is this bug well-defined? Check: repro steps, expected behavior, actual behavior."
Report risks but don't block.

## Step 3: Fix
Route to appropriate engineer:
**age-spe-frontend-dev** / **age-spe-backend-arch** / **age-spe-mobile-builder**

## Step 4: Test
Invoke **age-spe-test-engineer**: verify fix, check for regressions.

## Step 5: Quick Audit
Invoke **age-sup-auditor**: does this fix meet Definition of Done?

## Step 6: Technical Check

**IF tests FAIL or audit FAILS:**
- Do NOT save any learning. The bug is NOT resolved yet.
- Report what failed and why.
- PM decides: retry fix, try different approach, or abandon.
- If retrying: go back to Step 3. NO documentation created.

**IF tests PASS and audit PASS:**
- Continue to Step 7. But tests passing does NOT mean the bug is fixed.

## Step 7: PM Validation (CRITICAL)

Tests verify what the CODE does. The PM verifies what the USER experiences.

ALWAYS ask the PM:

"Los tests pasan y el audit esta ok.

Ahora necesito que TU verifiques:
- Reproduce el bug original con los mismos pasos
- Confirma que ya no ocurre
- Comprueba que no se ha roto nada que uses normalmente

¿El bug esta realmente resuelto?"

**Three possible answers:**

### PM says "SI, resuelto"
→ Continue to Step 8 (commit + save learning). The bug IS resolved.

### PM says "NO, sigue pasando"
→ Do NOT commit. Do NOT save learning. The bug is NOT resolved.
→ Ask: "Que ves exactamente? Describe que pasa cuando lo pruebas."
→ This new info is gold — the gap between what tests check and what really happens IS the bug.
→ Go back to Step 3 with the new understanding. NO documentation created.

### PM says "PARCIAL — algo mejoro pero no del todo"
→ Do NOT commit yet. Do NOT save learning.
→ Ask: "Que parte funciona y que parte no?"
→ This narrows the problem. Go back to Step 3 focused on what remains.

**ONLY proceed to Step 8 when PM explicitly confirms the bug is resolved.**

## Step 8: Commit
Commit "fix: [description]"
Update PROJECT_KNOWLEDGE.md if behavior changed.

## Step 9: Save the Learning (ONLY when PM confirms resolved)

**ONLY execute this step if Step 7 = PM says "SI, resuelto".**
Not when tests pass. Not when audit passes. When the PM CONFIRMS it works.

1. **Check for duplicate**: Search `tasks/lessons.md` for existing entries about the same bug/area. If found, UPDATE the existing entry instead of creating a new one.

2. Append (or update) in `tasks/lessons.md`:

```markdown
### [Date] — bug-resolution — [Short title]
**Bug**: [what was broken]
**Root Cause**: [WHY it was broken — the real reason, not the symptom]
**Fix**: [what you changed and why]
**Prevention**: [how to avoid this in the future — test, rule, pattern]
**Files**: [paths of files changed]
**Attempts**: [how many tries it took — 1 if first try, N if multiple]
```

3. Update `memory/MEMORY.md` section "Recurring Issues" — but only if this pattern could happen again. Don't log one-off typos.

4. If the bug reveals a test gap:
   "Test gap: [scenario] was not covered. Added test in [file]."

## Step 10: Confirm

"Hotfix complete, verified, and learning saved.

Bug: [title]
Root cause: [one line]
Fix: [one line]
Attempts: [N]
Prevention: [one line]
Saved to: tasks/lessons.md"

## Anti-Bloat Rules

These rules prevent documentation noise:

1. **Only save when RESOLVED** — failed attempts produce ZERO documentation
2. **No duplicates** — if a similar bug was already logged, UPDATE that entry
3. **Skip trivial bugs** — a typo fix or CSS tweak does NOT need a lessons entry. Only log if:
   - It took >15 minutes to find/fix
   - The root cause was non-obvious
   - It could happen again
   - It reveals a gap in tests or process
4. **One entry per bug** — even if you ran /hotfix 20 times, only 1 entry (the resolution)
5. **Count attempts** — note "Attempts: 5" so you know this was hard, but don't create 5 entries
