# Scenario: Defining Stories from a JTBD

## Context
JTBD Architect produced a validated JTBD. Story Writer needs to convert it into sprint-ready stories.

## Input (from JTBD Architect)
```
JTBD: Warehouse Receiving Discrepancy Resolution

Job Performer: Receiving operator during 6-14h shift at Lleida warehouse
Trigger: Delivery truck arrives with items that don't match the purchase order
Struggle: "I have to check three systems and it still takes 20 minutes" — Carlos
Desired Outcome: Resolve discrepancy in <5 minutes without leaving the dock

Motivation:
- Functional: Save 15 minutes per discrepancy
- Emotional: Feel in control, not stressed
- Social: Be seen as efficient by shift manager

Evidence: Gemba walk Feb 2026, 20 observations, 18% discrepancy rate
```

## Expected Agent Behavior

### Story Writer (age-spe-story-writer)

Should produce stories like:

**Good Story**:
```
As a receiving operator during the morning shift at Lleida warehouse,
When a delivery arrives that doesn't match the PO,
I want to see the discrepancy highlighted at the dock
So that I can resolve it in <5 minutes without calling the analyst.

Behavior Change:
- START: Checking discrepancies at the dock in real-time
- STOP: Calling the analyst and waiting for cross-reference
- DIFFERENT: Resolution in 5 min instead of 20 min

Dimensional Scoring: ~8/10 average
```

**Bad Story** (should NOT produce):
```
As a user, I want a barcode scanner so that I can scan items.
(Generic user, solution as need, no behavior change)
```

### Quality Coach (age-sup-quality-coach)

Should:
- Verify no antipatterns
- Score dimensions
- If all >=7: "Ready for sprint"
- If any <7: suggest specific improvements (as proposals, not commands)

## Key Validation Points

- [ ] Story traces to the JTBD with specific job performer
- [ ] Behavior Change is quantified (5 min vs 20 min)
- [ ] Given-When-Then acceptance criteria are testable
- [ ] Quality Coach suggestions are proposals ("Consider..."), not commands
- [ ] Stories >3 days get flagged for Story Splitter
