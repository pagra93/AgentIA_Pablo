---
description: "Launch Definition phase — transform research into JTBDs, stories, quality review, and splitting."
---

# /define — Definition Pipeline

## Input
Research brief from /analyze, or user-provided context.

## Step 1: Generate JTBDs
Invoke **age-spe-jtbd-architect** with the research brief.
Present JTBDs. Ask PM: "Approve, modify, or add?"

## Step 2: Write Stories
Invoke **age-spe-story-writer** with approved JTBDs.

## Step 3: Quality Review
Invoke **age-sup-quality-coach** to review stories.
If any story scores < 7:
- Present suggestions to PM
- "Accept suggestions, modify, or proceed as-is?"
- If accepted: rerun story-writer with suggestions

## Step 4: Split Large Stories
Invoke **age-spe-story-splitter** only for stories flagged as >3 days.

## Step 5: Deliver
Present final stories with scoring.

**Where to save**: Save to the feature's folder:
- `docs/working-docs/[feature-name]/jtbds.md` — JTBDs generated
- `docs/working-docs/[feature-name]/stories.md` — Stories with scoring

If no feature folder exists, create it. Always organize by feature, not by phase.

Next: "Use /plan to create architecture and sprint plan."
