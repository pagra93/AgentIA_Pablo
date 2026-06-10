---
name: rul-model-vs-code
description: When deciding whether a step should be agent judgment or deterministic code. Use the LLM only for judgment calls (classify, draft, summarize, extract, design); use plain code/scripts for routing, retries, status-handling and deterministic transforms. Preloaded by package-building and architecture agents.
license: MIT
user-invocable: false
metadata:
  author: agent-architect
  version: "1.0.0"
  category: architecture
  source: "12-rule CLAUDE.md article (mayo 2026), Rule 5 — Use the model only for judgment calls"
  loaded-by: [age-spe-arc-generator, age-spe-arc-propagator, age-spe-tech-architect]
---

# Modelo vs Código

**El juicio del LLM es caro, no determinista y difícil de auditar. Úsalo solo donde de verdad hace falta.**

La línea es simple: **si el código puede responder la pregunta de forma determinista, responde el código.**
El modelo se reserva para lo que no es reducible a reglas.

---

## La decisión

### Usa el modelo (judgment) para:
- **Clasificar** texto ambiguo (sentiment, categoría, intención).
- **Redactar / resumir / reescribir** contenido.
- **Extraer** estructura de texto no estructurado.
- **Diseñar / proponer** opciones cuando hay criterio y tradeoffs.

### NO uses el modelo (lo resuelve el código) para:
- **Routing**: a qué handler va un mensaje según un campo conocido.
- **Retries / manejo de errores**: si un status code ya responde la pregunta, un `if` la responde.
- **Transformaciones deterministas**: formato de fechas, parseo, mapeos fijos, validación de esquema.
- **Cálculos**: nada que tenga una respuesta única y verificable.

> Regla mnemónica: *"Si un `if/else` lo decide igual de bien cada vez, no llames al modelo."*

---

## Por qué importa (los costes ocultos de meter el modelo donde no toca)

- **No determinismo**: la misma entrada puede dar decisiones distintas semana a semana. Un retry policy
  basado en un prompt es flaky por diseño.
- **Coste**: pagas tokens por algo que un `switch` hace gratis.
- **Auditabilidad**: un `if status == 503: retry` se lee en el diff; "el modelo decidió reintentar" no.
- **Superficie de fallo**: el modelo puede leer contexto irrelevante (p.ej. el body de la request) y
  cambiar una decisión que debería depender solo del status.

### Ejemplo

❌ **Bad** (modelo para una decisión determinista):
> Llamada al LLM con el prompt "¿Deberíamos reintentar esta petición que devolvió 503?".
> Funciona dos semanas, luego empieza a flakear porque el modelo lee el body como contexto.

✅ **Good** (el código responde):
```python
if response.status_code in RETRYABLE:   # {429, 502, 503, 504}
    retry(request)
```

---

## Versión meta: agente vs script (al construir paquetes)

Esta regla es **central para el arquitecto**. Al diseñar un paquete o un agente, la pregunta recurrente es:
*¿esto es judgment del agente o un paso determinista que debe ser un script?*

| Señal | Implementación | Ejemplo en este repo |
|---|---|---|
| Paso repetible, verificable, mismo output cada vez | **Script** (`scripts/`, `deploy.sh`, hook) | `skills/ski-context-ledger/ledger-index.sh` (regenera un índice desde frontmatter) |
| Requiere criterio, contexto o lenguaje natural | **Agente** | El generator decidiendo el `prefix` y el dominio de un paquete nuevo |
| Idempotente, sin ambigüedad | **Script** | `install.sh`, `deploy.sh` |
| Resuelve ambigüedad o redacta artefactos | **Agente** | El propagator decidiendo cómo resolver un conflicto de propagación |

### Test al diseñar un paso de un paquete
Pregúntate: *"¿Podría escribir esto como un script idempotente que pasa un test?"* Si la respuesta es sí,
**es un script** — no lo dejes como instrucción al agente. Reservar el agente baja coste, sube fiabilidad
y hace el sistema auditable.

❌ **Bad** (judgment para algo determinista):
> Una skill que instruye al agente: "lee todas las entradas del ledger, ordénalas por fecha y construye el índice".

✅ **Good** (script determinista + agente para lo que sí es juicio):
> `ledger-index.sh` construye el índice (determinista). El agente solo decide *qué* anotar en una entrada
> nueva del ledger (juicio sobre qué es significativo).

---

## Antipatrones detectables

| Antipatrón | Por qué está mal | Severidad |
|---|---|---|
| LLM para routing/retry/status-handling | No determinista y caro donde un `if` basta | High |
| LLM para transformaciones deterministas (parseo, formato, mapeo) | Reducible a código verificable | High |
| Paso de paquete dejado como instrucción al agente siendo idempotente | Debería ser un script (`scripts/`, hook) | Medium |
| "El modelo decide" sin criterio que requiera lenguaje natural | Esconde lógica en el prompt, no en el diff | Medium |

---

## Scope

### Aplica a
- `age-spe-arc-generator` (al diseñar los pasos de un paquete nuevo: agente vs script).
- `age-spe-arc-propagator` (al decidir qué propaga y qué automatiza un script).
- `age-spe-tech-architect` (al diseñar arquitectura: dónde entra un LLM y dónde no).
- Cualquier diseño de feature que considere meter una llamada al modelo.

### NO aplica a
- Tareas que son inherentemente de juicio (research, redacción, clasificación) — ahí el modelo es correcto.

---

## Origen

Rule 5 del artículo "12-rule CLAUDE.md" (mayo 2026), extendida con la versión meta agente-vs-script propia
del arquitecto. Relacionada con `rul-llm-coding-discipline` (simplicidad) y `rul-scope-boundaries`.
