# Schema de `_events.jsonl` (por feature folder)

Activity log cronológico append-only, **uno por feature folder**. Lo escribe `age-spe-pm-producto` en modo `dossier`. Cada línea es un evento JSON válido.

> **Diferencia con `pm/events.jsonl`**: aquel es global y opcional. Éste es por feature y siempre activo. Aporta granularidad + portabilidad (la feature folder es self-contained: si la copias a otro proyecto, su histórico viaja con ella).

---

## Formato de cada línea

```jsonl
{"ts":"<ISO 8601>","agent":"<agent-or-command>","event":"<event-type>","[extra fields...]"}
```

### Campos obligatorios

- **`ts`**: timestamp ISO 8601 con timezone (ej. `"2026-05-12T14:30:00Z"`)
- **`agent`**: nombre del agente o comando que generó el evento (sin prefijo `age-`)
- **`event`**: tipo de evento (ver tabla abajo)

### Campos opcionales (según evento)

- **`entity`**: ID afectado (`EPIC-013`, `HU-067`, etc.)
- **`summary`**: descripción humana en 1 línea
- **`output_files`**: array de paths relativos a la feature folder
- **`score`**: número (para evaluator, quality-guard)
- **`commit`**: hash de commit (para build events)
- **`...`**: campos custom según evento

---

## Tipos de eventos (catálogo)

### Inbox y PM
| `event` | `agent` | Campos extra |
|---|---|---|
| `inbox_processed` | `pm` | `entity`, `summary` |
| `task_prioritized` | `pm` | `entity` |
| `task_blocked` | `pm` | `entity`, `reason` |
| `task_unblocked` | `pm` | `entity` |
| `task_cancelled` | `pm` | `entity`, `reason` |
| `task_done_manual` | `pm` | `entity` |
| `drift_detected` | `pm` | `summary`, `affected_ids` |

### Challenge
| `event` | `agent` | Campos extra |
|---|---|---|
| `challenge_complete` | `challenger` | `assumption_validation`, `output_files` |

### Análisis
| `event` | `agent` | Campos extra |
|---|---|---|
| `prd_evaluated` | `quality-guard` | `score`, `dimensions` |
| `research_complete` | `researcher` | `hypotheses_unvalidated`, `output_files` |

### Definición
| `event` | `agent` | Campos extra |
|---|---|---|
| `jtbds_generated` | `jtbd-architect` | `count` |
| `stories_written` | `story-writer` | `count`, `mode` (create/enrich) |
| `quality_review_complete` | `quality-coach` | `issues`, `stories_below_threshold` |
| `story_split` | `story-splitter` | `original`, `new_ids` |

### Planning
| `event` | `agent` | Campos extra |
|---|---|---|
| `adr_generated` | `tech-architect` | `decision`, `summary` |
| `sprint_planned` | `sprint-planner` | `stories`, `estimated_days` |

### Build
| `event` | `agent` | Campos extra |
|---|---|---|
| `hu_started` | `build` | `entity` |
| `hu_complete` | `build` | `entity`, `commit`, `assumptions`, `tech_debt` |
| `build_deferred` | `build` | `entity`, `reason` |

### Review
| `event` | `agent` | Campos extra |
|---|---|---|
| `tests_run` | `test-engineer` | `pass`, `fail`, `coverage` |
| `code_review_complete` | `code-reviewer` | `issues_by_severity` |
| `audit_complete` | `auditor` | `passed` (bool) |
| `evaluation_complete` | `evaluator` | `score`, `dimensions` |
| `optimizer_pattern_detected` | `optimizer` | `pattern`, `proposal` |
| `docs_generated` | `doc-updater` | `output_files` |

### Wiki
| `event` | `agent` | Campos extra |
|---|---|---|
| `wiki_ingested` | `wiki-curator` | `output_files`, `entities_detected` |
| `wiki_concept_promoted` | `wiki-curator` | `slug` |

