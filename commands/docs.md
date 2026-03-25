---
description: "Generate or update project documentation. Modes: init, feature, architecture, api, refresh. Creates docs for humans, exportable to docs sites."
---

# /docs — Project Documentation Generator

Generates and maintains complete project documentation in `docs/project-docs/`.

## Usage

```
/docs                     # Shows available modes
/docs init                # First time: create full structure + interview
/docs [feature-name]      # Document a specific feature after building it
/docs architecture        # Update architecture docs after /plan
/docs api                 # Generate/update API documentation
/docs refresh             # Re-scan entire project, update everything
```

## Modes

### /docs init — First Time Setup
Interviews you about the project and creates the documentation structure:

1. Ask: What is this project? Who is it for? Mission/vision? Tech stack?
2. Create `docs/project-docs/` with: index.md, overview/, features/, architecture/, guides/, api/, changelog.md
3. Generate initial content from your answers

Use this ONCE per project, after `/new-project`.

### /docs [feature-name] — Document a Feature
After completing and reviewing a feature:

1. Read the implementation (code, tests, stories from tasks/todo.md)
2. Create `docs/project-docs/features/[feature-name].md` with:
   - What it does (user-facing)
   - How it works (technical)
   - How to use it (examples)
   - Configuration, limitations, related features
3. Update features/_index.md and changelog.md

Use this after `/review` for each major feature.

### /docs architecture — Update Architecture
After `/plan` or major architectural changes:

1. Read ADRs, CLAUDE.md, current architecture docs
2. Update overview.md, data-model.md, tech-stack.md
3. Link new ADRs

### /docs api — API Documentation
For projects with APIs:

1. Scan route files and controllers
2. Generate endpoint docs with request/response examples
3. Group by resource/domain

### /docs refresh — Full Update
Re-scan everything and update stale docs:

1. Read all code, tests, configs
2. Compare with existing docs
3. Update what's changed, flag what's stale

## Where It Writes

```
docs/project-docs/           # Full documentation (for humans)
docs/PROJECT_KNOWLEDGE.md    # NOT touched (that's ski-doc-updater's job)
```

## When to Use

| Situation | Command |
|-----------|---------|
| New project just initialized | `/docs init` |
| Just finished a feature + /review | `/docs user-authentication` |
| Just ran /plan with new architecture | `/docs architecture` |
| Built new API endpoints | `/docs api` |
| Returning after weeks, docs feel stale | `/docs refresh` |
| Want to export to docs site | Just copy docs/project-docs/ |

## Typical Flow

```
/new-project          # Initialize project
/docs init            # Create documentation structure

/analyze → /define → /plan
/docs architecture    # Document the architecture

/build → /review
/docs user-auth       # Document the feature you just built
/docs payments        # Document the next feature

# Months later...
/docs refresh         # Update everything
```

## Important

This is NOT the same as PROJECT_KNOWLEDGE.md:
- **PROJECT_KNOWLEDGE.md** = Claude's quick reference (always loaded, concise)
- **docs/project-docs/** = Full human documentation (loaded only when asked, detailed)

Both are useful. They don't duplicate each other.
