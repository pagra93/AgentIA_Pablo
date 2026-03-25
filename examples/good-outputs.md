# Good Outputs

Examples of exemplary agent behavior for calibration.

---

## Example 1: Quality Guard — Risk Presentation (Non-blocking)

**Context**: PM submits a PRD with weak metrics section.

**Good output**:
```markdown
## Quality Guard Evaluation

### Dimension 1: Problem Completeness — 6/10
- Problem statement is clear and specific
- **Gap**: No baseline metrics defined. "Improve conversion" without a current number is unmeasurable.
- **Gap**: No evidence cited for the assumed user pain point

### Dimension 2: Process Quality — 8/10
- AS-IS flow is well documented
- TO-BE flow shows clear improvement
- Actors are identified

### Dimension 3: WHAT/HOW Separation — 9/10
- No solution contamination detected
- Requirements stay at the problem level

### Average: 7.7/10

### Risks
- **Risk**: Without baseline metrics, we cannot measure success. Impact: high.
  Recommendation: Add current conversion rate before defining target.

### Verdict
Ready to proceed with the noted gap. PM decides whether to define baselines first or continue to definition phase.
```

**Why this is good**:
- Scores each dimension separately with justification
- Identifies specific gaps, not vague concerns
- Presents risk as information with recommendation
- Ends with "PM decides" — never blocks

---

## Example 2: Story Writer — Behavior Change Story

**Context**: Converting a JTBD about onboarding into a user story.

**Good output**:
```markdown
## Story: First-time setup wizard

**As** a new team lead who just purchased the plan,
**I want** a guided setup that configures my team workspace in under 3 minutes,
**So that** I can invite my first team member before losing momentum.

### Behavior Change
- **START**: Following a 4-step wizard instead of exploring settings manually
- **STOP**: Abandoning setup halfway due to confusion about required fields
- **DIFFERENT**: Completing setup in 3 minutes instead of 15+ minutes of trial and error

### Acceptance Criteria
```gherkin
Given a new team lead on first login
When they start the setup wizard
Then they see step 1 of 4 with a progress indicator

Given the wizard is on step 3 (invite members)
When they enter an email and click invite
Then the invitation is sent and step 4 becomes available

Given all 4 steps are completed
When they click "Finish setup"
Then they land on their team dashboard with the invited member visible
```

### Dimensional Scoring
| Dimension | Score | Notes |
|-----------|-------|-------|
| JTBD Context | 8 | Clear job performer with specific trigger |
| User Specificity | 9 | "New team lead who just purchased" — not generic |
| Behavior Change | 8 | Clear START/STOP/DIFFERENT with quantification |
| Zone of Control | 9 | Fully within our product |
| Time Constraints | 7 | "3 minutes" is measurable but needs validation |
| Survivable Experiment | 8 | Low-risk, reversible, testable |
| **Average** | **8.2** | Ready for sprint |

### Size: S (1-2 days)
```

**Why this is good**:
- Specific job performer, not "as a user"
- Behavior change is quantified (3 min vs 15+ min)
- Acceptance criteria in Gherkin with concrete scenarios
- Each dimension scored with justification
- Size estimate included

---

## Example 3: Supervisor Agent — Proposal Without Imposition

**Context**: Optimizer detects recurring pattern across 3 sprints.

**Good output**:
```markdown
## Optimization Proposal #7

### Pattern Detected
In the last 3 review cycles, the Code Reviewer flagged missing error handling
in API endpoints (sprint 4: 3 instances, sprint 5: 2 instances, sprint 6: 4 instances).

### Proposed Improvement
Add a rule `rul-api-error-handling` that engineers consult when building API endpoints.
The rule would include a checklist: try/catch wrapper, consistent error response format,
logging with correlation ID, appropriate HTTP status codes.

### Expected Impact
- Reduce error handling review comments by ~70%
- Improve API consistency across endpoints

### Action Required
**PM decides**: Accept this proposal, modify it, or dismiss it.
This is a recommendation based on observed patterns, not a requirement.
```

**Why this is good**:
- Cites specific data (3 sprints, exact counts)
- Proposes concrete action (new rule file)
- Quantifies expected impact
- Explicitly states PM decides — supervisor never imposes
