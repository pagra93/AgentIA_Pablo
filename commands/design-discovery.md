---
description: "Discovery funcional sobre diseños de Pencil. Genera un cuestionario funcional batch completo (todas las preguntas a la vez, numeradas, citando pantalla y elemento, con técnica aplicada) para capturar lógica de negocio, validaciones, edge cases y reglas que el diseño no muestra. El PM responde todo del tirón. Output: Functional Brief que /design-to-prd lee como contexto."
---

# /design-discovery — Discovery Funcional sobre Diseño

## Pre-flight: leer `prompt_override` de épicas afectadas

Antes de invocar el agente sobre features que ya tienen épicas en `pm/tasks.json`:

1. Localiza épicas con `feature: <slug>` que coincidan con features del diseño.
2. Lee el campo `prompt_override` de cada una. Si existe y no está vacío, **inclúyelo como contexto adicional explícito** en el mensaje al sub-agente: «Contexto adicional del usuario para la épica X: <prompt_override>».
3. El sub-agente ya conoce la regla universal (`rul-prompt-override` precargado) y la respetará — no preguntará lo ya cerrado.
4. Si no hay épicas previas o no hay `prompt_override`, procede normal.

---

## Qué hace

Captura la **lógica funcional** que el diseño no muestra por sí solo: reglas de negocio, validaciones específicas, flujos condicionales por rol/estado, cálculos implícitos, integraciones, edge cases conscientes.

El agente `age-spe-design-discoverer`:

