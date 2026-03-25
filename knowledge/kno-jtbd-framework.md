---
name: kno-jtbd-framework
description: "JTBD Reforzado (8 elements) + Wendel Checklist (4 questions) + Behavior Change (NOW/NEW with 3 ranges) + 6D Scoring. Complete framework for translating research to stories. Preloaded by jtbd-architect and story-writer."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "2.0.0"
  category: methodology
  source: "AI Mercadona User Story Framework"
  loaded-by: [age-spe-jtbd-architect, age-spe-story-writer]
---

# JTBD Reforzado Framework

## The Translation Problem

Research richness disappears when writing stories. "A mother trying to complete her grocery shopping while her kids run around, afraid of forgetting items" becomes "As a customer, I want quick cart access." The user becomes generic. Behavior change vanishes. Emotion evaporates.

Three forces destroy information:
1. **Abstraction without roots** — generalizing kills specificity (which IS the pattern)
2. **Hidden solution in behavior** — "want a favorites list" is a solution, not a job
3. **Hidden motivation dimensions** — functional + emotional + social all collapse into one generic phrase

---

## JTBD Reforzado — 8 Mandatory Elements

### A. Job Principal (The What)
The fundamental task. Must be a JOB, not a solution. A job answers "why?" A user can do the job in MULTIPLE ways.

**Validation test**: "Could the user achieve this in MULTIPLE ways?" If NO, you've collapsed the solution into the job.

### B. Struggle (Current Friction)
Concrete pain in LITERAL research quotes. Preserve emotional intensity in 4 layers:
- **Operative**: "I forget items"
- **Emotional**: "I regret it when I get home"
- **Social**: "My family complains"
- **Contextual**: "Especially when I'm with the kids"

### C. Trigger (The When)
The specific moment the job becomes urgent. Observable and verifiable.
- Bad: "When they need to buy" (generic)
- Good: "Every Tuesday at 5pm, leaving work with 20 min before picking up kids" (observable)

### D. Outcome (Desired Result)
Quantifiable or at least observable future state.
- Bad: "Complete shopping easily"
- Good: "Leave the store in 20 min with 100% of planned items, without anxiety"

### E. Three Motivation Dimensions
- **Functional**: What to achieve concretely? ("Complete weekly grocery in <20 min")
- **Emotional**: How to feel? ("Calm, in control, no anxiety")
- **Social**: How to be perceived? ("Organized mother who doesn't forget")

### F. Anxieties & Barriers
NOT "nice to know" — these are design constraints NOW.
- **Anxiety**: "What if the list gets deleted?" "What if it's not updated?"
- **Operative barrier**: "I don't know if this product is in my store"
- **Contextual barrier**: "No stable WiFi in the supermarket"

### G. Validation: Job vs Solution
Metacognitive element. Continuously verify: "Is this a job or a solution?"
Test: "Could a user achieve this in MULTIPLE ways?" If NO → rewrite.

### H. Source Tracing
Every element must trace back to research evidence. Format:
"[Quote/Observation]" — [Person/Role], [Date], [Context]

---

## Wendel Checklist — 4 Questions

If you can't fully answer ALL 4, the story is NOT ready.

| # | Question | What It Reveals |
|---|----------|----------------|
| 1 | **Prior Experience**: Has user tried something similar? How did it go? | Adoption friction prediction |
| 2 | **Relationship with Product**: Does user trust current tools? | Switching cost |
| 3 | **Situational Motivation**: What in their SPECIFIC context motivates change NOW? | Timing of intervention |
| 4 | **Current Impediment**: What SPECIFICALLY is blocking change? | What the solution must overcome |

---

## Behavior Change — NOW to NEW

### NOW (Current Behavior, Documented)
Specific, observable, with frequency.
"Every Tuesday tries to remember mentally. Often fails, forgetting items. For big shops, makes paper list that she frequently loses. Result: forgets 15-20% of planned items."

### NEW (Desired Behavior)
- **START**: What they'll begin doing (hardest to adopt — new step)
- **STOP**: What they'll stop doing (hardest to sustain — breaking habit)
- **DIFFERENT**: What they'll do differently (easiest — habit exists, tool changes)

### 3 Ranges of Change
Design is practice under uncertainty. Three levels give perspective:

| Level | Description | Purpose |
|-------|------------|---------|
| **Minimum** (acceptable) | Worst we'll accept | Prevents "failure" label on partial success |
| **Target** (expected) | What we design for | The design goal |
| **Over-top** (aspirational) | Best possible | Stretch goal for optimization |

---

## Story Structure That Retains Information

Stories from JTBDs must contain ALL of these:

1. **EPIC** — Job Principal
2. **STORY** — Specific behavior name
3. **ACCEPTANCE CRITERIA** — Given/When/Then with Trigger, NEW behavior, Observable outcome
4. **CONTEXT** — Wendel Checklist (4 questions answered)
5. **MOTIVATIONS** — Functional, Emotional, Social
6. **BARRIERS** — Anxieties and impediments
7. **EVIDENCE** — Traced to research
8. **SUCCESS METRICS** — Minimum / Target / Over-top

No element is optional. No information collapses. Engineering reads Acceptance Criteria and knows what to build. Design reads Context and understands why.

---

## 6D Scoring (Diagnostic, Not Verdict)

| Dimension | What It Measures | Red Flag |
|-----------|-----------------|----------|
| JTBD Context | Richness of research context | <5 = speculative, not research-based |
| User Specificity | Can you describe user without "user"? | <5 = generic persona |
| Behavior Change | Clear observable NOW vs NEW? | <5 = feature description, not change |
| Zone of Control | How much is within product control? | <5 = depends on external factors |
| Time Constraints | Understanding of user's time context? | <5 = unknown temporal pressure |
| Survivable Experiment | Can validate with small test? | <5 = all-or-nothing bet |

Stories from validated research typically score >=7 on first two dimensions automatically. A score of 2/10 on Behavior Change is a critical problem.

---

## Key Principles

1. **Specificity IS the asset** — Maria with 2 kids and 20 minutes is a PATTERN, not anecdote
2. **"Multiple ways" test always** — If only one way → solution collapsed into job
3. **4 layers of struggle** — Operative, Emotional, Social, Contextual
4. **Anxieties = design constraints** — Not afterthoughts
5. **3 ranges always** — Minimum, Target, Over-top
6. **AI retains, human decides** — AI maintains all information. PM investigates and chooses.
7. **Documented gap > hidden gap** — A documented gap is an opportunity. A hidden gap is a time bomb.
