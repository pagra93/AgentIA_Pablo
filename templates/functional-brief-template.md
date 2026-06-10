---
type: functional-brief
created_at: <ISO 8601 UTC>
created_by: age-spe-design-discoverer
design_source: <path>.pen
features_covered: []        # lista de slugs en kebab-case
n_questions: 0
n_supuestos_pendientes: 0
n_decisiones_delegadas: 0
status: ready               # ready | partial | draft
---

# Functional Brief — <nombre del proyecto / feature set>

> Capturado vía `/design-discovery` el <fecha legible>.
>
> Esta información alimenta a `/design-to-prd`: las stories que se generen
> después marcarán `[VALIDADO via functional-brief]` las secciones con
> respaldo aquí, en vez de `[DERIVADO]`.

---

## Resumen ejecutivo
<!-- AUTO:resumen -->

- **Features detectadas**: N
- **Features cubiertas en esta sesión**: M
- **Reglas de negocio capturadas**: X
- **Validaciones específicas**: Y
- **Edge cases conscientes**: Z
- ⚠️ **Supuestos pendientes**: W _(revisar antes de `/plan`)_
- ⚠️ **Decisiones delegadas al dev**: P _(red flag para arquitectura)_

<!-- /AUTO:resumen -->

---

## Feature: <slug-1>
<!-- AUTO:feature-<slug-1> -->

### Pantallas implicadas
- Pantalla A (`<frame_id>`)
- Pantalla B (`<frame_id>`)

### Reglas de negocio
1. **<nombre corto de la regla>** — Cuando X entonces Y, porque Z.
   - Fuente: pantalla A, elemento "<botón / campo / lista>"
   - Técnica aplicada: Socratic / 5-whys / Pre-mortem / Devil's Advocate / Red-team / Reverse Assumption
2. ...

### Validaciones específicas
- **Campo `<nombre>`**: <regla de validación>. Momento (onBlur/onChange/onSubmit). Mensaje "<texto>" en posición <inline/toast/modal>.
- **Botón `<label>`**: se habilita cuando <condición compuesta>.
- ...

### Flujos condicionales
- Si `<condición>` → <comportamiento>.
- Si `<rol == admin>` → muestra/oculta <elemento>.
- Si `<estado del recurso>` → permite/bloquea <acción>.
- ...

### Integraciones específicas
- **<servicio>**: <decisión tomada en sesión>. <límites/costes si aplican>.
- ⚠️ **<integración pendiente>**: opciones consideradas (A / B), criterio para decidir, fecha objetivo.

### Cálculos y derivaciones
- **<valor que aparece en pantalla>** = <fórmula o regla>. Redondeo: <cómo>. Moneda/unidad: <cuál>.
- ...

### Edge cases conscientes
- **<situación>**: <comportamiento decidido>. ✅ resuelto / ⚠️ pendiente.
- Concurrencia en <recurso>: <estrategia>. ✅ / ⚠️.
- Idempotencia en <operación>: <mecanismo>. ✅ / ⚠️.
- Timeouts / reintentos: <política>. ✅ / ⚠️.

### Supuestos pendientes ⚠️
1. **<asunto>** — el PM no supo responder. Acción: <revisar con stakeholder X> / <validar con datos>.
2. ...

### Decisiones delegadas al dev ⚠️
1. **<aspecto>** — "como lo haga el dev". Riesgo: <impacto en arquitectura/UX/costes>.

### Aspectos NO capturados
- (Lista de temas que se decidió saltar o que se quedaron fuera por timeout. No son ⚠️ porque son conscientes.)

<!-- /AUTO:feature-<slug-1> -->

---

## Feature: <slug-2>
<!-- AUTO:feature-<slug-2> -->

_(misma estructura que feature anterior)_

<!-- /AUTO:feature-<slug-2> -->

---

## 📝 Notas del usuario
<!-- USER:notes -->
_(vacío — Pablo escribe aquí; los agentes nunca tocan esta sección)_
<!-- /USER:notes -->