1. Lee el diseño en Pencil (mismas MCP tools que `/design-to-prd`).
2. Identifica internamente puntos ciegos funcionales en 6 categorías (acciones ambiguas, estados intermedios, validaciones, visibilidad/permisos, cálculos, edge cases).
3. **Genera un cuestionario batch completo** — TODAS las preguntas en un único mensaje, numeradas (`P1`, `P2`, ...), agrupadas por feature, ordenadas por criticidad (arq → UX → polish). Cada pregunta cita pantalla y elemento concreto y lleva entre corchetes la técnica aplicada (Socratic / 5-whys / Pre-mortem / Devil's Advocate / Reverse Assumption / Red-team). **Una pregunta = un punto ciego detectado: si hay 23 dudas, hay 23 preguntas.**
4. Tú respondes en uno o varios mensajes, referenciando por número. Respuestas válidas:
   - Respuesta con detalle → se captura como regla/validación/edge case
   - `"no sé"` → ⚠️ supuesto pendiente
   - `"como lo haga el dev"` → ⚠️ decisión delegada (red flag para arquitectura)
   - `"skip"` → aspecto NO capturado (consciente)
5. Si alguna respuesta queda **radicalmente ambigua** (no se entiende), el agente hace **una única ronda corta** de clarificaciones puntuales. Si todas son claras, salta al brief directamente.
6. Resume hallazgos y pide confirmación final (A/B/C) antes de escribir.
7. Genera **un único archivo**: `docs/producto/functional-brief.md`.

**No genera stories ni PRD.** Eso es trabajo de `/design-to-prd`.

**Diseño del cuestionario** — sin resúmenes ni atajos:
- Si hay 23 puntos ciegos detectados, hay 23 preguntas (no agrupadas en 8).
- Si el PM dice "como siempre" sin contexto, queda como ambigua y entra en la ronda de clarificaciones.
- El agente NO insiste en preguntas que el PM no quiso responder.

## Cómo usarlo

```
/design-discovery                      # Analiza el .pen abierto en Pencil
/design-discovery [path/to/file.pen]   # Analiza un archivo específico
```

## Cuándo usarlo

- **Recomendado**: justo después de tener el diseño listo en Pencil, **antes** de `/design-to-prd`.
- **Especialmente útil** cuando el dominio tiene mucha lógica de negocio que no aparece en el visual (permisos por rol, cálculos derivados, integraciones externas con reglas específicas).
- **Opcional**: si tu diseño es trivial y el dominio bien conocido, puedes saltarlo y `/design-to-prd` seguirá funcionando como siempre (todo `[DERIVADO]`).

## Flujo recomendado

```
Diseño en Pencil
      ↓
/design-discovery          ← captura intención funcional del PM
      ↓
/design-to-prd             ← lee el brief y genera stories [VALIDADO] donde aplica
      ↓
/plan  |  /analyze + /define
```

## Output

Único archivo: `docs/producto/functional-brief.md`.

Estructura por feature (usa template `templates/functional-brief-template.md` con marcadores `<!-- AUTO:section -->`):
- **Reglas de negocio** capturadas (cuando X entonces Y porque Z, con fuente y técnica aplicada)
- **Validaciones específicas** (campo a campo, cuándo se ejecutan, mensajes)
- **Flujos condicionales** (por rol, estado, plan)
- **Integraciones específicas** (servicios externos decididos)
- **Edge cases conscientes** (red, concurrencia, idempotencia)
- ⚠️ **Supuestos pendientes** (lo que no supiste responder — revisar antes de `/plan`)
- ⚠️ **Decisiones delegadas al dev** (red flag para arquitectura)
- **Aspectos NO capturados** (gaps conscientes)

Frontmatter YAML con `created_at`, `design_source`, `features_covered`, `n_questions`, `n_supuestos_pendientes`, `n_decisiones_delegadas`, `status`.

## Re-runs (si el brief ya existe)

Si `docs/producto/functional-brief.md` ya existe, el agente ofrece:

- **(A) Reutilizar**: no preguntar nada, dar por bueno el brief actual.
- **(B) Reemplazar**: descartar el actual y empezar de cero.
- **(C) Ampliar feature por feature**: cargar el brief en memoria, identificar features sin cobertura, y entrevistar solo sobre esas.

Por defecto el agente **NO sobrescribe sin confirmación**. Si cancelas en cualquier punto, no queda ningún archivo nuevo en disco (idempotencia).

## Integración con `/design-to-prd`

`/design-to-prd` detecta automáticamente `docs/producto/functional-brief.md` en su Paso 0.5. Si existe:

- Lo lee completo como contexto adicional.
- Las secciones de Notas Técnicas (Lógica, Validaciones, Integraciones, Edge Cases) y JTBD que tienen respaldo en el brief se marcan **`[VALIDADO via functional-brief]`** en vez de `[DERIVADO]`.
- Las secciones sin cobertura del brief siguen marcadas `[DERIVADO]` como ahora.

Si no existe, `/design-to-prd` se comporta exactamente como hoy (sin errores, sin bloqueos).

## Importante

- **Cuestionario batch completo** — todas las preguntas en un único mensaje, numeradas. Tú respondes del tirón.
- **Una pregunta = un punto ciego detectado** — sin resumir ni fusionar dudas distintas.
- **Cita pantalla + elemento concreto en cada pregunta** — las preguntas son específicas, no genéricas.
- **Respuestas `"no sé"` / `"como lo haga el dev"` / `"skip"` son válidas y finales** — el agente no insiste.
- **Una sola ronda de clarificaciones, solo si hay respuestas ininteligibles** — si todas son claras, va directo al brief.
- **Idempotencia ante cancelación** — si paras a mitad, no queda rastro.
- **No sustituye al diseño** — el brief lo complementa con la lógica que el visual no muestra.
- **No genera código ni arquitectura** — solo captura intención funcional.

---

## Auto-sync con PM (último paso, automático)

Tras escribir el brief, ejecuta **age-spe-pm-producto** en modo `sync`:

- Lee filesystem y registra el artefacto nuevo.
- No crea épicas ni HUs (eso es trabajo de `/design-to-prd`).
- Output silent salvo reporte breve si detecta drift.

**Por qué**: el dashboard refleja que hay un brief vivo para alimentar a `/design-to-prd`.
