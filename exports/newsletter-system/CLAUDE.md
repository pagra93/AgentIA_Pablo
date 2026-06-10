# newsletter-system

Pipeline editorial para crear newsletters semanales

Paquete desplegable generado por [AgentArchitect](../../README.md) el 2026-05-15.

## Quick Reference

### Identidad

- **Nombre**: `newsletter-system`
- **Prefix**: `news` (todos los agentes con `age-spe-news-*`, comandos con `/news-*`)
- **Dominio**: `editorial-content`
- **Domain folder en proyectos clientes**: `docs/newsletter/`

### Filosofía

> Editorial Quality Over Output Volume

### Flujo principal

```
research → outline → draft → edit → publish
```

### Agentes previstos

- `age-spe-news-topic-researcher` — Investiga tema del próximo número (tendencias, fuentes, ángulo editorial)
- `age-spe-news-content-curator` — Selecciona y valida fuentes (artículos, estudios, citas)
- `age-spe-news-outline-architect` — Estructura el esqueleto del número (secciones, orden, longitudes objetivo)
- `age-spe-news-editorial-writer` — Redacta el primer draft completo basándose en el outline + fuentes
- `age-spe-news-headline-architect` — Genera titulares y subtítulos optimizados (apertura + cada sección)
- `age-spe-news-editor-in-chief` — Revisa, corrige, valida tono y coherencia, da OK final pre-publicación

(Cada uno con su carpeta `agents/age-spe-news-<nombre>/`. Algunos son stubs todavía — el `DUTIES.md` lo indica con `TODO: implementar`.)

### Supervisores QA heredados

Estos 5 supervisores son comunes a todos los paquetes (heredados del template canónico, mantenidos por el arquitecto):

- `age-sup-auditor` — Verifica compliance con rules
- `age-sup-evaluator` — Puntúa fases en 4D
- `age-sup-optimizer` — Detecta patrones recurrentes
- `age-sup-cynic` — Adversarial: desafía premisas
- `age-sup-boundary-walker` — Adversarial: explora bordes

### Outputs principales

Número de newsletter (.md y .html), métricas de envío

## Estructura del paquete

```
newsletter-system/
├── agents/          ← agentes específicos del paquete (age-spe-news-*) + supervisores QA
├── commands/        ← comandos /news-* específicos + comandos genéricos (save, docs, learned, etc.)
├── skills/          ← skills genéricas heredadas
├── rules/           ← rules genéricas heredadas
├── knowledge/       ← knowledge genérico heredado
├── templates/       ← templates específicos del paquete
├── docs/general/    ← docs cross-dominio
├── memory/MEMORY.md ← memoria del paquete
├── pm/              ← (opcional) estado operativo
├── changelog/       ← cambios del paquete
├── context-ledger/  ← log append-only por sesión
├── install.sh       ← compila e instala a ~/.claude/
├── deploy.sh        ← despliega en un proyecto cliente
├── dashboard-section.yaml  ← define la pestaña que aporta al dashboard del proyecto
├── guia-de-uso.html        ← guía humana del paquete
├── CLAUDE.md, SOUL.md, DUTIES.md, RULES.md, agent.yaml, system-overview.md, README.md
└── .claude/settings.local.json
```

## Cómo se usa

### Instalar a `~/.claude/`

Compila los agentes y comandos del paquete a `~/.claude/` para que estén disponibles globalmente:

```bash
bash install.sh
```

### Desplegar en un proyecto cliente

Crea la estructura del paquete en un proyecto cliente y añade su pestaña al dashboard del proyecto:

```bash
bash deploy.sh /ruta/al/proyecto-cliente
```

- Si el proyecto **no tiene** `dashboard/` todavía: lo crea desde `templates/project-template/` del arquitecto.
- Si el proyecto **ya tiene** `dashboard/` (otro paquete está desplegado): solo añade su pestaña sin pisar las demás.

### Trabajar en el paquete

Abre Cursor/Claude Code en `newsletter-system/`. Los agentes y comandos específicos del paquete estarán disponibles (después de ejecutar `install.sh`).

## Relación con el arquitecto

Este paquete se mantiene **sincronizado** con [AgentArchitect](../../README.md):

- **Lo genérico** (skills/rules/knowledge heredados, comandos transversales, supervisores QA, código del dashboard) lo propaga el arquitecto vía `/arc-propagate` cuando hay mejoras.
- **Lo específico** del paquete (agentes `age-spe-news-*`, comandos `/news-*`, skills/rules/knowledge propios del dominio) lo mantiene el PM directamente aquí.

Si necesitas mejorar algo genérico, hazlo en el arquitecto y propágalo. NO lo edites directamente aquí (se sobrescribirá en la próxima propagación).

## Identidad

Soy `newsletter-system`. Mi razón de ser:

Pipeline editorial para crear newsletters semanales

Trabajo en el dominio `editorial-content`. Mi flujo principal es: research → outline → draft → edit → publish.

Sigo las convenciones del arquitecto: prefijos consistentes, scope boundaries claros, lazy loading. Cuando produzco algo significativo, lo registro en `context-ledger/` para que sesiones futuras puedan reanudar trabajo.

## Lectura recomendada al arrancar sesión

1. Este `CLAUDE.md`
2. `system-overview.md` (índice ligero del paquete)
3. `memory/MEMORY.md` si tiene contenido reciente
4. Últimas entradas de `context-ledger/`
5. Solo después: el archivo concreto que necesites
