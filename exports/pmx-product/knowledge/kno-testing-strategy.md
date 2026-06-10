---
name: kno-testing-strategy
description: "Testing Trophy strategy, test types, data patterns, coverage, regression, anti-patterns, TDD guidance. Complete methodology for generating and validating tests. Preloaded by test-engineer agent."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: methodology
  source: "Kent C. Dodds (Testing Trophy), Guillermo Rauch, Martin Fowler, Qodo Cover patterns"
  loaded-by: [age-spe-test-engineer]
---

# Testing Strategy

## The Testing Trophy (Default Strategy)

"Write tests. Not too many. Mostly integration." — Guillermo Rauch

The Testing Pyramid (lots of unit tests, few E2E) was designed for an era of slow machines and primitive tooling. Modern frameworks make integration tests nearly as fast as unit tests, and TypeScript + ESLint replace much of what unit tests used to catch.

```
            ┌─────────┐
            │   E2E   │  10-20 critical flows max
          ┌─┴─────────┴─┐
          │ Integration  │  THE BULK (50-60% of test effort)
        ┌─┴─────────────┴─┐
        │     Unit        │  Complex logic only (10-15%)
      ┌─┴─────────────────┴─┐
      │  Static Analysis     │  TypeScript + ESLint (always on, free)
      └──────────────────────┘
```

**Why the Trophy wins**: Unit tests are tightly coupled to implementation — they break when you refactor, even if behavior is unchanged. Integration tests test real behavior from the outside without being brittle.

**When the Pyramid still applies**: Library code with no UI. Pure algorithmic code (parsers, data transformers, financial calculations). Backend-only services with complex internal logic. In these cases, unit tests are king.

---

## Test Types: When to Use Each

| Type | What It Tests | When to Write | Do NOT Use For |
|------|---------------|---------------|----------------|
| **Static** | Type errors, syntax, imports | Always on (TypeScript + ESLint) | Logic verification |
| **Unit** | Pure functions, calculations, state machines, data transformers | Complex logic with clear input/output contract | Components, API calls, DOM interactions |
| **Integration** | Multi-component interactions, API contracts, user interactions with real services | Multi-module behavior, API endpoints, component user flows | Isolated utility functions |
| **E2E** | Critical user journeys end-to-end | Top 10-20 flows (login, purchase, core workflow) | Individual components, edge cases |

### Mapping Acceptance Criteria to Test Types

Each **Given-When-Then** from the story maps to a test type:

