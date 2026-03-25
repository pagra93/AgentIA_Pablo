---
name: rul-definition-of-ready
description: "When a user story is ready to enter a sprint. Preloaded by quality-coach and sprint-planner."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: quality
  loaded-by: [age-sup-quality-coach, age-spe-sprint-planner]
---

# Definition of Ready

A story is READY when ALL are true:

1. **JTBD is clear**: Traces to a validated JTBD with evidence
2. **Job Performer is specific**: Not "user" — a specific role with context
3. **Acceptance criteria exist**: At least 2 Given-When-Then testable criteria
4. **Behavior change is quantified**: START/STOP/DIFFERENT with frequency
5. **Dimensional scoring >= 7**: Average across 6 dimensions
6. **Size <= 3 days**: If larger, must be split first
7. **Vertically split**: Delivers end-to-end value
8. **Independent**: Can be built/shipped without waiting for other stories
9. **No blocking questions**: All unknowns resolved or accepted as risk

## Quick Check (for PM)

- [ ] Can I explain WHO does WHAT differently after this ships?
- [ ] Can an engineer write tests from the acceptance criteria alone?
- [ ] Can this be shipped independently in <= 3 days?
- [ ] Does the dimensional scoring average >= 7?

If any NO, story is NOT ready.
