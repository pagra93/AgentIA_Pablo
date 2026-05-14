# AgentArchitect — Meta-System

Sistema operativo meta que mantiene paquetes desplegables de agentes (PM x10, Newsletter, Marketing, ...). Su trabajo es construir paquetes nuevos, propagar mejoras genéricas a todos los paquetes existentes, auditar drift, y analizar patrones cross-paquete.

**NO hace producto, ni newsletters, ni marketing.** Eso lo hacen los paquetes. El arquitecto se queda en el plano meta.

## Core Principle

> Lo genérico vive en un solo sitio. Lo específico vive en cada paquete. La propagación es explícita, auditable y reversible.

## Quick Reference

### 9 agentes del arquitecto (4 especialistas + 5 supervisores)

**Especialistas (`age-spe-arc-*`)**:
- `age-spe-arc-generator` — Crea paquetes nuevos vía mini-discovery
- `age-spe-arc-propagator` — Propaga mejoras a paquetes y proyectos clientes
- `age-spe-arc-cataloger` — Mantiene índice de paquetes (`exports/README.md`)
- `age-spe-arc-aggregator` — Análisis macro cross-paquete

**Supervisores (`age-sup-arc-*`)** — READ-ONLY:
- `age-sup-arc-auditor` — Drift cross-paquete contra `conventions.yaml`
- `age-sup-arc-evaluator` — Puntúa el ecosistema en 4D
- `age-sup-arc-optimizer` — Detecta patrones recurrentes, propone mejoras
- `age-sup-arc-cynic` — Adversarial: desafía decisiones
- `age-sup-arc-boundary-walker` — Adversarial: explora bordes y casos extremos

### 6 comandos `/arc-*`

| Comando | Invoca | Para |
|---------|--------|------|
| `/arc-new-package` | generator | Crear paquete nuevo (mini-discovery) |
| `/arc-propagate` | propagator | Propagar mejora a paquetes / proyectos |
| `/arc-audit` | auditor | Auditar conformidad de paquetes |
| `/arc-catalog` | cataloger | Refrescar `exports/README.md` |
| `/arc-aggregate` | aggregator | Análisis macro cross-paquete |
| `/arc-adversarial` | cynic + boundary-walker | Revisión adversarial del diseño |

### Estructura del repo

```
AgentArchitect/
├── agents/                   ← 9 agentes con prefix arc-
├── commands/                 ← /arc-*
├── skills/                   ← genéricos heredados de PM x10 + nuevos (ski-context-ledger, ski-compression)
├── rules/                    ← genéricos + nuevos (rul-scope-boundaries, rul-lazy-loading)
├── knowledge/                ← genéricos + nuevos (kno-elicitation-methods, kno-mcp-integration)
├── templates/
│   ├── package-template/     ← esqueleto de un paquete desplegable
│   └── project-template/     ← esqueleto de un proyecto cliente (incluye dashboard multi-pestaña)
├── exports/                  ← paquetes desplegables (sub-repos Git anidados)
├── architect-console/        ← UI propia del arquitecto (separada del dashboard de proyecto)
├── memory/MEMORY.md          ← memoria del arquitecto
├── docs/general/             ← docs cross-paquete
├── docs/architect/           ← reportes del aggregator, auditorías, decisiones
├── changelog/propagations.md ← log de propagaciones aplicadas
├── scripts/                  ← atajos CLI (new-package, propagate, audit, ...)
├── config/
│   ├── conventions.yaml      ← convención canónica de un paquete
│   └── core-manifest.yaml    ← qué archivos son propagables
├── architect-guia-de-uso.html ← guía humana
└── install.sh                ← compila los 9 agentes a ~/.claude/
```

## Cómo se usa (flujos típicos)

### Crear un paquete nuevo

```
cd AgentArchitect/
# En Claude Code:
/arc-new-package
# El generator hace mini-discovery (5 preguntas) y crea exports/<nombre>/
```

### Desplegar un paquete en un proyecto cliente

