# AgentArchitect

Meta-sistema que mantiene paquetes desplegables de agentes Claude Code.

> **Estado**: en construcción. Plan completo: `~/.claude/plans/tengo-una-duda-quiero-rosy-tide.md`. Bitácora: `~/.claude/plans/architect-build-log.md`.

## ¿Qué es esto?

`AgentArchitect/` es el **meta-sistema** que mantiene un ecosistema de **paquetes desplegables** (PM x10, Newsletter, Marketing, ...). Cada paquete es un sistema autocontenido de agentes que puede:

1. **Instalarse a `~/.claude/`** (vía su `install.sh`) → sus comandos quedan disponibles globalmente en Claude Code, con prefijos para evitar colisiones.
2. **Desplegarse en proyectos clientes** (vía su `deploy.sh`) → crea estructura específica del dominio en el proyecto y añade su pestaña al dashboard multi-pestaña del proyecto.

El arquitecto se ocupa de:

- **Construir paquetes nuevos** con un mini-discovery de 5 preguntas (`/arc-new-package`)
- **Propagar mejoras genéricas** a todos los paquetes y proyectos clientes desplegados (`/arc-propagate`)
- **Auditar conformidad** de paquetes contra la convención canónica (`/arc-audit`)
- **Mantener el catálogo** de paquetes y su estado (`/arc-catalog`)
- **Analizar patrones cross-paquete** para detectar candidatos a promover a genérico (`/arc-aggregate`)
- **Revisión adversarial** del propio diseño (`/arc-adversarial`)

## ¿Qué NO es?

- **NO es un sustituto de los paquetes.** No hace producto, ni newsletters, ni marketing. Eso lo hace cada paquete dentro de su dominio.
- **NO es triple-platform.** Solo Claude Code. Sin generación para Codex/Antigravity.
- **NO impone reescritura de sistemas existentes.** PM x10 sigue funcionando idéntico, sin estar integrado al arquitecto. La migración a `exports/pmx-product/` es opcional, posterior, reversible.

## Convenciones rápidas

- **Prefijos por paquete**: `age-spe-<prefix>-*`, comandos `/<prefix>-*`. Ejemplo: `arc` para el arquitecto, `pm` para PM x10, `news` para Newsletter.
- **Comandos transversales** (genéricos, sin prefix): `/save`, `/docs`, `/learned`, `/challenge`, `/unknown-unknowns`, `/hotfix`, `/code-review`.
- **Aislamiento de scope**: el arquitecto solo lee `templates/` y `exports/README.md`; nunca entra en `exports/<paquete>/` para contenido específico.

## Cómo arrancar

(Estos comandos estarán disponibles cuando se complete el plan):

```bash
# Instalar el arquitecto a ~/.claude/ (compila los 9 agentes)
bash AgentArchitect/install.sh

# Crear un paquete nuevo (en Claude Code, dentro de AgentArchitect/)
/arc-new-package

# Desplegar un paquete en un proyecto cliente
bash AgentArchitect/exports/<paquete>/deploy.sh /ruta/MiCliente

# Abrir la consola visual del arquitecto
python3 architect-console/bridge.py
```

## Estructura

```
AgentArchitect/
├── agents/              ← 9 agentes (4 especialistas + 5 supervisores) con prefix arc-
├── commands/            ← 6 comandos /arc-*
├── skills/, rules/, knowledge/  ← genéricos heredados de PM x10 + nuevos
├── templates/
│   ├── package-template/   ← esqueleto de un paquete desplegable
│   └── project-template/   ← esqueleto de proyecto cliente + dashboard multi-pestaña
├── exports/             ← paquetes desplegables (cada uno su propio repo Git)
├── architect-console/   ← UI propia del arquitecto
├── config/              ← conventions.yaml, core-manifest.yaml
├── docs/                ← docs cross-paquete y reportes
├── changelog/           ← propagations.md
├── scripts/             ← atajos CLI
└── install.sh           ← compila agentes/comandos a ~/.claude/
```

## Documentación

- **[CLAUDE.md](CLAUDE.md)** — Quick reference para Claude Code
- **[SOUL.md](SOUL.md)** — Identidad y filosofía
- **[DUTIES.md](DUTIES.md)** — Segregación de los 9 agentes
- **[RULES.md](RULES.md)** — Reglas de operación
- **`architect-guia-de-uso.html`** — Guía humana detallada (pendiente en Fase 11)

## Relación con PM x10

`AgentArchitect/` se construye **inspirado en PM x10** y **reutiliza sus convenciones** (formato de agentes, sistema de memoria, dashboard como base parametrizable, install.sh como modelo). PM x10 sigue siendo el sistema vivo principal y no se modifica. La migración a `exports/pmx-product/` es una decisión futura del PM.
