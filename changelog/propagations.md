# Propagations Changelog

Log de operaciones del arquitecto sobre el ecosistema de paquetes y proyectos clientes.
Cada entrada documenta scope, archivos afectados, conflictos resueltos y outcomes.

Entradas en orden cronológico inverso (más reciente arriba).

---

## 2026-06-10T09:22:07Z — pmx — Comando /auto (orquestador gobernado del pipeline)

**Tipo**: comando nuevo de pmx (NO transversal, NO se propaga — orquesta el pipeline de producto)
**Iniciado por**: PM (quería autonomía "lanzo y se hace solo"; acordado: autonomía gobernada con gates)

**Cambio**:

- `exports/pmx-product/commands/auto.md` — **NUEVO**. Recorre el pipeline completo de punta a punta solo,
  parando en **3 gates** humanos:
  - **Paso 0**: detección de entrada (diseño Pencil → design-discovery+design-to-prd; problema → analyze+define; idea → story; ya hay stories → planning) + reanudación desde el estado actual.
  - **Paso 1** research/definición → **GATE 1 (Scope)**.
  - **Paso 2** planning (tech-architect lee architecture-map) → **GATE 2 (Arquitectura)**.
  - **Paso 3** build (sub-agente/story, commit atómico; para si `bloqueada`).
  - **Paso 4** review (test + code-review con seguridad + audit + evaluate + optimize + UPDATE del mapa) → **GATE 3 (Done/Merge)**.
- `exports/pmx-product/CLAUDE.md` — añadido `/auto` a la tabla (18→19 comandos).

**Gobernanza embebida**: `rul-fail-loud` en cada transición, mueve el kanban y aparca en el gate, respeta
`prompt_override`, **push siempre manual** (`/save`). Control de coste interactivo = los gates; tope duro real
= modo headless (`claude -p "/auto X" --max-budget-usd N --max-turns M`).

**Verificado**: 11/11 comandos, 18/18 agentes y 7/7 estados referenciados existen; 3 gates presentes.

**Decisión consciente**: NO fire-and-forget total (choca con la gobernanza); NO Agent Teams experimental
(el encadenamiento gobernado de comandos cubre el objetivo, estable). Futuro: modo `express` con menos gates.

**Outcome**: ✓ completed (sin probar en ejecución real sobre una feature todavía)

---

## 2026-06-10T07:00:52Z — propagator — Capa de seguridad: kno-security-review + code-reviewer

**Tipo**: knowledge nuevo (genérico propagable) + enriquecimiento del code-reviewer (pmx)
**Iniciado por**: PM (minado de la capa de seguridad de `affaan-m/ECC`; forma elegida: enriquecer el code-reviewer, no agente nuevo)

**Genérico propagado** (`to_packages.knowledge`, 3/3 [identical]):

- `knowledge/kno-security-review.md` — **NUEVO**. Metodología de revisión de seguridad a **nivel de cambio**: 8 clases de vulnerabilidad (inyección, authn/authz/IDOR, secretos, XSS, validación, SSRF, deserialización/config, dependencias), rúbrica de severidad (Crítica bloquea merge), red-team de juicio, y la regla de **no reinventar análisis estático** → recomendar la herramienta real (`npm audit`, `semgrep`, `gitleaks`…). Complementa (no duplica) el checklist a nivel de proyecto de `ski-unknown-unknowns/references/security.md`. Registrado en el manifest.

**Enriquecimiento pmx-específico** (NO propagado; el code-reviewer es agente de pmx, no del package-template):

- `exports/pmx-product/agents/age-spe-code-reviewer/agent.yaml` — añadidos `kno-security-review` y `rul-fail-loud` a `skills:`.
- `exports/pmx-product/agents/age-spe-code-reviewer/DUTIES.md` — nueva **pasada de seguridad dedicada**: reporta hallazgos por severidad con fix; Crítica (o Alta no aceptada) → REQUEST CHANGES; recomienda herramientas; declara qué clases revisó (no "es seguro" vacío, `rul-fail-loud`).

