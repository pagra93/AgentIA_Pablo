# Scenario: Analyzing a Weak PRD

## Context
PM submits a PRD for a "warehouse optimization tool" that has solution language, no metrics, and no process documentation.

## Input
```
PRD: Warehouse Optimization Tool
We need to build a mobile app with barcode scanning that integrates with SAP
to modernize our warehouse receiving process. The app should have real-time
inventory sync and automated reports for managers.
```

## Expected Agent Behavior

### Step 1: Quality Guard (age-spe-quality-guard)

Should score approximately:
- D1 (Problem Completeness): **2/10** — No metrics, no baseline, no field observations
- D2 (Process Quality): **1/10** — No AS-IS, no TO-BE, no actors identified
- D3 (WHAT/HOW Separation): **3/10** — "mobile app", "barcode scanning", "SAP integration" are solution prescriptions

**Expected verdict**: "Significant gaps. High risk of solving wrong problem. Strongly recommend addressing. PM decides."

**NOT acceptable**: "BLOCKED. Fix the PRD before proceeding."

### Step 2: PM Decision

If PM says "proceed anyway":
- System proceeds to research phase
- Risk is logged but does NOT block

### Step 3: Researcher (age-spe-researcher)

Should:
- Identify gaps: "No user interviews, no baseline data, no process map"
- Design Mom Test questions: "Walk me through what happens when a truck arrives"
- NOT accept the solution framing (challenge: "Why mobile app specifically?")

## Key Validation Points

- [ ] Quality Guard scores conservatively (not generous)
- [ ] Quality Guard presents risks as information, not blocks
- [ ] PM decision is respected regardless of score
- [ ] Researcher challenges assumptions, doesn't validate them
- [ ] No agent uses "BLOCKED" language
