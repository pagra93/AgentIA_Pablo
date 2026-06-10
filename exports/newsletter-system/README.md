# newsletter-system

Pipeline editorial para crear newsletters semanales

> Paquete desplegable generado por [AgentArchitect](../../README.md) el 2026-05-15. Dominio: `editorial-content`. Prefix: `news`.

## Quick start

```bash
# Instalar agentes y comandos del paquete a ~/.claude/
bash install.sh

# Desplegar el paquete en un proyecto cliente
bash deploy.sh /ruta/al/proyecto-cliente
```

Después del primer comando, los `/news-*` están disponibles globalmente en Claude Code.
Después del segundo, el proyecto cliente tiene la estructura del paquete y una pestaña en su dashboard.

## Flujo principal

```
research → outline → draft → edit → publish
```

## Agentes del paquete

- `age-spe-news-topic-researcher` — Investiga tema del próximo número (tendencias, fuentes, ángulo editorial)
- `age-spe-news-content-curator` — Selecciona y valida fuentes (artículos, estudios, citas)
- `age-spe-news-outline-architect` — Estructura el esqueleto del número (secciones, orden, longitudes objetivo)
- `age-spe-news-editorial-writer` — Redacta el primer draft completo basándose en el outline + fuentes
- `age-spe-news-headline-architect` — Genera titulares y subtítulos optimizados (apertura + cada sección)
- `age-spe-news-editor-in-chief` — Revisa, corrige, valida tono y coherencia, da OK final pre-publicación

(Más detalles en `system-overview.md` y `agents/age-spe-news-<nombre>/DUTIES.md`.)

## Outputs canónicos

Número de newsletter (.md y .html), métricas de envío

## Documentación

- **`CLAUDE.md`** — quick reference para Claude Code (estructura, convenciones)
- **`SOUL.md`** — identidad y filosofía del paquete
- **`DUTIES.md`** — segregación de roles
- **`RULES.md`** — reglas operativas
- **`system-overview.md`** — índice ligero (preferido al leer cosas)
- **`guia-de-uso.html`** — guía humana detallada

## Estructura

```
newsletter-system/
├── .claude/settings.local.json
├── agents/              ← especialistas del paquete + 5 supervisores QA heredados
├── commands/            ← /news-* + comandos genéricos heredados
├── skills/              ← genéricas heredadas
├── rules/               ← genéricas heredadas
├── knowledge/           ← genérico heredado
├── templates/           ← templates específicos del paquete
├── docs/general/        ← docs cross-dominio
├── memory/MEMORY.md
├── pm/                  ← (opcional) estado operativo
├── changelog/
├── context-ledger/      ← log append-only por sesión
├── install.sh           ← compila a ~/.claude/
├── deploy.sh            ← despliega en proyecto cliente
├── dashboard-section.yaml ← define pestaña aportada al dashboard del proyecto
├── guia-de-uso.html
├── system-overview.md
├── CLAUDE.md, SOUL.md, DUTIES.md, RULES.md, agent.yaml
└── README.md
```

## Relación con el arquitecto

Este paquete vive bajo [AgentArchitect](../../README.md). Cuando el arquitecto propaga mejoras a lo genérico (skills, rules, knowledge, comandos transversales, supervisores QA, código del dashboard), este paquete las recibe.

Lo específico del dominio se mantiene aquí directamente.

## Estado

**Versión actual**: 0.1.0 (stub)

Los agentes especialistas son **stubs por ahora** — sus `DUTIES.md` indican `TODO: implementar`. La implementación es trabajo aparte del PM tras la generación.

## Licencia

MIT
