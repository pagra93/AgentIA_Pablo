# Deuda técnica — Dashboard: dos mecanismos de pestañas divergentes

> Registrada: 2026-06-10. Estado: **abierta, no reconciliar ahora** (decisión del PM). Se documenta para no perderla.

## Resumen

El dashboard de proyectos clientes tiene **dos mecanismos de pestañas que dejaron de hablarse**:

- **Capa de spec/convención (declarativa):** cada paquete trae un `dashboard-section.yaml` que declara su
  pestaña (`tab_id`, `tab_label`, `sections`). El arquitecto lo trata como **archivo canónico requerido**.
- **Capa de runtime (efectiva):** `exports/pmx-product/dashboard-template/bridge.py` **ignora** ese yaml y
  construye las pestañas del sidebar desde `pm/config.json > areas`. Cada `deploy.sh` rellena ese `areas`
  **hardcodeando el área inline** (newsletter lo hace así), sin leer `dashboard-section.yaml`.

Es decir: el diseño original probablemente era *"`dashboard-section.yaml` → `deploy.sh` lo lee → escribe el
área en `config.json`"*, pero la implementación derivó y el paso intermedio nunca se cableó. El yaml quedó
como una declaración que **nadie consume en runtime**, pero que **la auditoría sí exige**.

## Dónde está enraizado `dashboard-section.yaml` (por eso NO es un simple borrado)

- `config/conventions.yaml` — lo lista como archivo canónico requerido + campos mínimos.
- `config/core-manifest.yaml` — en `never_propagate`.
- `agents/age-spe-arc-generator/` (SOUL + DUTIES) — lo **genera** en cada paquete nuevo.
- `agents/age-sup-arc-auditor/SOUL.md` + `commands/arc-audit.md` — lo **requieren** (su ausencia = drift).
- `agents/age-spe-arc-propagator/` + `rules/rul-scope-boundaries.md` (root y template) — referencian
  `dashboard/sections/*.yaml` como config local a preservar.
- `commands/arc-deploy.md`, `commands/arc-new-package.md` — lo referencian.

Borrar los `dashboard-section.yaml` sin tocar todo lo anterior haría que **todos los paquetes fallaran la
auditoría** (les faltaría un archivo canónico). Por eso "limpiar" es una reconciliación real, no un borrado.

## Problema adicional relacionado

`config/core-manifest.yaml → to_client_projects.dashboard_code` apunta a
`templates/project-template/dashboard/{bridge.py,index.html,styles.css,app.js}` — rutas **borradas** el
2026-05-25 (el dashboard se movió a `exports/pmx-product/dashboard-template/`). La entrada está **obsoleta**:
`/arc-propagate scope=dashboard` no encontraría esos archivos. La propagación real del dashboard a proyectos
clientes hoy ocurre vía `deploy.sh`/`update-dashboards.sh` de pmx, no vía el manifest.

## Opciones de reconciliación (cuando se aborde)

1. **Cablearlo (spec = verdad):** `deploy.sh` lee `dashboard-section.yaml` y de ahí escribe el área en
   `pm/config.json`. El yaml pasa a ser fuente única como se pretendía. Coherente, trabajo medio.
2. **Retirar la convención (runtime = verdad):** quitar `dashboard-section.yaml` de
   conventions/manifest/generator/auditor y estandarizar en `pm/config.json > areas`. Refactor mayor.

En cualquier caso, arreglar también la entrada `dashboard_code` obsoleta del manifest (repuntar a
`exports/pmx-product/dashboard-template/*` o retirarla).

## Por qué no se reconcilia ahora

Decisión del PM (2026-06-10): priorizar el **mapa de arquitectura**, que se integra por el mecanismo de
runtime (`areas`/sub-tabs) **independientemente** de esta deuda. La reconciliación es una tarea separada.
