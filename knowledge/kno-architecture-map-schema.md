---
name: kno-architecture-map-schema
description: "Schema canónico del mapa de arquitectura (architecture-map.json): nodos, edges, flujos de datos y procedencia. Fuente de verdad estructural que los agentes leen antes de construir y actualizan después. No escanea código: se nutre de los artefactos que los agentes ya producen."
license: MIT
user-invocable: false
metadata:
  author: agent-architect
  version: "1.0.0"
  category: architecture
  priority: high
  source: "Concepto 'self-explaining repo' (HTML para humanos + JSON para agentes)"
---

# Architecture Map — Schema canónico

El **mapa de arquitectura** (`docs/general/architecture-map.json`) es la **única fuente de verdad estructural**
de un proyecto cliente. Los agentes lo **leen** antes de diseñar/construir (para extender, no duplicar) y lo
**actualizan** después de completar una feature. Su proyección humana es `architecture-map.html` (grafo + ER +
flujos). El dashboard lo pinta en vivo.

**Principio clave**: el mapa NO escanea código. Se nutre de los artefactos que los agentes **ya producen** —
las "Notas técnicas" de 6 capas de cada story, la sección "Dependencias > Usa/Crea", y los ADRs de
`architecture.md`. Es una **normalización** de conocimiento disperso, no un análisis nuevo.

---

## Ubicación

| Archivo | Qué es | Propagable |
|---|---|---|
| `docs/general/architecture-map.json` | Capa canónica (máquina) | NO — dato local del proyecto |
| `docs/general/architecture-map.html` | Proyección humana (derivada) | NO — derivado del JSON |
| `docs/general/architecture-map.events.jsonl` | Correcciones humanas (v1.1, opcional) | NO — dato local |

Coexiste con `project-registry.md` (inventario plano que sigue usándose en build). El mapa es su **versión
relacional**; unificarlos queda como mejora futura — NO romper el registry.

---

## Schema

```json
{
  "schema_version": "1.0.0",
  "project": "<nombre del proyecto>",
  "generated_at": "<ISO 8601>",
  "tech_stack": {
    "frontend": "<ej: Next.js 15>",
    "backend": "<ej: Node.js + Express>",
    "database": "<ej: PostgreSQL>"
  },
  "nodes": [ /* ver Nodos */ ],
  "edges": [ /* ver Edges */ ],
  "data_flows": [ /* ver Flujos */ ],
  "drift_warnings": [ /* strings; los rellena el drift-check opcional */ ]
}
```

### Nodos (`nodes[]`)

Cada nodo es una pieza estructural. Campos:

| Campo | Req | Descripción |
|---|---|---|
| `id` | sí | Identificador único y estable. Convención: `<kind-prefix>-<slug>` (ej. `svc-auth`, `db-users`, `api-login`). |
| `kind` | sí | Uno de: `page`, `component`, `hook`, `api`, `service`, `table`, `integration`. |
| `name` | sí | Nombre legible (ej. `AuthService`, `POST /api/login`, `users`). |
| `path` | no | Ruta del archivo en el codebase, si se conoce. |
| `feature` | sí | Feature/slug al que pertenece (ej. `user-auth`). |
| `meta` | no | Objeto con campos según el `kind` (ver abajo). |
| `provenance` | sí | De dónde salió este nodo (trazabilidad). |
| `status` | no | `active` (default) o `deprecated`. Nunca se borra un nodo; se marca `deprecated`. |

**`meta` por kind** (orientativo, no estricto):
- `table`: `{ "fields": ["id","email",...], "primary_key": "id", "indexes": ["email"] }`
- `api`: `{ "method": "POST", "route": "/api/login", "auth": "public|jwt", "request": {...}, "response": {...} }`
- `service`/`component`/`hook`: `{ "exports": ["fnA","fnB"] }`
- `integration`: `{ "provider": "SendGrid", "type": "external_service", "endpoint": "..." }`

**`provenance`** (obligatorio — el mapa siempre sabe de dónde viene cada dato):
```json
{ "story": "HU-012", "adr": "ADR-003", "added_at": "<ISO>", "by": "agent|human|bootstrap" }
```
- `by: agent` — escrito por un agente durante `/review` UPDATE.
- `by: human` — corrección humana reconciliada (v1.1).
- `by: bootstrap` — generado retroactivamente desde artefactos existentes.

### Edges (`edges[]`)

Cada edge es una relación dirigida entre dos nodos.

| Campo | Req | Descripción |
|---|---|---|
| `from` | sí | `id` del nodo origen. **Debe existir en `nodes`.** |
| `to` | sí | `id` del nodo destino. **Debe existir en `nodes`.** |
| `type` | sí | Uno de: `uses`, `depends_on`, `fk` (foreign key), `calls`, `renders`. |
| `provenance` | no | Igual que en nodos (al menos `story` recomendado). |

### Flujos de datos (`data_flows[]`)

Secuencia legible de un flujo end-to-end (login, checkout, etc.). Se renderiza como `sequenceDiagram`.

```json
{ "id": "user-login", "name": "Login de usuario",
  "steps": ["AuthForm (page-login) envía POST a api-login",
            "api-login llama svc-auth.validateCredentials",
            "svc-auth consulta db-users",
            "svc-auth genera JWT",
            "api-login devuelve token"] }
```

---

## Invariantes (las valida `render-map.py validate`)

1. **`schema_version` presente** y soportada.
2. **`id` únicos** en `nodes`. No duplicados.
3. **No edges colgantes**: todo `from`/`to` referencia un `id` existente en `nodes`.
4. **`kind` y `type` dentro del enum** permitido.
5. **`provenance` presente** en cada nodo.
6. **Append/upsert, nunca rewrite**: una actualización añade o modifica nodos/edges existentes (por `id`),
   nunca regenera el archivo de cero. Para retirar algo, `status: deprecated` (no borrar).

---

## Cómo lo usan los agentes (resumen — el detalle vive en `ski-architecture-map`)

- **Antes de construir** (`/plan`, `/build`): leer el JSON para entender qué existe y qué depende de qué, en
  <1k tokens, en vez de leer varias carpetas de feature e inferir. Extender, no duplicar.
- **Después de construir** (`/review` paso 6): upsert de los nodos/edges que la feature introdujo, desde sus
  "Notas técnicas" (6 capas: UI→`page/component`, DB→`table`, API→`api`, Lógica→`service`, Integraciones→
  `integration`, Edge cases→notas) y "Usa/Crea" (→ edges), con procedencia. Luego re-render del HTML.

Stub vacío válido (proyecto recién inicializado):
```json
{ "schema_version": "1.0.0", "project": "<nombre>", "generated_at": null,
  "tech_stack": {}, "nodes": [], "edges": [], "data_flows": [], "drift_warnings": [] }
```
