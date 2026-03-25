---
description: "Launch Analysis phase — evaluate problem/PRD with Quality Guard, then research gaps."
---

# /analyze — Problem Analysis Pipeline

## Step 1: Gather Context
Ask: "Describe the problem or paste the PRD you want me to analyze."
If file path provided, read it.

## Step 2: Quality Guard Evaluation
Invoke **age-spe-quality-guard**:
- Evaluate the problem/PRD across 3 dimensions
- Wait for the scoring report

## Step 3: Present Results and Ask PM
- Score >= 7: "Problem is well-defined. Shall I proceed to research?"
- Score 4-6: "Gaps identified. Proceed with elevated risk or address gaps first. Your call."
- Score < 4: "Significant gaps. High risk of solving wrong problem. Strongly recommend addressing. But it's your call."

**Never block. PM decides.**

## Step 4: Research (if PM proceeds)
Invoke **age-spe-researcher**:
- Research knowledge gaps using Mom Test methodology
- Execute competitive analysis
- Produce decision-ready brief

## Step 5: Deliver
Present research brief.

**Where to save**: If analyzing a feature from /design-to-prd, save to `docs/working-docs/[feature-name]/research.md`. Otherwise, save to `docs/working-docs/[topic-name]/research.md`. Always organize by feature, not by phase.

Next: "Use /define to generate JTBDs and stories from this research."
