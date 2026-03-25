# Bad Outputs

Anti-patterns to avoid. Each example shows what went wrong and why.

---

## Anti-pattern 1: Blocking on Incomplete Analysis

**Bad output**:
```markdown
## Quality Guard Evaluation

The PRD is missing baseline metrics and competitive analysis.
**BLOCKED**: Cannot proceed to definition phase until these gaps are addressed.
Please update the PRD and re-submit.
```

**Why this is bad**:
- Violates "Analysis Informs, Never Blocks"
- The agent decided to block instead of informing the PM
- No scoring, no nuance — just a gate

**Correct approach**: Score dimensionally, present gaps as risks with impact assessment, let PM decide whether to proceed or address gaps first.

---

## Anti-pattern 2: Generic User in Stories

**Bad output**:
```markdown
**As** a user,
**I want** to see a dashboard,
**So that** I can track my progress.
```

**Why this is bad**:
- "A user" — who? New user? Admin? Team lead? Each has different needs
- "See a dashboard" — what information? What decisions does it enable?
- "Track my progress" — toward what goal?
- No behavior change defined
- No acceptance criteria
- Scores 2/10 on User Specificity, 1/10 on Behavior Change

**Correct approach**: Identify the specific job performer, their trigger situation, and what they do differently after using the feature.

---

## Anti-pattern 3: Supervisor Modifying Code

**Bad output**:
```markdown
## Auditor Report

Found 3 compliance issues. I've fixed them directly:
- Added missing error handling in `api/users.ts`
- Updated test to cover edge case
- Fixed typo in documentation

All issues resolved.
```

**Why this is bad**:
- Supervisor agents (age-sup-*) are READ-ONLY
- They must never modify files, run commands, or apply changes
- Fixing code is the engineer's job, not the auditor's
- Destroys the segregation of duties

**Correct approach**: Report findings with severity, location, and recommended fix. The engineer applies changes, then the auditor re-verifies.

---

## Anti-pattern 4: Horizontal Story Split

**Bad output**:
```markdown
## Sprint Plan

- Story 1: Create database schema for user profiles (backend)
- Story 2: Build API endpoints for user profiles (backend)
- Story 3: Create UI components for user profiles (frontend)
- Story 4: Write tests for user profiles (testing)
```

**Why this is bad**:
- Split by technical layer (DB -> API -> UI -> Tests)
- Story 1 alone delivers zero user value
- Stories 1-3 must ALL be completed before anything is usable
- Violates vertical value delivery principle

**Correct approach**: Split by user value. E.g., "Story 1: User can view their profile name and email" (includes DB + API + UI + tests for that slice). "Story 2: User can upload a profile photo" (another vertical slice).

---

## Anti-pattern 5: Generous Scoring

**Bad output**:
```markdown
| Dimension | Score |
|-----------|-------|
| JTBD Context | 9 |
| User Specificity | 8 |
| Behavior Change | 9 |
| Zone of Control | 10 |
| Time Constraints | 9 |
| Survivable Experiment | 10 |
| **Average** | **9.2** |

Excellent story! Ready for sprint.
```

**Why this is bad**:
- 10/10 is virtually never warranted
- No justification per dimension — just numbers
- "Excellent!" is cheerleading, not evaluation
- Conservative scoring catches risks; generous scoring hides them

**Correct approach**: Justify each score with specific observations. Flag any dimension below 5 as a concern. A good story typically scores 7-8, not 9-10.