- Given-When-Then with **pure logic** (calculations, validations, transformations) → **Unit test**
- Given-When-Then with **multiple components or services** (form submits to API, API writes to DB) → **Integration test**
- Given-When-Then that describes a **complete user journey** through multiple screens → **E2E test** (only if it's a critical flow)
- Given-When-Then about **type safety or format validation** → Verify **static analysis** handles it (no explicit test needed)

**Rule**: One acceptance criterion may generate 1-3 tests of different types. But most criteria map to exactly ONE integration test.

---

## Test Structure: AAA Pattern

Every test follows **Arrange-Act-Assert**:

```
Arrange: Set up the test data and preconditions
Act:     Execute the behavior being tested
Assert:  Verify the expected outcome
```

### Naming Convention

Test names should read as sentences that describe behavior:

```
GOOD: "creates order and returns 201 when cart has valid items"
GOOD: "shows error message when email is invalid"
GOOD: "redirects to login when session expires"

BAD:  "test order"
BAD:  "should work"
BAD:  "handles edge case"
```

### One Concept Per Test

Multiple `expect` calls are fine if they test the **same concept**. But don't test unrelated behaviors in one test — split them.

```
GOOD: One test checks "order created" + "order has correct total"  (same concept)
BAD:  One test checks "order created" + "email notification sent"  (two concepts)
```

---

## Test Data Strategy

### Factory Pattern Over Static Fixtures

Factories compose. Static fixture files (`testData.json`) don't — they become outdated as schemas change, and they hide the relationship between test data and test intent.

```
GOOD (factory):
  createUser({ role: "admin" })           <- clear what matters for THIS test
  createOrder({ items: 3, total: 99.50 }) <- explicit test-relevant data

BAD (static fixture):
  import userFixture from './fixtures/user.json'  <- what fields matter? unclear
```

### Mocking Strategy

- **Mock external third-party services ALWAYS** (Stripe, Twilio, SendGrid) — slow, costly, not your responsibility
- **Mock at the network layer** (MSW / Mock Service Worker), not at the module level — tests more real code
- **Do NOT mock your own database in integration tests** — use a real test database with transaction rollback
- **Do NOT over-mock** — if your test has more mocks than assertions, you're testing the mocks, not the code

### Test Isolation

- Each test sets up and tears down its own data
- No shared mutable state between tests
- Tests must run in any order and produce the same result
- Database: use transactions that rollback after each test (faster than truncation)

---

## Coverage: Branch Coverage on Business Logic

### What Matters

**80% branch coverage on business logic**. Not global line coverage — that's a vanity metric that incentivizes garbage tests.

Coverage is a **discovery tool**: it tells you what you DIDN'T test. It does NOT tell you that what you DID test is correct.

### What to Cover

- Payment processing, authorization, data validation: target **90%+**
- API endpoint contracts (happy path + one error path): catches **80% of real production bugs**
- Every exported public function/endpoint: **at least one test**

### What NOT to Cover

- Generated code, migrations, config files, constants
- UI layout code (CSS, styling, JSX structure)
- Trivial getters/setters with no logic
- Third-party library wrappers with no custom logic
- Snapshot tests inflating numbers (near-zero real coverage value)

### The Right Metric

"% of user-impacting behaviors covered" > "% of lines executed"

A codebase with 60% line coverage but 100% coverage of checkout and auth flows is safer than one with 90% line coverage and tests that only check JSX renders.

---

## Regression Strategy: Tiered CI

### On Every PR Commit (fast, <5 min)
- Full unit + component test suite
- Integration tests for changed modules only
- Smoke E2E test (login + main user flow, 3-5 tests)
- Static analysis (type check + lint)

### On Merge to Main
- Full integration suite
- Critical path E2E suite (top 10-20 flows)

### Nightly / Weekly
- Full E2E regression suite
- Performance regression tests (if applicable)

### During /review (Test Engineer)
- **ALWAYS run full test suite** — not just new tests
- Every acceptance criterion must have at least one test
- Coverage comparison: before vs after

### Bug Fix Regression Rule
**Every bug fix gets a regression test before merging.** Write a test that reproduces the bug FIRST. This is non-negotiable — it prevents the same bug from ever returning.

---

## Anti-Patterns: What NOT to Do

| Anti-Pattern | Why It's Bad | What to Do Instead |
|---|---|---|
| **render-without-crash** | Tests nothing useful. Zero confidence gained. | Test user interactions and outcomes. |
| **Testing CSS/styles** | Breaks on any styling change. Extremely brittle. | Test behavior, not appearance. Use visual regression tools for UI. |
| **Over-mocking** | Test becomes a mirror of implementation. Passes when code is broken. | Mock only external boundaries. Use real services internally. |
| **Snapshot abuse** | Developers approve without reading. False confidence. | Use targeted assertions on specific values. |
| **Testing implementation details** | Breaks on refactor even when behavior is unchanged. Wastes time. | Test the public API/contract. Ask: "Would this break if I refactored internals?" |
| **Flaky tests** | Train engineers to ignore red CI. Worse than no test. | Fix immediately or delete. No tolerance for intermittent failures. |
| **Shared mutable test state** | Tests pass alone, fail together. Order-dependent nightmare. | Each test creates its own data. Rollback after each test. |
| **Testing library internals** | React Router, Redux, etc. have their own tests. | Test YOUR code that uses the library, not the library itself. |

---

## TDD Guidance

### When to Write Tests FIRST (TDD)

- **Business logic** with clear input/output contracts (pricing, validation, state machines)
- **Bug fixes** — write a failing test that reproduces the bug, then fix it (regression test for free)
- **API contracts** — define expected request/response first
- **Complex algorithms** where requirements are stable

### When to Write Tests AFTER (Implementation-First)

- **UI components** — props and DOM output change too much during initial design
- **Prototypes and spikes** — you may throw the code away
- **Simple CRUD** with no logic
- **Integrations** with third-party services where you're learning the API

### The Practical Rule

"If you can describe the behavior before writing the code, TDD. If you're discovering the behavior as you build, implementation-first, then test."

---

## E2E Strategy

### Keep It Small

10-20 critical flows **maximum**. Each E2E test must map to a real user journey:

- Login / authentication flow
- Core purchase / conversion flow
- Main CRUD operations
- Payment processing
- Critical error recovery paths

### Do NOT Use E2E For

- Individual component testing (use integration tests)
- Edge cases (use unit tests)
- API contract verification (use integration tests)
- Layout verification (use visual regression tools)

### Flaky E2E Prevention

- No arbitrary waits/sleeps — use proper `waitFor` patterns
- Use stable selectors: `data-testid` > role > text > CSS class
- Isolate test data — each E2E test gets its own user/data
- Run in headless mode for CI, headed for debugging
- Retry on infrastructure failures only (network timeout), NOT on assertion failures

### Framework Recommendation

**Playwright** for new projects (cross-browser, free parallelism, multi-language).
Keep **Cypress** if it's already working (superior interactive debugger).

---

## When NOT to Test

Do NOT generate garbage tests for coverage vanity:

- **Trivial getters/setters** — no logic, no risk
- **Framework boilerplate** — routing config, module declarations
- **CSS-only changes** — use visual tools, not code assertions
- **Auto-generated code** — migrations, GraphQL types, Prisma client
- **Config files** — environment variables, constants
- **Tests that mirror implementation** — if the test is just a restatement of the code with no independent logic, it catches nothing

**The Staff Engineer Test**: "Would a Staff Engineer look at this test and say 'this catches real bugs'?" If no, don't write it.
