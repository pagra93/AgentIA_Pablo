# Dossier: {{ENTITY_ID}} — {{FEATURE_TITLE}}

> Generated and maintained by `age-spe-pm-producto` (modo `dossier`).
> No edites manualmente entre marcadores `<!-- AUTO:section -->` y `<!-- /AUTO:section -->`.
> Last updated: {{LAST_UPDATED_ISO}}

---

## 📍 Estado actual

<!-- AUTO:status -->
- **Status**: _(inferido por el PM)_
- **Sprint**: _(si está en sprint activo)_
- **Stories**: _(N done / M total · progress bar)_
- **Score Quality Guard**: _(si /analyze ejecutado)_
- **Score Evaluator (último review)**: _(si /review ejecutado)_
- **Última actividad**: _(timestamp + agente)_
<!-- /AUTO:status -->

---

## 💡 Idea original

<!-- AUTO:idea -->
> _Pegada literalmente del `inbox.md` o creada manualmente. Preservada palabra por palabra._

— Origen: _(comando)_ · _(timestamp)_ · por _(autor)_
<!-- /AUTO:idea -->

---

## 🎯 Challenge

<!-- AUTO:challenge -->
_(Solo si `/challenge idea` fue ejecutado para esta feature)_

> Hallazgos clave en 3 líneas.

- **Asunción crítica detectada**: _(si la hubo)_
- **Brief completo**: [challenge-brief.md](challenge-brief.md)

— Añadido por: `/challenge` · _(timestamp)_
<!-- /AUTO:challenge -->

---

## 🔬 Análisis

<!-- AUTO:analyze -->
_(Solo si `/analyze` fue ejecutado)_

- **Quality Guard score**: _(X/10)_ · razón principal
- **Decisión humana**: _("proceder con riesgo" / "corregir gaps" / "abandonar")_
- **Hipótesis no validadas**: _(N marcadas `[HIPOTESIS]`)_
- **Research brief**: [research.md](research.md)

— Añadido por: `/analyze` · _(timestamp)_
<!-- /AUTO:analyze -->

---

## 📋 Definición (JTBDs + Stories)

<!-- AUTO:define -->
_(Solo si `/define` o `/design-to-prd` fue ejecutado)_

- **JTBDs**: _(N generados con títulos)_
- **Stories**: _(M creadas, listadas con IDs + título + status actual)_

| ID | Título | Status | Days est. |
|----|--------|--------|-----------|
| HU-XXX | ... | ... | ... |

- **Issues del quality-coach**: _(si hubo)_
- **Splits del story-splitter**: _(stories originales → divididas)_
- **Detalles**: [jtbds.md](jtbds.md) · [stories.md](stories.md)

— Añadido por: `/define` o `/design-to-prd` · _(timestamp)_
<!-- /AUTO:define -->

---

## 🏗 Arquitectura

<!-- AUTO:architecture -->
_(Solo si `/plan` fue ejecutado)_

- **Decisión arquitectural clave**: _(1-2 líneas — qué se decidió y por qué)_
- **ADRs generados**: _(lista de decisiones tomadas)_
- **Wiki concept page**: _(si fue promovida vía `/wiki ingestar`)_
- **Detalles**: [architecture.md](architecture.md)

— Añadido por: `/plan` · _(timestamp)_
<!-- /AUTO:architecture -->

---

## 🏃 Sprint

<!-- AUTO:sprint -->
_(Solo si `/plan` ejecutó sprint-planner)_

- **Orden de ejecución**: _(ordenado por dependencias)_
- **Días estimados**: _(N)_
- **Plan completo**: [../../sprint.md](../../sprint.md)

— Añadido por: `/plan` · _(timestamp)_
<!-- /AUTO:sprint -->

---

## 🔨 Build

<!-- AUTO:build -->
_(Solo si `/build` está en curso o ha completado historias)_

- **HU actual en build**: _(si activo)_
- **Completadas**:
  | HU | Commit | Estado |
  |----|--------|--------|
  | HU-XXX | abc123 | Done |

- **Notas del sub-agente** (assumptions + tech debt detectada):
  - HU-XXX · _(asunción)_ · _(pendiente confirmar)_
  - HU-XXX · _(tech debt)_ · _(propuesta de fix en commit separado)_

— Actualizado por: `/build` · _(timestamp)_
<!-- /AUTO:build -->

---

## ✅ Review

<!-- AUTO:review -->
_(Solo si `/review` ha ejecutado)_

- **Tests**: _(pass/fail · N tests · coverage X%)_
- **Code reviewer issues**: _(severidad + breve)_
- **Stub scan**: _(clean / N stubs)_
- **Verify must-haves**: _(stories PASS / FAIL con detalle)_
- **Evaluator score (4D)**:
  - Completeness: X/10
  - Quality: X/10
  - Compliance: X/10
  - Efficiency: X/10
  - **Total**: X/10
- **Optimizer patterns detectados**: _(si hubo)_
- **Detalles**: [../../qa.md](../../qa.md)

— Añadido por: `/review` · _(timestamp)_
<!-- /AUTO:review -->

---

## 📚 Aprendizajes

<!-- AUTO:lessons -->
_(Capturas vía `/learned` relacionadas a esta feature)_

- _(fecha · categoría · título · link a lessons.md)_

<!-- /AUTO:lessons -->

---

## 🗂 Decisiones críticas tomadas

<!-- AUTO:decisions -->
_(Solo decisiones loggables: scores Quality Guard <7, tech debt aceptada, overrides de quality-coach, abandono, rejection de stories)_

- _(timestamp)_ — _(quién)_ — _(qué se decidió y por qué)_

<!-- /AUTO:decisions -->

---

## 📎 Artefactos relacionados

<!-- AUTO:artifacts -->
- `_events.jsonl` — timeline cronológico completo
- _(links a wiki concepts si fueron promovidos)_
- _(link a project-registry filtrado por esta feature)_
- _(link a lessons relacionadas)_
<!-- /AUTO:artifacts -->

---

## 📝 Notas del usuario

<!-- USER:notes -->
_Esta sección está fuera de los marcadores AUTO. Pablo puede editarla libremente — el PM nunca la sobrescribe._

_(Notas personales, contexto adicional, decisiones informales, recordatorios)_
<!-- /USER:notes -->
