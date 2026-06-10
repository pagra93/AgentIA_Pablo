---
name: ski-architecture-map
description: "Mantener el mapa de arquitectura de un proyecto (architecture-map.json canónico + architecture-map.html). API de 4 verbos: READ (antes de construir), UPDATE (tras una feature), PROJECT (render HTML), BOOTSTRAP (mapa inicial retroactivo). Se nutre de artefactos existentes, no escanea código."
license: MIT
allowed-tools: Read Write Edit Bash
user-invocable: false
metadata:
  author: agent-architect
  version: "1.0.0"
  category: architecture
  schema: kno-architecture-map-schema
---

# Architecture Map — Skill de mantenimiento

Mantiene el **mapa de arquitectura** de un proyecto cliente: la capa canónica `docs/general/architecture-map.json`
(para agentes) y su proyección `docs/general/architecture-map.html` (para humanos). El schema canónico está en
`kno-architecture-map-schema` — léelo antes de escribir el mapa.

**Principio**: el mapa NO escanea código. **Normaliza** lo que los agentes ya producen (Notas técnicas de 6
capas, Usa/Crea, ADRs) en una capa relacional. Lo que es *juicio* (qué nodos/edges introduce una feature) lo
hace el agente; lo *determinista* (validar, renderizar HTML) lo hace `render-map.py`.

Rutas (relativas a la raíz del proyecto):
- Mapa: `docs/general/architecture-map.json`
- HTML: `docs/general/architecture-map.html`
- Script: `skills/ski-architecture-map/render-map.py` (bundleado; ruta idéntica en arquitecto y paquetes)

---

## Verbo READ — antes de construir (`/plan`, `/build`)

Para entender la arquitectura existente sin leer media docena de carpetas de feature:

1. `Read docs/general/architecture-map.json`. Es <1k tokens en proyectos pequeños/medianos.
2. Localiza los nodos del área que vas a tocar (`feature`, `kind`) y sus `edges` (qué usa, qué lo usa).
3. **Extender, no duplicar**: si ya existe un `service`/`table`/`api` que cubre la necesidad, reúsalo. Solo
   crea nodos nuevos para lo que de verdad no existe.

Reemplaza el patrón actual de "leer `project-registry.md` plano e inferir relaciones".

---

## Verbo UPDATE — tras completar una feature (`/review`, paso 6)

Upsert **incremental e idempotente** desde los artefactos de la feature recién terminada:

1. `Read` la feature: `stories.md` (sección "Notas técnicas" de 6 capas + "Dependencias > Usa/Crea") y, si
   existe, `architecture.md` (ADRs).
2. Mapea las 6 capas a nodos:
   - UI → `page` / `component` / `hook`
   - DB → `table` (con `meta.fields`)
   - API → `api` (con `meta.method`/`route`)
   - Lógica → `service`
   - Integraciones → `integration`
   - Edge cases → notas (no son nodos)
3. Mapea "Usa/Crea" y las llamadas a **edges** (`uses`, `calls`, `fk`, `renders`, `depends_on`).
4. **Upsert por `id`** (regla del schema): si el nodo/edge ya existe, actualízalo; si no, añádelo. **Nunca
   reescribas el archivo de cero.** Para retirar algo: `status: deprecated` (no borrar).
5. Pon `provenance` en todo lo nuevo: `{ "story": "HU-XXX", "adr": "ADR-YYY?", "added_at": "<ISO>", "by": "agent" }`.
   Genera el timestamp con `date -u +%Y-%m-%dT%H:%M:%SZ`.
6. Actualiza `generated_at` a ahora.
7. **Valida y renderiza** (verbo PROJECT abajo). Si `validate` falla, corrige antes de dar la feature por cerrada.

> Es upsert, no análisis nuevo: solo normalizas en el mapa lo que el agente ya escribió en la story.

---

## Verbo PROJECT — render del HTML (determinista)

```
python3 skills/ski-architecture-map/render-map.py validate docs/general/architecture-map.json
python3 skills/ski-architecture-map/render-map.py render   docs/general/architecture-map.json docs/general/architecture-map.html
```

- `validate` comprueba invariantes (ids únicos, no edges colgantes, enums, procedencia). Falla con lista clara.
- `render` genera el HTML standalone (mermaid: grafo de dependencias + ER + sequence de flujos), reusa los
  design tokens OKLch, inlina el JSON. Idempotente.

El dashboard lee el JSON directamente (no necesita el HTML); el HTML es para abrir/compartir sin levantar nada.

---

## Verbo BOOTSTRAP — mapa inicial retroactivo (proyectos existentes, manual)

Solo cuando el PM lo lanza a mano sobre un proyecto que ya tiene historia y quiere su mapa de golpe (no se
ejecuta solo: cuesta una pasada y su calidad depende de la documentación previa).

1. `Read` los artefactos existentes: `docs/general/project-registry.md` (inventario de assets), todas las
   `docs/producto/features/*/stories.md` (Notas técnicas) y `architecture.md`/ADRs.
2. Construye `nodes`/`edges`/`data_flows` siguiendo el schema, con `provenance.by: "bootstrap"`.
3. Valida y renderiza (verbo PROJECT).
4. A partir de aquí, UPDATE lo mantiene incrementalmente.

Si un artefacto está incompleto, marca el hueco (no inventes): mejor un mapa parcial honesto que uno falso
(ver `rul-fail-loud`).

---

## Reglas

1. **Schema es ley**: ajústate a `kno-architecture-map-schema`. `validate` debe pasar siempre antes de cerrar.
2. **Upsert, nunca rewrite**: el mapa es acumulativo; `deprecated` en vez de borrar.
3. **Procedencia obligatoria**: cada nodo sabe de qué story/ADR salió y quién lo escribió (`agent|human|bootstrap`).
4. **El mapa es dato local**: nunca se propaga entre proyectos (como `memory/`, `context-ledger/`).
5. **No escanear código**: si te falta info, sale de un artefacto del agente o se marca como hueco; no se
   infiere parseando fuentes (eso sería otra capacidad, opcional y por-stack).

## Relación con otras piezas
- `kno-architecture-map-schema` — el contrato de datos.
- `ski-context-ledger` — registra el paso UPDATE como entrada del ledger si fue significativo.
- `project-registry.md` — coexiste (inventario plano); el mapa es su versión relacional. No romper el registry.