**Integración sin tocar pipelines**: como el code-reviewer ya corre en `/review` (Step 2) y `/code-review` (Step 1), la pasada de seguridad ocurre automáticamente donde él corre. No hizo falta añadir pasos al pipeline.

**Decisión de forma**: enriquecer el code-reviewer (no un `age-sup-security-reviewer` dedicado). Más ligero; la seguridad comparte la pasada con calidad/perf.

**Frente a ECC** (de donde salió la idea): tomamos la *metodología* + red-team, NO su escala (102 reglas de análisis estático propias, cross-harness). Respetamos `rul-model-vs-code`: el escaneo determinista es de herramientas externas, no del LLM.

**Pendiente / v1.1**: agente supervisor de seguridad dedicado + red-team adversarial multi-agente (varios escépticos por hallazgo Crítico), si el volumen lo justifica.

**Conflictos**: ninguno (todo nuevo).
**Reversibilidad**: borrar el knowledge (4 sitios) + revertir agent.yaml/DUTIES del code-reviewer + el manifest vía `git checkout`.
**Outcome**: ✓ completed

---

## 2026-06-10T06:19:26Z — generator+propagator — Mapa de Arquitectura (architecture-map) v1

**Tipo**: capacidad nueva (genérica propagable) + wiring pmx-específico
**Iniciado por**: PM (concepto "self-explaining repo": HTML para humanos + JSON para agentes)

**Genérico propagado** (`to_packages`, 9/9 [identical] en template + newsletter + pmx):

- `knowledge/kno-architecture-map-schema.md` — **NUEVO**. Schema canónico relacional (nodes+edges+data_flows+procedencia). Registrado en `core-manifest.yaml → to_packages.knowledge`.
- `skills/ski-architecture-map/SKILL.md` — **NUEVO**. API de 4 verbos: READ (antes de construir), UPDATE (tras feature, upsert idempotente desde Notas técnicas 6 capas + Usa/Crea), PROJECT (render HTML), BOOTSTRAP (mapa retroactivo opcional). Registrado en `to_packages.skills`.
- `skills/ski-architecture-map/render-map.py` — **NUEVO** (bundleado). Determinista: `validate` (invariantes: ids únicos, no edges colgantes, enums, procedencia) + `render` (JSON→HTML con mermaid: grafo `graph` + `erDiagram` + `sequenceDiagram`, tokens OKLch). Verificado: valida, detecta 5/5 errores, render idempotente.

**Sourcing**: agent-authored (normaliza artefactos existentes, NO escanea código). Respeta `rul-model-vs-code`.

**Wiring pmx-específico** (NO propagado por el arquitecto; llega a proyectos vía `pmx deploy.sh`):

- `exports/pmx-product/deploy.sh` — `ensure_file` idempotente del stub vacío `docs/general/architecture-map.json` (proyectos nuevos y existentes arrancan con mapa válido vacío).
- `exports/pmx-product/dashboard-template/` — sub-tab **"Arquitectura"** en el área Producto (mecanismo vivo de sub-tabs, NO el `dashboard-section.yaml` muerto): `bridge.py` (endpoint `GET /api/architecture`), `app.js` (`renderArquitectura()` con mermaid), `index.html` (sub-tab + CDN mermaid), `styles.css`. Endpoint verificado end-to-end (con mapa: 7 nodos; sin mapa: `_missing` + estado vacío). **Render visual mermaid NO verificado en navegador** (shell headless) — ruta de datos y estructura sí.
- `exports/pmx-product/agents/age-spe-tech-architect/DUTIES.md` — lee el mapa primero (READ) → extender, no duplicar.
- `exports/pmx-product/commands/review.md` — Step 4 (Auto Documentation): UPDATE del mapa + validate + render.

**Datos NO propagados** (locales por proyecto, como memory/ledger): `architecture-map.json/.html`.

**Generalidad**: fontanería genérica (schema/skill/render) en todos los paquetes; **población solo activa donde hay arquitectura de software** (pmx). La pestaña es de la sub-tab de Producto; newsletter no construye software → mapa vacío/irrelevante.

