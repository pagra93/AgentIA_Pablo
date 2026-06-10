---
name: kno-story-splitting
description: "Story splitting methodology: exponential risk, 6 linguistic indicators, 9 heuristics, 4 validation criteria, decision table. Based on Eduardo Ferro (@eferro). Preloaded by story-splitter agent."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "2.0.0"
  category: methodology
  source: "Eduardo Ferro (@eferro) — https://www.eferro.net/"
  loaded-by: [age-spe-story-splitter, age-spe-story-builder]
---

# Story Splitting (Eduardo Ferro / @eferro)

## The Core Problem: Exponential Risk

Risk does NOT grow linearly with size. It grows exponentially. A story that's 2x bigger doesn't have 2x risk — it has 4x to 10x risk. This is not theoretical. It shows up consistently in failed deploys, sprint-spanning stories, and retros.

**Why**: A story of ≤3 days is a **survivable experiment**. If it fails, the team reverts quickly. The cost of learning is low. But a 2+ week story is NOT survivable. If it fails, the investment is too large. Teams don't revert — they accept a mediocre result. Uncertainty grows. Risk expands.

This is why the hard limit is **3 days**. Not because of some arbitrary rule, but because it's the boundary between a survivable experiment and an all-or-nothing bet.

---

## Step 1: Linguistic Detection (6 Categories of Red Flags)

Before applying any heuristic, **scan the story text** for these 6 categories of words that signal hidden complexity. The excessive size of a story almost always announces itself — not through line count, but through language.

### Category 1: Coordinating Conjunctions
**Words**: "y", "ademas de", "and", "as well as"
**Signal**: Two or more independent actions hidden in one story.
**Example**: "Los usuarios pueden **subir y descargar** archivos" = 2 stories. Upload is a completely different flow from download — different interfaces, different error cases, different success criteria.

### Category 2: Action Connectors
**Words**: "gestionar", "administrar", "procesar", "manejar", "manage", "handle"
**Signal**: Full CRUD operations hidden behind a single verb.
**Example**: "Gestionar usuarios" = create + read + update + delete = potentially 4 stories. Each is a different flow with different validation rules.

### Category 3: Sequence Connectors
**Words**: "antes", "despues", "luego", "entonces", "before", "after", "then"
**Signal**: Separable steps grouped together that could be delivered independently.
**Example**: "Antes de pagar, el usuario revisa su pedido y luego confirma" — each step can be built and deployed independently.

### Category 4: Scope Indicators
**Words**: "incluyendo", "ademas", "tambien", "including", "also", "plus"
**Signal**: Feature creep — someone added one more feature to an already complete story.
**Example**: "Cancelar pedidos, **incluyendo** reembolso automatico y notificacion" — the base cancellation and each addition are separate stories.

### Category 5: Optionality Indicators
**Words**: "o bien", "opcionalmente", "alternativamente", "optionally", "alternatively"
**Signal**: Multiple optional paths that should be separate stories.
**Example**: "El usuario puede pagar con tarjeta, **o bien** con PayPal, **opcionalmente** con transferencia" — each payment method is a story.

### Category 6: Exception Indicators
**Words**: "excepto", "a menos que", "sin embargo", "en caso de", "except", "unless", "however"
**Signal**: Develop and deploy the base case first (80% of value), add exceptions in later stories. Exceptions are where most bugs hide.
**Example**: "Procesar pedidos, **excepto** cuando el stock es insuficiente" — the happy path first, exception handling second.

---

## Step 2: Apply Heuristics (The 9 from Eduardo Ferro)

### Heuristic 1: Start by Outputs
Deliver the minimum VISIBLE output to the user first.

**When to use**: The story has many features or multiple outputs.
**Example**: Building a report → first plain text summary, then details, then CSV export. Each can be validated, deployed, and used independently.
**Pattern**: Output A (simple) → Output B (detailed) → Output C (formatted)

### Heuristic 2: Narrow the Segment
Deliver complete functionality for the SMALLEST possible group.

**When to use**: The story applies to "all users" or multiple user types.
**Example**: Feature for "all users" → first only for store employees. This dramatically reduces complexity.
**Pattern**: Segment A (smallest) → Segment B (next) → Segment C (all)

### Heuristic 3: Extract Basic Utility
The MVP is the minimum. Beauty comes later.

**When to use**: The core is simple but surrounded by extras.
**Example**: Batch cancellation → first upload a list of IDs. Second adds filters. Third adds validation. Each delivers value and each is small.
**Pattern**: Core utility → Enhancement 1 → Enhancement 2

### Heuristic 4: Dummy to Dynamic
Static data first, real data later.

**When to use**: There's architectural complexity AND data complexity mixed together.
**Example**: Dashboard → first with hardcoded data. Second connects to real source. Third adds auto-refresh. Separates the architectural problem from the data problem.
**Pattern**: Hardcoded → Real data → Real-time

### Heuristic 5: Simplify Outputs
Simpler formats first, richer formats later.

**When to use**: The story has rich output formats.
**Example**: Report generation → first CSV. Second generates PDF. Third auto-sends by email. Complexity grows predictably.
**Pattern**: Simple format → Rich format → Automated delivery

### Heuristic 6: Split by Capability
Each CRUD operation is a separate story.

**When to use**: Story contains "manage", "administer", or CRUD-like operations.
**Example**: "Manage users" → Create users, Edit users, Delete users, Assign roles. Each is a complete, deployable story.
**Pattern**: Create → Read → Update → Delete (each independently valuable)

### Heuristic 7: Split by Example
Each concrete use case becomes a separate story.

