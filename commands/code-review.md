---
description: "Validation-only pipeline — code review, tests, audit, evaluation. No building."
---

# /code-review — Validation Only

## Step 1: Code Review
Invoke **age-spe-code-reviewer**: review recent changes for quality, security, best practices.

## Step 2: Test
Invoke **age-spe-test-engineer**: run tests, verify coverage.

## Step 3: Audit
Invoke **age-sup-auditor**: check against Definition of Done.

## Step 4: Evaluate
Invoke **age-sup-evaluator**: score on Completeness, Quality, Compliance, Efficiency.

## Step 5: Report

```markdown
## Code Review Summary
- Code Review: [APPROVE/REQUEST CHANGES]
- Tests: [PASS/FAIL] — [coverage]%
- Audit: [X/Y compliant]
- Score: [X/10]
- Issues: [list]
```
