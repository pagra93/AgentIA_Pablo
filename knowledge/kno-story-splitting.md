---
name: kno-story-splitting
description: "9 story splitting heuristics from Eduardo Ferro. Survivable experiment concept. Preloaded by story-splitter agent."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: methodology
  source: "Eduardo Ferro (@eferro)"
  loaded-by: [age-spe-story-splitter]
---

# Story Splitting (Eduardo Ferro / @eferro)

## Fundamental Principle

Every split = a **survivable experiment**. Each piece: independently valuable, separately deployable, ≤3 days.

## CRITICAL: Always Vertical, Never Horizontal

Each split delivers value through ALL layers (UI + logic + data).

## The 9 Heuristics

### 1. Start by Outputs
Minimum VISIBLE output to the user first.

### 2. Narrow the Segment
Reduce scope to smaller user group/scenario.

### 3. Extract Basic Utility
Simplest version that's actually useful.

### 4. Dummy to Dynamic
Hardcoded first, automate later.

### 5. Simplify Outputs
Reduce output complexity progressively (table → chart → interactive).

### 6. Split by Capability
Each CRUD operation = a story.

### 7. Split by Example
Each acceptance criterion example = a story.

### 8. Learning vs Earning
Validate assumptions before building (analytics story → feature story).

### 9. Put It on Crutches
Temporary workarounds first, remove later (manual → automated).

## Choosing the Right Heuristic

| Situation | Best Heuristic |
|-----------|---------------|
| Many features | #1 Start by Outputs |
| Many user types | #2 Narrow Segment |
| Complex but simple core | #3 Extract Basic Utility |
| Complex logic | #4 Dummy to Dynamic |
| Rich UI/output | #5 Simplify Outputs |
| CRUD-like | #6 Split by Capability |
| Many acceptance criteria | #7 Split by Example |
| High uncertainty | #8 Learning vs Earning |
| Needs automation | #9 Put It on Crutches |