**When to use**: Many acceptance criteria or many examples in one story.
**Example**: Post-cancellation communication → email to web users, SMS to mobile users, support tickets. Each is a complete end-to-end flow.
**Pattern**: Example A (full flow) → Example B (full flow) → Example C (full flow)

### Heuristic 8: Learning vs Earning
Separate research from delivery. They are different types of work.

**When to use**: High technical uncertainty (ML, new technology, unknown performance).
**Example**: ML recommendations → spike research (3 days max, answers one specific question). Then simple rule-based version. Then, maybe 3 sprints later, the ML model. Mixing research and delivery almost always makes both worse.
**Pattern**: Spike (≤3 days, answers a question) → Simple version → Advanced version

### Heuristic 9: Put It on Crutches
Deliver with manual steps or simpler backends first.

**When to use**: Full automation is expensive but partial value can be delivered with manual workarounds.
**Example**: Inventory sync → first upload CSV manually and process changes. Second is a semi-automatic script. Third is full automatic sync. Each is a valuable story the business can use.
**Pattern**: Manual → Semi-automated → Fully automated

---

## Decision Table: Linguistic Indicator → Heuristic

| Linguistic Indicator | Recommended Heuristic |
|---------------------|----------------------|
| "gestionar", "administrar", "manage" | #6 Split by Capability or #1 Start by Outputs |
| "y" + distinct actions | Split by conjunction — each action = story |
| "para todos los usuarios", "for all users" | #2 Narrow the Segment |
| "incluyendo", "ademas", "tambien" | #1 Start by Outputs (base first, additions later) |
| "opcionalmente", "o bien", "alternativamente" | Extract as separate story |
| "excepto", "a menos que", "sin embargo" | Base case first, exceptions as later stories |
| "antes", "despues", "luego" | Evaluate if each step is independently deliverable |
| High technical uncertainty | #8 Learning vs Earning |
| Complex automation | #9 Put It on Crutches |
| Many output formats | #5 Simplify Outputs |
| Many user types | #2 Narrow the Segment |
| Rich UI/output requirements | #5 Simplify Outputs |

---

## 4 Validation Criteria (Non-Negotiable)

Every proposed split MUST pass ALL four. If any fails, the split is not valid.

### 1. Independently Valuable
The user or business can obtain value from this story completed alone, WITHOUT needing the other stories that were split from the original.

### 2. Separately Deployable
If you completed it, you can deploy it to production WITHOUT deploying the other stories.

### 3. Completable in ≤3 Days
This is Eduardo Ferro's line. If it takes more than 3 days, it carries exponential risk. No exceptions.

### 4. End-to-End Value
It is NOT an "infrastructure component." It is a complete capability the user can exercise. It crosses ALL layers (UI + logic + data).

---

## CRITICAL: Always Vertical, Never Horizontal

A **horizontal** split separates by technical layer: "Implement API endpoint", "Implement business logic", "Implement UI." This SEEMS logical from a technical perspective. But it's a trap. None of these "stories" delivers value on its own. They regroup at release time. You're back to one big story.

The correct way is **vertical**. Every story crosses ALL technology layers and delivers complete end-to-end value:
- "Users can create an order with basic data" crosses UI, API, business logic, database. And delivers value.

**Test**: If your "story" can't be demonstrated to a user, it's horizontal. Rewrite it.

---

## Practical Example

**Original story**: "Gestionar usuarios del sistema, incluyendo creacion, actualizacion y eliminacion, ademas de reseteo de contrasenas, con soporte para roles y permisos, opcionalmente con autenticacion de dos factores."

**Indicators detected**:
- "gestionar" → Category 2 (Action Connector) → suggests #6 Split by Capability
- "y" (creacion, actualizacion y eliminacion) → Category 1 (Conjunction) → split by action
- "incluyendo" → Category 4 (Scope) → base first, additions later
- "ademas de" → Category 4 (Scope) → separate feature
- "opcionalmente" → Category 5 (Optionality) → extract as separate story

**Result — 7 vertical stories**:

| # | Story | Size | Heuristic |
|---|-------|------|-----------|
| 1 | Admin users can create local users with name, email, initial password | 3 days | #6 Capability (Create) |
| 2 | Admin users can edit email and name of existing users | 2 days | #6 Capability (Update) |
| 3 | Admin users can delete users | 2 days | #6 Capability (Delete) |
| 4 | Admin users can assign roles (admin/editor/viewer). Permissions apply based on roles | 3 days | #1 Start by Outputs |
| 5 | Users can reset their own password via email link | 3 days | #7 Split by Example |
| 6 | Research spike: Two-factor authentication options | 3 days | #8 Learning vs Earning |
| 7 | Users can optionally configure 2FA with SMS (after spike) | 3 days | #8 → delivery |

7 small stories instead of 1 giant. The team completes the first in 2 days, gets feedback. By end of week 2, they've delivered 4 fully functional stories — 70% of the value.

---

## Choosing the Right Heuristic (Quick Reference)

| Situation | Best Heuristic |
|-----------|---------------|
| Many features/outputs | #1 Start by Outputs |
| Many user types | #2 Narrow Segment |
| Complex but simple core | #3 Extract Basic Utility |
| Complex logic + data | #4 Dummy to Dynamic |
| Rich UI/output formats | #5 Simplify Outputs |
| CRUD-like operations | #6 Split by Capability |
| Many acceptance criteria | #7 Split by Example |
| High uncertainty | #8 Learning vs Earning |
| Needs automation | #9 Put It on Crutches |
