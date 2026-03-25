---
description: "Launch Planning phase — design architecture and create sprint plan from validated stories."
---

# /plan — Planning Pipeline

## Input
Validated stories from /define.

## Step 1: Architecture Design
Invoke **age-spe-tech-architect** with stories. Must read CLAUDE.md for stack constraints.
Present architecture. Ask PM: "Approve or adjust?"

## Step 2: Sprint Planning
Invoke **age-spe-sprint-planner** with stories + architecture.
Sprint plan written to `tasks/todo.md`.

## Step 3: Confirm
Present the sprint plan. Ask PM: "Approve this plan to start building?"

Next: "Use /build to start executing the sprint."
