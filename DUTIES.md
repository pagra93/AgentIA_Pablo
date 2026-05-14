# Segregation of Duties — Agent Architect

## Roles

| Role ID | Description | Permissions |
|---------|-------------|-------------|
| `generator` | Crea paquetes nuevos desde el template canónico vía mini-discovery | read, write-package, write-stubs, init-git |
| `propagator` | Aplica cambios genéricos a paquetes existentes y proyectos clientes desplegados | read, write-package, write-project, log-propagation |
| `cataloger` | Mantiene el índice de paquetes y su estado de salud | read, write-catalog |
| `aggregator` | Analiza patrones cross-paquete (lectura, sin modificar) | read, report |
| `supervisor` | Observa, audita, puntúa, propone mejoras (READ-ONLY) | read, score, propose |

## Agent-Role Assignments

| Agent | Role | Action surface |
|-------|------|----------------|
| `age-spe-arc-generator` | generator | Crea `exports/<nombre>/` desde `templates/package-template/` con mini-discovery |
| `age-spe-arc-propagator` | propagator | Distribuye cambios a paquetes y proyectos clientes |
| `age-spe-arc-cataloger` | cataloger | Regenera `exports/README.md` con estado de cada paquete |
| `age-spe-arc-aggregator` | aggregator | Genera reportes en `docs/architect/aggregations/` |
| `age-sup-arc-auditor` | supervisor | Detecta drift cross-paquete contra `conventions.yaml`. Read-only |
| `age-sup-arc-evaluator` | supervisor | Puntúa estado del arquitecto y de paquetes en 4D. Read-only |
| `age-sup-arc-optimizer` | supervisor | Detecta patrones recurrentes en cambios y propone mejoras. Read-only |
| `age-sup-arc-cynic` | supervisor | Adversarial review: desafía decisiones del arquitecto. Read-only |
| `age-sup-arc-boundary-walker` | supervisor | Adversarial review: explora bordes y casos extremos. Read-only |

## Scope Boundaries

El arquitecto opera sobre dos planos y NUNCA dentro de un paquete concreto:

| Scope | Lectura | Escritura |
|-------|---------|-----------|
| `AgentArchitect/` (raíz: `agents/`, `skills/`, `rules/`, etc.) | Sí | Sí |
| `templates/package-template/`, `templates/project-template/` | Sí | Sí |
| `exports/README.md` (catálogo) | Sí | Sí (vía cataloger) |
| `exports/<paquete>/<contenido específico>` | **NO** (regla `rul-scope-boundaries`) | **NO** |
| `exports/<paquete>/<archivos core marcados como propagables>` | Sí (vía propagator) | Sí (vía propagator, solo los core) |
| Proyectos clientes (rutas externas) | Sí (cuando propaga al dashboard) | Sí (solo el código del dashboard genérico) |

## Conflict Matrix

| Role A | Role B | Reason |
|--------|--------|--------|
| `generator` | `supervisor` | Quien crea paquetes no debe auditarlos |
| `propagator` | `supervisor` | Quien modifica paquetes no debe evaluar el resultado |

## Handoff Workflows

### Crear paquete nuevo (`/arc-new-package`)
```
age-spe-arc-generator
  → mini-discovery (5 preguntas)
  → copia templates/package-template/ → exports/<nombre>/
  → sustituye placeholders
  → genera stubs de agentes previstos
  → git init dentro del export
  → invoca cataloger para actualizar exports/README.md
  → primera entrada en context-ledger/
```

### Propagar mejora (`/arc-propagate`)
```
age-spe-arc-propagator
  → lee config/core-manifest.yaml
  → identifica qué paquetes/proyectos reciben el cambio
  → aplica a paquetes en exports/
  → aplica a proyectos clientes registrados (si scope incluye dashboard)
  → log en changelog/propagations.md
```

### Auditar conformidad (`/arc-audit`)
```
age-sup-arc-auditor
  → escanea exports/*/
  → verifica conformidad contra conventions.yaml
  → reporta drift por paquete (legítimo vs accidental)
  → READ-ONLY
```

### Análisis macro cross-paquete (`/arc-aggregate`)
```
age-spe-arc-aggregator
  → lee solo agent.yaml y system-overview.md de cada paquete (lazy-loading)
  → aplica foco solicitado: patrones, comparativas, gaps
  → genera reporte en docs/architect/aggregations/<fecha>.md
  → propone candidatos a propagar (NO ejecuta)
  → READ-ONLY
```

### Revisión adversarial (`/arc-adversarial`)
```
age-sup-arc-cynic
  → desafía premisas, fuerza evidencia
  → READ-ONLY
age-sup-arc-boundary-walker
  → explora bordes y casos extremos
  → READ-ONLY
PM recibe ambos reportes
```

### Mantenimiento de catálogo (`/arc-catalog`)
```
age-spe-arc-cataloger
  → escanea exports/*/agent.yaml + system-overview.md
  → regenera exports/README.md
  → auto-invocado tras generator/propagator
```

## Isolation Policy

- **State**: El arquitecto no comparte contexto con los paquetes ni con los proyectos clientes. Cada uno es Claude Code independiente cuando se abre.
- **Memory**: El arquitecto tiene su propio `memory/MEMORY.md`. Cada paquete tiene el suyo. Los proyectos clientes el suyo. No se mezclan.
- **Context-ledger**: Cada paquete tiene su `context-ledger/` con log de sesiones. El arquitecto también.

## Enforcement

**Mode: advisory**

Igual que PM x10. La regla `rul-scope-boundaries` es advisory pero documentada. El sistema avisa si un agente intenta leer fuera de su scope. El PM decide.
