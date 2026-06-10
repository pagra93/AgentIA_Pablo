---
description: "Validation-only pipeline — code review, tests, audit, evaluation. No building."
---

# /code-review — Validation Only

## Pre-flight: leer `prompt_override` de la HU

Antes de invocar cualquier agente sobre una HU o EPIC concreta:

1. Localiza el frontmatter YAML de esa HU en `docs/<área>/features/<feature>/stories.md`.
2. Lee el campo `prompt_override`. Si existe y no está vacío, **inclúyelo como contexto adicional explícito** en el mensaje al sub-agente: «Contexto adicional del usuario para esta tarea: <prompt_override>».
3. El sub-agente ya conoce la regla universal (ver `rul-prompt-override` precargado) y la respetará.
4. Si no hay `prompt_override`, procede normal.

Esto vale tanto si el usuario lanza el comando manualmente (clipboard) como si el PM lo lanza autónomamente.

---


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
