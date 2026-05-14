---
name: kno-mom-test
description: "Mom Test methodology (Rob Fitzpatrick) + Gap Detection + JTBD Reforzado + Wendel Checklist. Complete research framework. Preloaded by researcher agent."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "2.0.0"
  category: methodology
  source: "The Mom Test (Rob Fitzpatrick) + AI Mercadona User Story Framework"
  loaded-by: [age-spe-researcher]
---

# The Mom Test + Research Framework

## Core Principle

If you ask your mother if your business idea is good, she'll say yes because she loves you. Not because it's good. Design questions so that NOBODY can give a false answer.

## 3 Rules

1. **Talk about THEIR life, not YOUR idea**
2. **Ask about SPECIFICS in the past, not generics about the future**
3. **Talk less, listen more** — if talking >20%, you're pitching

## Toxic Questions (PROHIBITED)

| Type | Example | Why It's Bad |
|------|---------|-------------|
| Opinion | "Would you like...?" "What do you think?" | People say what you want to hear |
| Hypothetical | "Would you use X?" "How much would you pay?" | Intentions ≠ behavior |
| Leading | "Don't you think it would be better if...?" | Confirms YOUR bias |

## Truth-Revealing Questions (USE THESE)

- "Tell me about the last time you [did X]. What happened?"
- "What did you do when [Y] occurred?"
- "How do you solve [Z] currently?"
- "How long does it take you?"
- "What did you try before doing what you do now?"
- "How many times this week did something like that happen?"
- "When you found the problem, who did you tell? How long did it take to resolve?"
- "Did you ever invent a faster way to do this on your own? Tell me about it."

## Detecting False Signals

| Signal | What They Say | What To Ask Instead |
|--------|--------------|-------------------|
| Compliment | "That's a great idea!" | "How are you solving this today?" |
| Hypothetical | "I would definitely use that!" | "When was the last time you looked for a solution?" |
| Feature request | "It should also do X!" | "Why? What problem would that solve for you?" |
| Generic complaint | "Everything is slow" | "Which part exactly? Tell me about the last time." |

## Interview Structure by Role

For each role, 5 sections (20-30 min total):

1. **Context** (2 min): Typical day, experience, how shift starts
2. **Current Process** (10 min): Step by step, last time, tools used, time taken
3. **Problems & Friction** (10 min): What takes most time, last failure, frequency, workarounds
4. **Dependencies** (5 min): Other roles needed, wait times, what happens when unavailable
5. **Close** (3 min): Anything not asked, who else to talk to

## Gap Detection Categories

### PF: Process Functional Gaps
Missing info about HOW the process works. Steps not detailed, volumes not quantified, exceptions not documented.

### PI: Section Inventory Gaps
Missing info about AREAS affected. Which sections, locations, shifts, seasonal variations.

### CU: User Context Gaps
Missing understanding of how users REALLY interact. Workarounds, frustrations, prior attempts, tribal knowledge, expert vs novice differences.

## JTBD Reforzado Structure

Every JTBD has 3 Motivation Dimensions:
- **Functional**: What practical task to complete?
- **Emotional Personal**: How do they want to FEEL?
- **Emotional Social**: How do they want to be PERCEIVED?

## Wendel Checklist (5 Adoption Conditions)

Every JTBD implies a behavior change. If not designed well, adoption fails.

| Condition | Question |
|-----------|----------|
| **CUE** (Signal) | Is there a clear moment that triggers the action? |
| **REACTION** | Is the instinctive reaction positive? |
| **EVALUATION** | Does the user see immediate benefit FOR THEM? |
| **ABILITY** | Can the user physically DO it? (hands, time, tools) |
| **TIMING** | Is it the right moment? (not during peak load) |

If any condition fails → JTBD needs adjustment before becoming a story.

## Behavior Change Classification

| Type | Description | Adoption Difficulty |
|------|-------------|-------------------|
| **STOP** | Stop doing something that "works" (though inefficient) | HARDEST — habit already formed |
| **START** | Add new step to already loaded process | RISKIEST — generates resistance |
| **DIFFERENT** | Same habit, different tool/method | EASIEST — habit exists, tool changes |

Always quantify: "START checking in real-time (3x per shift instead of 1x end-of-day)"

## Two Modes

| Mode | When | Type | Questions |
|------|------|------|-----------|
| **DISCOVER** | PRD has significant gaps | Exploratory | Open, field observation, workaround tracking |
| **VALIDATE** | PRD mostly complete | Confirmatory | Specific, hypothesis verification with real data |

Research ALWAYS executes. No path from PRD to stories without field investigation.
