---
description: "Auditar conformidad de paquetes contra la convención canónica (config/conventions.yaml). Read-only, no modifica. Detecta drift de estructura y de archivos core. Ejecuta age-sup-arc-auditor."
---

# /arc-audit — Auditar conformidad de paquetes

Verifica que cada paquete en `exports/` cumple la convención canónica definida en `config/conventions.yaml`. Reporta drift: archivos requeridos faltantes, archivos core divergentes respecto al template, archivos extra inesperados, violaciones de `rul-scope-boundaries`.

**Tipo de operación**: read-only. NO modifica nada. Solo reporta.

## Sintaxis

```
/arc-audit                        → audita todos los paquetes en exports/
/arc-audit <paquete>              → audita solo ese paquete
/arc-audit --since=<commit>       → solo paquetes con cambios desde ese commit
/arc-audit --scope=convention     → solo verifica conformidad estructural (no core-files)
/arc-audit --scope=core           → solo verifica core-files contra template (no estructura)
/arc-audit --scope=boundaries     → solo verifica violaciones de rul-scope-boundaries
/arc-audit --report=<path>        → guarda reporte en path concreto
```

## Qué verifica

### 1. Conformidad estructural (default)

Lee `config/conventions.yaml` y para cada paquete comprueba:

- **Archivos requeridos presentes**: `CLAUDE.md`, `SOUL.md`, `DUTIES.md`, `RULES.md`, `agent.yaml`, `install.sh`, `deploy.sh`, `dashboard-section.yaml`, `system-overview.md`, `README.md`
- **Carpetas requeridas presentes**: `agents/`, `commands/`, `skills/`, `rules/`, `knowledge/`, `memory/`, `context-ledger/`
- **Supervisores QA mínimos**: el paquete tiene los 5 supervisores canónicos (`age-sup-auditor`, `age-sup-evaluator`, `age-sup-optimizer`, `age-sup-cynic`, `age-sup-boundary-walker`)

### 2. Core-files contra template

Lee `config/core-manifest.yaml` y por cada archivo listado:

- Compara checksum del archivo en el paquete vs su versión canónica en `templates/package-template/`
- Marca como `OK` si idéntico, `DRIFT` si divergente
- Para `DRIFT`: indica si parece intencional (carpeta con muchos cambios coherentes) o accidental (cambio aislado)

### 3. Violaciones de scope boundaries

Busca señales de que el paquete viola `rul-scope-boundaries`:

- Referencias en `DUTIES.md`/`SOUL.md` de agentes del paquete a paths bajo OTROS paquetes
- Lógica que mencione dominios ajenos (heurística por palabras clave)
- Imports/lecturas cross-paquete

### 4. Salud del paquete

- ¿Tiene `git log` reciente? (paquete vivo vs abandonado)
- ¿Tiene `context-ledger/` con entradas? (uso activo vs solo creado y olvidado)
- ¿Tiene README útil o solo placeholder?
- ¿Su `version` en `agent.yaml` evoluciona o sigue en `0.1.0`?

## Output del auditor

Reporte por paquete (en `docs/architect/audits/<fecha>-<paquete-o-all>.md`):

```markdown
# Audit Report — <paquete> — 2026-05-14

## Resumen
- ✅ Conformidad estructural: OK
- ⚠️  Core-files: 2 archivos con drift (ver detalle)
- ✅ Scope boundaries: sin violaciones detectadas
- ✅ Salud: paquete vivo (último commit hace 3 días, ledger activo)

## Detalle drift core-files

### `skills/ski-plan-mode/SKILL.md` — DRIFT
- Checksum local: `abc123`
- Checksum template: `def456`
- Diff: 12 líneas modificadas localmente
- Hipótesis: cambios intencionales del paquete (NO marca como necesidad de propagación inversa)
- Recomendación: documentar la divergencia en `exports/<paquete>/context-ledger/`

### `commands/save.md` — DRIFT
- ...

## Recomendaciones al PM
1. Decidir si los drifts son intencionales o accidentales
2. Si accidentales: ejecutar `/arc-propagate skill --to=<paquete>` para alinear
3. Si intencionales: documentar la divergencia (auditor no la flageará en runs futuros si está documentada)
```

Si auditamos todos los paquetes, también se genera un **reporte global** con tabla resumen.

## Reglas

- **READ-ONLY**: el auditor nunca modifica archivos. Las recomendaciones son para que el PM decida.
- **No flagea drift documentado**: si `exports/<paquete>/context-ledger/` tiene una entrada que documenta la divergencia como intencional, el auditor lo respeta (con cita de la entrada).
- **Heurístico, no exhaustivo**: el auditor detecta lo evidente. No reemplaza una revisión manual del PM en cambios delicados.

## Cuándo invocar

- **Periódicamente** (sugerencia: semanal, o tras una sesión de cambios grandes)
- **Antes de una propagación** (`/arc-audit` → `/arc-propagate`)
- **Después de crear un paquete** (`/arc-new-package` → `/arc-audit <nuevo>`) para verificar que nació conforme
- **Cuando se sospecha drift** ("este paquete está raro, audítalo")

## Limitaciones

- **No audita proyectos clientes**, solo paquetes (`exports/*/`). Auditar proyectos clientes sería violación de scope (cada proyecto cliente es soberano).
- **No verifica funcionalidad**, solo conformidad estructural. Un paquete puede pasar la auditoría y no funcionar — eso lo detectan los tests de cada paquete, no el arquitecto.
- **No detecta drift sutil**: cambios semánticos en código que mantienen estructura no se detectan. Requiere `/arc-aggregate` o revisión manual.
