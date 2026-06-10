---
name: ski-impeccable-guide
description: >
  Guia de cuando y como usar Impeccable (herramienta externa de design quality)
  dentro del flujo PM x10. Mapea cada comando de Impeccable al momento correcto
  del pipeline. Requiere Impeccable instalado: npx skills add pbakaus/impeccable
license: MIT
allowed-tools: Read
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: design-quality
  external-dependency: "Impeccable by Paul Bakaus (https://impeccable.style/)"
  install: "npx skills add pbakaus/impeccable"
---

# Impeccable Guide — Design Quality in the PM x10 Pipeline

## What is Impeccable?

Impeccable is an EXTERNAL tool (not part of this system) that gives AI professional design vocabulary. It transforms "make this look better" into specific, actionable design improvements.

**Install**: `npx skills add pbakaus/impeccable`
**Web**: https://impeccable.style/

## When to Use Each Command

### During /build (after implementing UI)

| Command | When | What it does |
|---------|------|-------------|
| `/impeccable:frontend-design` | Building a new UI component or page from scratch | Generates production-grade frontend with high design quality |
| `/impeccable:polish` | UI is functional but feels unfinished | Final pass: alignment, spacing, consistency, details |

### After /build (before /review)

| Command | When | What it does |
|---------|------|-------------|
| `/impeccable:audit` | Want a comprehensive check before review | Evaluates accessibility, performance, theming, responsive. Detailed report with severity ratings. |
| `/impeccable:critique` | Want UX feedback | Assesses visual hierarchy, information architecture, emotional resonance. Actionable feedback. |

### When Design Needs Adjustment

| Command | When | What it does |
|---------|------|-------------|
| `/impeccable:bolder` | Design is too safe, boring, generic | Amplifies visual impact while maintaining usability |
| `/impeccable:quieter` | Design is too aggressive, visually loud | Tones down intensity while maintaining quality |
| `/impeccable:distill` | Design is too complex, cluttered | Strips to essence. Less is more. |
| `/impeccable:colorize` | Design is too monochromatic, lacks life | Adds strategic color. Makes interfaces expressive. |

### For Specific Improvements

| Command | When | What it does |
|---------|------|-------------|
| `/impeccable:animate` | UI feels static, needs life | Adds purposeful animations and micro-interactions |
| `/impeccable:adapt` | Need responsive across devices | Adapts for mobile/tablet/desktop/different contexts |
| `/impeccable:clarify` | Labels, errors, copy are unclear | Improves microcopy, error messages, instructions |
| `/impeccable:harden` | Need robustness for edge cases | Error handling, i18n, text overflow, edge cases |
| `/impeccable:delight` | UI is functional but forgettable | Adds personality, joy, memorable touches |
| `/impeccable:onboard` | First-time user experience is weak | Improves onboarding flows, empty states, first-run |

### For Design System Work

| Command | When | What it does |
|---------|------|-------------|
| `/impeccable:extract` | Want to consolidate reusable patterns | Extracts components, tokens, patterns into design system |
| `/impeccable:normalize` | Inconsistencies across the UI | Normalizes to match design system |

### For Optimization

| Command | When | What it does |
|---------|------|-------------|
| `/impeccable:optimize` | UI is slow, heavy, janky | Improves loading, rendering, animations, images, bundle size |

### One-Time Setup

| Command | When | What it does |
|---------|------|-------------|
| `/impeccable:teach-impeccable` | First time in a project | Gathers design context, saves to .impeccable.md for future reference |

## Recommended Flow in PM x10

```
/build                          ← Implement stories
  └─ If building NEW UI:
     /impeccable:frontend-design  ← Generate with design quality from start

  └─ If UI exists but needs work:
     /impeccable:polish           ← Final refinement pass

Before /review:
  /impeccable:audit               ← Comprehensive design check
  /impeccable:critique            ← UX feedback

  (Fix issues found, then proceed to /review)
```

## Mapping to PM x10 Phases

| PM x10 Phase | Impeccable Commands | Why |
|--------------|-------------------|-----|
| /design-to-prd | None | Analyzing designs, not creating them |
| /define | None | Working with stories, not UI |
| /plan | None | Architecture, not design |
| /build (frontend) | frontend-design, polish | Build with quality from start |
| Pre-/review | audit, critique | Verify design quality before QA |
| After feedback | bolder/quieter/distill/colorize | Adjust based on critique |
| Accessibility | audit, harden, adapt | Ensure WCAG, responsive, edge cases |
| Design system | extract, normalize | Consolidate patterns |

## Important Notes

1. Impeccable is OPTIONAL — /build works fine without it
2. Only relevant for FRONTEND work — backend/API stories don't need it
3. Install once: `npx skills add pbakaus/impeccable` — then commands are available
4. Creates `.impeccable.md` in your project for persistent design context
5. Does NOT replace a real designer — but elevates AI-generated UI significantly