### Decisiones humanas (críticas)
| `event` | `agent` | Campos extra |
|---|---|---|
| `decision` | `human` | `summary`, `context` (qué se decidió y por qué) |

Solo se loguean decisiones críticas:
- Proceder con Quality Guard score <7
- Aceptar tech debt detectada en build/review
- Override de quality-coach (rechazar reescritura sugerida)
- Abandono de feature
- Rejection de stories en cualquier fase
- Override de auditor (proceder sin DoD)

---

## Ejemplo completo (EPIC-013 notif-push)

```jsonl
{"ts":"2026-05-10T08:00:00Z","agent":"pm","event":"inbox_processed","entity":"EPIC-013","summary":"Avisos push pedidos"}
{"ts":"2026-05-10T08:30:00Z","agent":"challenger","event":"challenge_complete","assumption_validation":"FAIL","output_files":["challenge-brief.md"]}
{"ts":"2026-05-10T09:00:00Z","agent":"quality-guard","event":"prd_evaluated","score":5.5,"dimensions":{"D1":4,"D2":6,"D3":7}}
{"ts":"2026-05-10T09:01:00Z","agent":"human","event":"decision","summary":"Proceder con riesgo","context":"Score 5.5 — baseline no validado, researcher debe captar evidencia"}
{"ts":"2026-05-10T09:30:00Z","agent":"researcher","event":"research_complete","hypotheses_unvalidated":3,"output_files":["research.md"]}
{"ts":"2026-05-11T10:00:00Z","agent":"jtbd-architect","event":"jtbds_generated","count":2}
{"ts":"2026-05-11T10:15:00Z","agent":"story-writer","event":"stories_written","count":5,"mode":"create"}
{"ts":"2026-05-11T10:30:00Z","agent":"quality-coach","event":"quality_review_complete","issues":["usuario-fantasma HU-070"],"stories_below_threshold":1}
{"ts":"2026-05-11T10:45:00Z","agent":"story-splitter","event":"story_split","original":"HU-068","new_ids":["HU-068a","HU-068b"]}
{"ts":"2026-05-11T14:00:00Z","agent":"tech-architect","event":"adr_generated","decision":"postgres-notify","summary":"Postgres NOTIFY sobre Supabase Realtime"}
{"ts":"2026-05-11T14:01:00Z","agent":"human","event":"decision","summary":"Aprobar Postgres NOTIFY","context":"Más control + mismo coste vs Realtime"}
{"ts":"2026-05-11T14:30:00Z","agent":"sprint-planner","event":"sprint_planned","stories":6,"estimated_days":4}
{"ts":"2026-05-12T11:00:00Z","agent":"build","event":"hu_complete","entity":"HU-067","commit":"abc123","assumptions":["SECURITY DEFINER necesario"],"tech_debt":["orders.status sin índice"]}
```

---

## Reglas de escritura

1. **Append-only**: nunca se modifica una línea existente. Si hay error, escribir nuevo evento con `event: "correction"`.
2. **Idempotencia**: si el PM regenera el dossier, NO duplica eventos. Detecta duplicados por `(ts, agent, event, entity)`.
3. **Atomicidad**: cada escritura es una sola línea + `\n`. Nunca multi-línea.
4. **UTF-8**: campos con acentos/ñ/símbolos van en UTF-8 (no escapados).
5. **Tamaño**: si supera 500 entradas, comprimir a `_events-archive-YYYY-MM.jsonl.gz` y empezar nuevo.
6. **Backwards compatibility**: nuevos campos opcionales no rompen lectores antiguos.

---

## Cómo leerlo

```python
import json
events = []
with open("_events.jsonl") as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("//"):
            continue
        events.append(json.loads(line))

# Ordenar por timestamp (debería estar ya, pero garantía)
events.sort(key=lambda e: e["ts"])

# Filtrar por agente
human_decisions = [e for e in events if e["agent"] == "human"]
```

El dashboard lo parsea con `json.loads` línea por línea y lo renderiza como timeline visual.
