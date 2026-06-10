# Compliance Directory

## What This Is For

This directory holds regulatory compliance artifacts for **regulated environments** (finance, healthcare, legal). The gitagent spec supports FINRA, SEC, Federal Reserve, and CFPB frameworks.

## For This Project

This PM Agent System is **not regulated** — it's a product management tool. The compliance directory exists for:

1. **Projects that need it**: When you use `/new-project` to initialize a regulated project, compliance artifacts go here.
2. **Future extensibility**: If this system is used in a regulated industry, add:
   - `regulatory-map.yaml` — Maps capabilities to regulatory rules
   - `validation-schedule.yaml` — Cadence for compliance reviews
   - `risk-assessment.md` — Risk tier justification
   - `audit-log.schema.json` — Audit log format

## Our Internal "Compliance"

Even without regulation, we have quality compliance:
- **Rules** (`rules/rul-*.md`) — Quality standards all agents must follow
- **QA Auditor** (`age-sup-auditor`) — Verifies compliance with our rules
- **QA Report** (`qa/qa-report.md`) — Append-only audit trail
- **Scoring** (`rul-scoring-dimensional`) — Objective quality measurement

This is self-imposed quality compliance, not regulatory compliance.
