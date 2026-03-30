---
name: rul-definition-of-done
description: "When a story implementation is complete. Preloaded by engineering and testing agents."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: quality
  loaded-by: [age-spe-frontend-dev, age-spe-backend-arch, age-spe-mobile-builder, age-spe-test-engineer, age-spe-code-reviewer, age-sup-auditor]
---

# Definition of Done

A story is DONE when ALL are true:

## Code
- [ ] Compiles without errors or warnings
- [ ] Static analysis passes (type checking, linter)
- [ ] All new code has tests appropriate to its type:
  - Business logic / data transformers: unit tests
  - Multi-component interactions / API contracts: integration tests
  - Critical user journeys (top 10-20 flows): E2E test
  - Trivial code (getters, config, boilerplate): no test required — do not pad coverage
- [ ] All tests pass (full suite — existing + new, not just new tests)
- [ ] No regressions introduced (existing tests unchanged or intentionally updated with justification)
- [ ] No flaky tests introduced (tests pass consistently, no timing dependencies)
- [ ] Coverage: 80%+ branch coverage on new business logic (not global line %)

## Review
- [ ] Code review completed (age-spe-code-reviewer)
- [ ] No critical issues remaining
- [ ] Warning-level issues addressed or accepted with justification

## Documentation
- [ ] docs/ updated with relevant changes
- [ ] docs/PROJECT_KNOWLEDGE.md updated if new functionality
- [ ] API documentation updated (if applicable)
- [ ] Changelog entry added

## Verification
- [ ] Diff reviewed against main branch
- [ ] Acceptance criteria from story verified
- [ ] QA audit passed (age-sup-auditor)

## Git
- [ ] Committed with descriptive message
- [ ] Branch is clean (no uncommitted changes)

## Quick Check

NOT done if you can't answer YES to:
- "Could I ship this to production right now?"
- "Would a Staff Engineer approve this PR?"
- "Is the documentation accurate and up to date?"