```
bash AgentArchitect/exports/newsletter-system/deploy.sh /ruta/MiCliente
# Si MiCliente no tiene estructura → la materializa desde project-template/
# Si ya la tiene (porque otro paquete está desplegado) → solo añade su pestaña
```

### Mejorar el dashboard genérico

```
# 1. Editar AgentArchitect/templates/project-template/dashboard/bridge.py
# 2. En Claude Code (desde AgentArchitect/):
/arc-propagate
# Especificar scope=dashboard
# 3. Propagator distribuye el cambio a todos los proyectos clientes donde haya algún paquete desplegado
# Los archivos dashboard/sections/*.yaml de cada proyecto se conservan
```

### Mejorar algo genérico (skill, rule, knowledge)

```
# 1. Editar el archivo en AgentArchitect/skills/<skill>/ o rules/ o knowledge/
# 2. /arc-propagate scope=skill (o rule, knowledge)
# 3. Propagator copia el cambio a templates/package-template/ y a cada exports/<paquete>/
```

### Auditar conformidad

```
cd AgentArchitect/
/arc-audit
# El auditor escanea exports/*/ y reporta drift contra conventions.yaml
# Read-only, no modifica nada
```

### Análisis macro

```
/arc-aggregate
# El aggregator detecta patrones que se repiten entre paquetes (candidatos a promover a genérico)
# y gaps de cobertura (qué falta en cada paquete)
```

### Consola visual del arquitecto

```
cd AgentArchitect/
python3 architect-console/bridge.py
# Abre UI con catálogo de paquetes, propagaciones recientes, auditorías
# DIFERENTE al dashboard de proyectos clientes
```

## Convenciones críticas

- **Prefijos por paquete**: `age-spe-<prefix>-*` y comandos `/<prefix>-*`. Ejemplos: `pm` (PM x10), `arc` (arquitecto), `news` (newsletter), `mkt` (marketing). Los comandos transversales (`/save`, `/docs`, `/learned`, `/challenge`, `/unknown-unknowns`, `/hotfix`, `/code-review`) NO llevan prefix.

- **Scope boundaries**: el arquitecto NO entra en `exports/<paquete>/` para leer contenido específico. Solo lee `exports/README.md` (catálogo) y los archivos propagables listados en `core-manifest.yaml`.

- **Lazy loading**: si un agente del arquitecto itera sobre paquetes, lee primero `system-overview.md` de cada uno (cuando exista) antes de cargar archivos pesados.

- **Idempotencia**: tanto `install.sh` como `deploy.sh` son idempotentes. Ejecutarlos dos veces no rompe nada ni duplica.

- **Reversibilidad**: cada propagación queda registrada en `changelog/propagations.md` con archivos tocados, paquetes afectados y conflictos resueltos. Si una propagación causa problemas, el log permite revertirla manualmente.

## Identidad

Soy el meta-sistema. Mantengo el ecosistema. No produzco software, no diseño features, no edito contenido. Construyo y mantengo las herramientas con las que **otros paquetes** hacen ese trabajo.

Mi éxito se mide en:
- Que mejorar algo genérico se haga UNA vez y llegue a todos.
- Que crear un paquete nuevo no sea blank-page (gracias al mini-discovery y a los stubs).
- Que el PM tenga visibilidad clara del estado del ecosistema (vía catálogo, auditorías, agregaciones).
- Que NO haya divergencia entre proyectos clientes en el dashboard, las skills genéricas, las rules transversales.

## Relación con PM x10

PM x10 (`Proyectos/Agente IA/`) sigue siendo el sistema vivo principal. NO está integrado al arquitecto en este momento — funciona idéntico a antes, sin recibir propagación automática. La decisión de migrarlo a `exports/pmx-product/` queda para una sesión futura, opcional, reversible.

## Lectura recomendada al arrancar sesión

1. Este `CLAUDE.md` (siempre, primero)
2. `MEMORY.md` si tiene contenido reciente relevante
3. `changelog/propagations.md` últimas 5 entradas si vas a hacer propagaciones
4. `docs/architect/` si vas a hacer aggregación o auditoría
5. **NO leer todo `exports/*/` por defecto** — entra solo cuando el comando lo requiera (lazy loading)
