# Project Registry
Last updated: -
Total assets: 0

## Reglas de Llenado

**Granularidad**: Una fila = un asset. Nunca agrupes múltiples funciones, endpoints o componentes en una sola fila, aunque compartan archivo. Si `contracts.ts` exporta 8 funciones, son 8 filas.

**Ortografía**: Aplica `rul-spanish-orthography` cuando el proyecto esté en español — acentos, ñ, ¿, ¡ en todas las descripciones. Ejemplo: "análisis", "energía", "configuración".

**Inventario puro**: Solo hechos, no decisiones. Nada de "> Decisión final se toma en /plan" ni comentarios editoriales. Para decisiones pendientes usa `docs/working-docs/[feature]/architecture.md` o un ADR.

**Categorías base obligatorias**: Las 6 categorías base (DB Models, API Endpoints, Shared Components, Services & Utilities, Types & Interfaces, External Integrations) NUNCA se eliminan — se dejan vacías si no aplican todavía.

**Categorías opcionales según stack**: Puedes añadir Hooks, Pages, Libs/Utils, Jobs, Middlewares según el stack del proyecto. Ver sección opcional al final del archivo.

## Quick Reference
<!-- SUMMARY -->
**DB**: (none yet)
**API**: (none yet)
**Components**: (none yet)
**Services**: (none yet)
**Types**: (none yet)
**Integrations**: (none yet)
<!-- /SUMMARY -->

## DB Models
<!-- CATEGORY:db -->
| Table | Key Fields | Relations | Feature | Story | Status |
|-------|-----------|-----------|---------|-------|--------|

## API Endpoints
<!-- CATEGORY:api -->
| Method | Path | Auth | Feature | Story | Status |
|--------|------|------|---------|-------|--------|

## Shared Components
<!-- CATEGORY:components -->
| Component | Path | Props/Interface | Feature | Story | Status |
|-----------|------|----------------|---------|-------|--------|

## Services & Utilities
<!-- CATEGORY:services -->
| Service | Path | Key Exports | Feature | Story | Status |
|---------|------|-------------|---------|-------|--------|

## Types & Interfaces
<!-- CATEGORY:types -->
| Type | Path | Key Fields | Feature | Story | Status |
|------|------|-----------|---------|-------|--------|

## External Integrations
<!-- CATEGORY:integrations -->
| Service | Purpose | Feature | Story | Status |
|---------|---------|---------|-------|--------|

<!-- ═══════════════ CATEGORÍAS OPCIONALES (añadir solo si el stack lo requiere) ═══════════════ -->

## (Opcional) Hooks — solo para proyectos React/Next.js
<!-- CATEGORY:hooks -->
| Hook | Path | Purpose | Feature | Story | Status |
|------|------|---------|---------|-------|--------|

## (Opcional) Pages — solo para proyectos Next.js con routing por archivo
<!-- CATEGORY:pages -->
| Route | File | Feature | Story | Status |
|-------|------|---------|-------|--------|

## (Opcional) Jobs — solo para proyectos con background workers
<!-- CATEGORY:jobs -->
| Job | Trigger | Purpose | Feature | Story | Status |
|-----|---------|---------|---------|-------|--------|
