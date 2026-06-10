---
name: rul-scope-boundaries
description: "Aislamiento estricto entre el arquitecto y los paquetes/proyectos clientes. El arquitecto solo opera sobre el plano meta. Preloaded por todos los agentes del arquitecto."
license: MIT
user-invocable: false
metadata:
  author: agent-architect
  version: "1.0.0"
  category: standards
  loaded-by: all_arc_agents
  inspired-by: "luisdomarco/AiAgentArchitect (rul-scope-boundaries)"
---

# Scope Boundaries — Aislamiento del meta-sistema

## Principio

El arquitecto opera sobre el **plano meta**: templates, catálogo de paquetes, propagaciones, auditorías. **Nunca** entra en `exports/<paquete>/` para leer contenido específico ni modificarlo (salvo los archivos listados como propagables en `core-manifest.yaml`).

Esto preserva la **soberanía de cada paquete** sobre su dominio. PM x10 sabe de stories, Newsletter sabe de pipelines editoriales, Marketing sabe de campañas. El arquitecto no.

## Matriz de scope

| Path | Read | Write | Quién |
|------|------|-------|-------|
| `AgentArchitect/{agents,skills,rules,knowledge,commands}/` | ✅ | ✅ | Todos los agentes del arquitecto |
| `AgentArchitect/templates/package-template/` | ✅ | ✅ | generator, propagator |
| `AgentArchitect/templates/project-template/` | ✅ | ✅ | propagator (sobre dashboard genérico) |
| `AgentArchitect/exports/README.md` | ✅ | ✅ (solo cataloger) | cataloger |
| `AgentArchitect/exports/<paquete>/agent.yaml` | ✅ (lazy, solo lo necesario) | ❌ | aggregator, auditor |
| `AgentArchitect/exports/<paquete>/system-overview.md` | ✅ (lazy) | ❌ | aggregator, auditor |
| `AgentArchitect/exports/<paquete>/<archivos en core-manifest>` | ✅ | ✅ (solo propagator) | propagator |
| `AgentArchitect/exports/<paquete>/<contenido específico>` (DUTIES, SOUL, agent.yaml de agentes del paquete, etc.) | ❌ | ❌ | NINGÚN agente del arquitecto |
| Proyectos clientes (rutas externas, ej `/Users/pablo/Trabajos/MiCliente/`) | ✅ (solo cuando propaga dashboard) | ✅ (solo `dashboard/{bridge.py,index.html,styles.css,app.js}`) | propagator |
| Proyectos clientes: `pm/config.json`, `dashboard/sections/*.yaml` | ❌ | ❌ | NUNCA — son config local del proyecto |

## Reglas operativas

1. **Lectura selectiva en aggregator y auditor**: solo `agent.yaml` y `system-overview.md` de cada paquete. NO leer DUTIES.md/SOUL.md de agentes internos del paquete.

2. **Propagator solo toca core-manifest**: si un archivo NO está listado en `config/core-manifest.yaml`, el propagator no lo modifica. Si una propagación requeriría tocar algo fuera del manifest, se aborta y se pide al PM ampliar el manifest o hacer el cambio manualmente.

3. **Generator NO modifica paquetes existentes**: solo crea paquetes nuevos copiando `templates/package-template/`. Para modificar un paquete existente, eso lo hace el propagator (solo en core files) o el PM directamente (en cualquier archivo).

4. **Acceso a proyectos clientes solo durante propagación de dashboard**: el propagator escanea `~/.claude/projects-registry.txt` (registro mantenido por `deploy.sh` de cada paquete), itera sobre las rutas listadas, y solo toca los 4 archivos del dashboard genérico (`bridge.py`, `index.html`, `styles.css`, `app.js`). NUNCA toca `pm/config.json` ni `dashboard/sections/*.yaml` ni `docs/<dominio>/` del proyecto.

5. **Reportes nunca incluyen contenido protegido**: si el auditor o aggregator necesitan reportar algo sobre un paquete, citan rutas (`exports/newsletter-system/agents/age-spe-news-research/DUTIES.md`) pero NO incluyen el contenido del archivo en el reporte. La regla es: el arquitecto sabe que existe, no qué dice.

## Modo de cumplimiento

**Mode: advisory** (igual que `rul-naming-conventions` en PM x10). El sistema avisa si un agente intenta una lectura/escritura fuera de su scope, pero el PM puede forzarla con confirmación explícita.

En la práctica, los agentes del arquitecto están escritos para respetar estos boundaries por diseño. La regla existe para hacerlo explícito y para que el auditor pueda flagear violaciones si las detecta.

## Por qué importa

Sin esta regla, el arquitecto tiende a "saberlo todo" sobre cada paquete y a meter lógica de dominio en agentes meta. Eso destruye la separación de responsabilidades:

- El arquitecto se convierte en un super-agente sabelo-todo difícil de mantener
- Las skills/rules genéricas empiezan a tener `if dominio == "newsletter"` (cross-contamination)
- Cambios en un paquete obligan a tocar el arquitecto
- El catálogo crece linealmente con el conocimiento de cada paquete, no con el número de paquetes

Con scope boundaries estrictos, el arquitecto crece en complejidad solo si añadimos nuevas capacidades meta (nuevo tipo de propagación, nuevo tipo de auditoría), no por cada paquete nuevo.

## Cómo se verifica

El `age-sup-arc-auditor` puede ejecutar un check específico de `scope-boundaries`:

1. Buscar referencias en los DUTIES.md/SOUL.md de agentes del arquitecto a paths bajo `exports/<paquete>/` que NO sean `agent.yaml`, `system-overview.md` o archivos del `core-manifest.yaml`.
2. Buscar en código de skills/rules del arquitecto referencias a dominios específicos (palabras como "story", "PRD", "newsletter", "marketing" hardcodeadas).
3. Reportar violaciones al PM.

Read-only. El auditor no arregla, propone.
