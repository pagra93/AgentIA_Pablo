---
agent: age-spe-arc-generator (Pablo + Claude)
timestamp: 2026-05-18T11:55:00+0200
step: "migration_to_architect"
scope: "pmx-product"
input_summary: "PM x10 migrado desde Proyectos/Agente IA/ a AgentArchitect/exports/pmx-product/ como first-class package."
outcome: "completed"
artifacts_touched:
  - exports/pmx-product/ (movido entero desde Proyectos/Agente IA/)
  - exports/pmx-product/pm-agent-system-guia-de-uso.html (9 paths actualizados)
  - exports/pmx-product/scripts/README.md (2 paths actualizados)
  - exports/pmx-product/CLAUDE.md (NUEVO)
  - exports/pmx-product/system-overview.md (NUEVO)
  - exports/pmx-product/deploy.sh (NUEVO)
  - exports/pmx-product/dashboard-section.yaml (NUEVO)
  - exports/pmx-product/context-ledger/README.md (NUEVO)
  - exports/pmx-product/guia-de-uso.html (symlink NUEVO)
  - ~/.claude/packages-registry.txt (entrada añadida)
  - ~/.claude/pmx10 (regenerado por install.sh con nueva ruta)
---

## Qué se hizo

Migración de PM x10 al arquitecto como first-class package. Plan completo aprobado y ejecutado en 12 fases (Fase 15.1 a 15.12). Decisión clave del PM: **first-class** (no legacy con drift documentado) — PM x10 cumple la convención canónica del arquitecto.

## Cambios concretos

### Movimiento físico

`/Users/pablogranados/Desktop/PABLO/Proyectos/Agente IA/` → `/Users/pablogranados/Desktop/PABLO/Proyectos/AgentArchitect/exports/pmx-product/`

`mv` simple preservó:
- Repo Git completo (commit base `9bed57e`)
- Remote a GitHub (`pagra93/AgentIA_Pablo`)
- 18 agentes intactos
- 17 comandos intactos
- `dashboard-template/` original intacto
- Todas las carpetas extra (compliance, qa, workflows, examples, hooks, config, scripts, templates, docs, memory)

### Paths hardcoded actualizados (11)

- `pm-agent-system-guia-de-uso.html`: 9 referencias actualizadas
- `scripts/README.md`: 2 referencias actualizadas

Patrón sustituido: `$HOME/Desktop/PABLO/Proyectos/Agente IA` → `$HOME/Desktop/PABLO/Proyectos/AgentArchitect/exports/pmx-product`

### Archivos nuevos para cumplir convención canónica

- `CLAUDE.md` — Quick reference para Claude Code
- `system-overview.md` — Índice ligero (rul-lazy-loading)
- `deploy.sh` — Despliegue como pestaña en proyecto cliente
- `dashboard-section.yaml` — Define pestaña "Producto" del dashboard multi-paquete
- `context-ledger/README.md` — (este archivo)
- `guia-de-uso.html` — symlink → `pm-agent-system-guia-de-uso.html`

### Registros

- `~/.claude/packages-registry.txt`: añadido `pmx-product|pmx|<ruta>|<timestamp>`
- `~/.claude/pmx10` wrapper: regenerado con nueva ruta vía `install.sh`

## Decisiones tomadas

1. **First-class vs legacy drift**: PM elige first-class. Implica crear los 5 archivos canónicos que PM x10 no tenía.

2. **Symlink en lugar de renombrar la guía HTML**: `guia-de-uso.html` → `pm-agent-system-guia-de-uso.html`. Cumple convención sin romper bookmarks ni URLs externas que usen el nombre viejo.

3. **No renombrar agentes**: PM x10 NO usa el prefix consistente `age-spe-<prefix>-*`. Sus agentes son `age-spe-quality-guard`, `age-spe-story-builder`, `age-spe-pm-producto`, etc. — predates la convención. Documentado en `dashboard-section.yaml > metadata.notes` como divergencia legítima.

4. **`prefix` en packages-registry = `pmx`**: el primer campo del registry es el nombre (`pmx-product`); el segundo es el prefix nominal usado como alias. Para PM x10 ponemos `pmx` (en lugar de `pm` que es el comando) para evitar confusión.

5. **Dashboard original conservado**: PM x10 sigue teniendo su `dashboard-template/` propio. Coexiste con la pestaña "Producto" del dashboard multi-paquete del arquitecto. Cada proyecto cliente elige cuál usar.

## Próximos pasos (sugeridos al PM)

1. Verificar que `/pm`, `/define`, `/build`, etc. siguen funcionando idénticos en Claude Code (smoke test).
2. Actualizar manualmente:
   - Alias en `.zshrc` / `.bashrc` si tenías alguno apuntando a la ruta vieja.
   - Workspaces de VSCode/Cursor configurados con la ruta antigua.
   - Pinned folders en Finder o Dock.
3. Considerar: cuando lances el siguiente proyecto cliente, decidir si usar el flow tradicional (`/new-project` con dashboard original) o el multi-paquete (`bash deploy.sh /ruta/`).

## Notas

- El backup defensivo previo a la migración está en `~/.pmx10-backup-20260518-115229/` por si hay que revertir.
- El commit de la migración se hizo en el sub-repo (`exports/pmx-product/.git/`), preservando todo el historial previo del repo de PM x10.
- Es un cambio reversible: si quisieras volver, `mv` de vuelta + `git checkout` de los archivos modificados + borrar los archivos nuevos creados.