**Deuda registrada** (no abordada, decisión del PM): `docs/architect/tech-debt-dashboard.md` — divergencia `dashboard-section.yaml` (convención exigida por auditor) ↔ `pm/config.json > areas` (runtime), + entrada `dashboard_code` obsoleta en el manifest.

**Pendiente / v1.1**: bucle de corrección humana (eventos JSON desde el dashboard), drift-check por supervisores, grafos arrastrables (vis-network). Idea aparte anotada: companion visual para brainstorming (`obra/superpowers/visual-companion`).

**Conflictos**: ninguno (todo nuevo).
**Reversibilidad**: borrar kno+skill (3 destinos) + revertir manifest, deploy.sh, los 4 archivos del dashboard y los 2 docs de agente vía `git checkout`.
**Outcome**: ✓ completed (con la salvedad del render mermaid sin verificar en navegador)

---

## 2026-06-09T21:57:41Z — propagator — Reglas del "12-rule CLAUDE.md" (R5, R12, R7/R8/R10)

**Agente**: `age-spe-arc-propagator` (vía `/arc-propagate scope=rule --apply`)
**Tipo**: rule propagation (2 reglas nuevas + 1 editada)
**Iniciado por**: PM (adopción de gaps del artículo "12-rule CLAUDE.md", mayo 2026, tras mapear cobertura)

**Cambio propagado**:

- `rules/rul-model-vs-code.md` — **NUEVA** (Rule 5: modelo vs código; juicio del LLM solo para no-deterministas; versión meta agente-vs-script para el arquitecto). Registrada en `core-manifest.yaml`.
- `rules/rul-fail-loud.md` — **NUEVA** (Rule 12: superficiar incertidumbre; prohibido "completado" si algo se saltó/no se verificó; conecta con el `outcome` del ledger). Registrada en `core-manifest.yaml`.
- `rules/rul-llm-coding-discipline.md` — **EDITADA**: sección "Principios adicionales (mayo 2026)" con §5 Leer antes de escribir (Rule 8), §6 Exponer conflictos no promediar (Rule 7), §7 Checkpoint multi-paso (Rule 10); 3 filas nuevas en la tabla de antipatrones; sección Origen actualizada.

**Cobertura previa (no se duplicó)**:

- Rules 1-4 de Karpathy ya estaban al 100% en `rul-llm-coding-discipline` (core de 4, preservado sin renumerar).
- Rule 11 (convenciones) ya cubierta por `rul-naming-conventions`.
- Rule 6 (budgets numéricos) DESCARTADA (arbitraria; `rul-lazy-loading` + `ski-compression` + harness cubren la intención).
- Rule 9 (tests con intención) NO adoptada como regla: `kno-testing-strategy` ya existe en pmx; su falta de propagación es otra conversación.

**Destinos aplicados** (3 archivos × 3 destinos = 9, todos [identical] tras aplicar):

- `templates/package-template/rules/`
- `exports/newsletter-system/rules/`
- `exports/pmx-product/rules/`

**Conflictos**: ninguno. Las 2 reglas nuevas no existían en destinos. `rul-llm-coding-discipline.md` tenía la misma versión canónica antigua (hash `2e9bc5a0…`) en los 3 destinos → sin modificación local, sobrescritura limpia.

**Cambios en el arquitecto (fuente)**:

- `config/core-manifest.yaml` — `rul-model-vs-code.md` y `rul-fail-loud.md` añadidas a `to_packages.rules`.

**Reversibilidad**: `git checkout rules/<archivo>` en cada destino restaura la versión previa; borrar las 2 reglas nuevas y revertir el manifest deshace la adopción.

**Outcome**: ✓ completed

---

## 2026-06-09T21:30:52Z — propagator — `ski-context-ledger` v2 (índice + recuperación en 3 capas)

**Agente**: `age-spe-arc-propagator` (vía `/arc-propagate scope=skill skill=ski-context-ledger --apply`)
**Tipo**: skill propagation
**Iniciado por**: PM (adopción de ideas de claude-mem — índice compacto + hook SessionStart)

**Cambio propagado**:

