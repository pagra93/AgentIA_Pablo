---
name: ski-project-docs
description: >
  Generates and maintains complete project documentation for humans.
  Creates/updates docs/project-docs/ with mission, features, architecture,
  API reference, and how-it-works guides. Designed to be exportable to a
  docs site (Docusaurus, Nextra, GitBook, etc.).
  Trigger: /docs, 'document feature', 'update docs', 'generate documentation'.
license: MIT
allowed-tools: Read Write Edit Glob Grep Bash
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: documentation
  loaded-by: [standalone, age-sup-optimizer]
---

# Project Documentation Generator

## Purpose

Generate and maintain complete, detailed project documentation that:
- Lives in `docs/project-docs/` inside the project
- Is written for HUMANS (developers, stakeholders, future you)
- Is NOT loaded by Claude every session (too heavy)
- Is structured for future export to a docs site (Docusaurus, Nextra, GitBook)
- Gets updated incrementally — each /docs call adds/updates, never rewrites everything

## Important: This is NOT PROJECT_KNOWLEDGE.md

| | PROJECT_KNOWLEDGE.md | docs/project-docs/ |
|---|---|---|
| **For** | Claude (AI context) | Humans (developers, stakeholders) |
| **Size** | Max ~200 lines | Unlimited |
| **Loaded** | Every session | Only when asked |
| **Detail** | Concise summaries | Full explanations, examples, screenshots |
| **Updated by** | ski-doc-updater (auto) | ski-project-docs (manual: /docs) |

## Documentation Structure

When initializing docs for the first time, create this structure:

```
docs/project-docs/
├── index.md                    # Home: what is this project, quick links
├── overview/
│   ├── mission-vision.md       # Mission, vision, objectives
│   ├── target-audience.md      # Who is this for
│   └── roadmap.md              # What's planned, what's done
├── features/
│   ├── _index.md               # Feature list with status
│   └── [feature-name].md       # One file per feature (detailed)
├── architecture/
│   ├── overview.md             # High-level architecture
│   ├── tech-stack.md           # Stack decisions and why
│   ├── data-model.md           # Database schema, relationships
│   └── decisions/              # ADRs (linked from /plan)
├── guides/
│   ├── getting-started.md      # How to set up and run
│   ├── development.md          # How to develop (conventions, patterns)
│   └── deployment.md           # How to deploy
├── api/
│   ├── _index.md               # API overview
│   └── [endpoint-group].md     # Endpoint documentation
└── changelog.md                # Version history
```

## Modes of Operation

### Mode 1: Initialize (`/docs init`)
Creates the full structure from scratch. Interviews the user:
1. What is this project? (1-2 sentences)
2. What problem does it solve?
3. Who is the target audience?
4. What's the mission/vision?
5. What tech stack and why?

Then generates: index.md, mission-vision.md, target-audience.md, tech-stack.md, getting-started.md.

### Mode 2: Document Feature (`/docs [feature-name]`)
After completing a feature (triggered manually or by /review Step 6).

**First, reads ALL working docs** from `docs/working-docs/[feature-name]/`:
- `design-analysis.md` — UI, DB, API, Logic, Integrations, Edge Cases (from /design-to-prd)
- `prd.md` — Problem definition (from /design-to-prd or /analyze)
- `research.md` — Mom Test findings, gap analysis (from /analyze)
- `jtbds.md` — Jobs-to-be-Done with 8 elements, Wendel, behavior change (from /define)
- `stories.md` — User stories with 6D scoring (from /define)
- `architecture.md` — ADRs, components, data flow (from /plan)

**Then reads the actual implementation** (code, tests, configs).

**Generates** `docs/project-docs/features/[feature-name].md` with:
   - What it does (user-facing description — from PRD + stories)
   - How it works (technical — from design-analysis + architecture + code)
   - How to use it (with examples — from acceptance criteria)
   - API endpoints (from design-analysis API layer)
   - Data model (from design-analysis DB layer)
   - Configuration options (if any)
   - Known limitations (from edge cases + stories)
   - Related features
   - Evidence trail (links to working-docs)
3. Updates `docs/project-docs/features/_index.md` with the new feature
4. Updates `docs/project-docs/changelog.md`

### Mode 3: Update Architecture (`/docs architecture`)
After /plan or architectural changes:
1. Reads current architecture docs, ADRs, CLAUDE.md
2. Updates architecture/overview.md and data-model.md
3. Links new ADRs from architecture/decisions/

### Mode 4: Generate API Docs (`/docs api`)
For projects with APIs:
1. Scans route files, controllers, endpoints
2. Generates per-group documentation with request/response examples
3. Updates api/_index.md

### Mode 5: Full Refresh (`/docs refresh`)
Re-scans the entire project and updates all docs:
1. Reads all code, tests, configs
2. Updates every section that's out of date
3. Flags sections that might be stale

## Feature Documentation Template

```markdown
# [Feature Name]

> [One-line description]

## What It Does

[User-facing description. What can the user do with this feature?
Write as if explaining to someone who's never seen the project.]

## How It Works

[Technical explanation. Architecture, data flow, key components.
Include diagrams if helpful (mermaid syntax).]

### Key Components
- `path/to/file.ts` — [what it does]
- `path/to/other.ts` — [what it does]

## How to Use

[Step-by-step usage with examples]

### Example
```code
[Concrete code example or UI interaction]
```

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| [option] | [value] | [what it controls] |

## Known Limitations

- [Limitation 1]
- [Limitation 2]

## Related Features

- [Link to related feature]
```

## Output Rules

1. Write for humans, not AI. Full sentences, examples, context.
2. Each feature = one file. Never cram multiple features in one doc.
3. Include code examples wherever possible.
4. Link between docs (relative links: `../architecture/overview.md`).
5. Use mermaid diagrams for architecture and data flow.
6. Update _index.md files when adding new content.
7. Never delete existing docs — update or mark as deprecated.
8. Changelog uses format: `## [Date] — [Feature/Change]`

## Future Export

This structure is designed to be exportable to:
- **Docusaurus**: Each .md becomes a page, _index.md becomes category
- **Nextra**: Same structure works directly
- **GitBook**: Import the docs/project-docs/ folder
- **Custom site**: Parse markdown files with any static site generator

The _index.md files serve as category pages / navigation.