- `skills/ski-context-ledger/SKILL.md` — nueva sección "Índice (`INDEX.md`)", paso 6 en la API (append al índice al escribir), "Cómo se consulta" reescrito como recuperación en 3 capas (índice → timeline → fetch detallado), sección de regeneración.
- `skills/ski-context-ledger/ledger-index.sh` — **NUEVO** script idempotente que regenera `INDEX.md` desde el frontmatter. Bundleado dentro de la carpeta de la skill para que viaje con ella (ruta relativa idéntica en arquitecto y paquetes).

**Destinos aplicados**:

- `templates/package-template/skills/ski-context-ledger/` → [identical] tras aplicar (actualización)
- `exports/newsletter-system/skills/ski-context-ledger/` → [identical] tras aplicar (actualización)
- `exports/pmx-product/skills/ski-context-ledger/` → **instalación nueva** (la skill no existía en pmx; el PM confirmó instalarla en la misma sesión). Índice de su `context-ledger/` (1 entrada) bootstrapeado.

**Datos NO propagados** (por `core-manifest.yaml` → `never_propagate`):

- `context-ledger/*` (entradas e `INDEX.md` de cada destino son locales). Los `INDEX.md` de `pmx-product` y `newsletter-system` se bootstrappearon localmente con el script durante la verificación.

**Cambios paralelos en el arquitecto (no propagables)**:

- `.claude/settings.json` — hook `SessionStart` → `scripts/load-context.sh` (carga MEMORY.md + índice del ledger + últimas propagaciones).
- `scripts/load-context.sh` — NUEVO, capa barata de arranque.
- `CLAUDE.md` — sección "Lectura recomendada al arrancar sesión" actualizada.

**Conflictos**: ninguno (ambos destinos tenían la versión canónica antigua, sin modificación local).

**Reversibilidad**: `git checkout <archivo>` en cada destino restaura la versión previa. El hook se desactiva borrando el bloque `SessionStart` de `.claude/settings.json`.

**Outcome**: ✓ completed

---

## 2026-05-15T10:15:00Z — generator — Creado paquete `newsletter-system`

**Agente**: `age-spe-arc-generator`
**Tipo**: package creation (no propagación)
**Iniciado por**: PM (Fase 13 del plan del arquitecto)

**Mini-discovery**:

| Pregunta | Respuesta |
|----------|-----------|
| Nombre | `newsletter-system` |
| Prefix | `news` |
| Dominio | `editorial-content` |
| Domain folder | `newsletter` |
| Propósito | Pipeline editorial para crear newsletters semanales |
| Etapas | research → outline → draft → edit → publish |
| Agentes (6) | topic-researcher, content-curator, outline-architect, editorial-writer, headline-architect, editor-in-chief |
| Outputs | Número de newsletter (.md y .html), métricas de envío |

**Archivos generados**:

- `exports/newsletter-system/` (paquete completo desde `templates/package-template/`)
- 60+ archivos materializados con placeholders sustituidos
- 6 stubs en `agents/age-spe-news-*/` (cada uno con SOUL + DUTIES + agent.yaml)
- 5 supervisores QA heredados (`age-sup-{auditor,evaluator,optimizer,cynic,boundary-walker}/`)
- 8 comandos genéricos heredados en `commands/`
- `install.sh` y `deploy.sh` parametrizados (prefix=news, domain_folder=newsletter)
- `dashboard-section.yaml` con pestaña configurada (tab_id: news, tab_label: editorial-content)
- `guia-de-uso.html` con tabla de stubs

**Acciones git**:

- `git init -b main` dentro del paquete
- Primer commit: `31ee57e feat: paquete newsletter-system generado por el arquitecto`

**Trazabilidad**:

- Context-ledger: `exports/newsletter-system/context-ledger/2026-05-15-101500-age-spe-arc-generator.md`
- `exports/README.md` actualizado por cataloger (manualmente en este caso, dado que el generator no tiene auto-invocación implementada todavía)

**Conflictos**: ninguno (paquete nuevo, sin colisión)

**Outcome**: ✓ completed

---

## (Entradas futuras se añadirán aquí, con timestamp ISO descendente)
