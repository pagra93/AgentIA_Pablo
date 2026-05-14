---
description: "Propagar mejoras genéricas a paquetes existentes y/o proyectos clientes desplegados. Scope: skill, rule, knowledge, command, dashboard, supervisor-qa. Ejecuta age-spe-arc-propagator."
---

# /arc-propagate — Propagar mejoras genéricas

Aplica un cambio genérico (skill, rule, knowledge, comando transversal, código del dashboard, supervisor QA) a todos los paquetes existentes y a todos los proyectos clientes registrados donde un paquete esté desplegado.

**La fuente de verdad** es `AgentArchitect/` (sus skills, rules, knowledge, comandos transversales, `templates/package-template/`, `templates/project-template/dashboard/`). Los destinos son `exports/*/` y proyectos clientes externos.

**Tipo de operación**: write (modifica archivos en paquetes y proyectos clientes, hace commits opcionales).

## Sintaxis

```
/arc-propagate                           → diálogo interactivo (pregunta qué y dónde)
/arc-propagate <scope>                   → con scope explícito, sigue con confirmaciones
/arc-propagate <scope> --dry-run         → muestra qué cambiaría sin tocar nada
/arc-propagate <scope> --apply           → aplica sin más confirmaciones (riesgo)
/arc-propagate <scope> --to=<paquete>    → solo a un paquete concreto
/arc-propagate <scope> --commit-each     → hace commit en cada paquete tras aplicar
```

## Scopes válidos

- `skill` — un archivo o carpeta dentro de `skills/`
- `rule` — un archivo dentro de `rules/`
- `knowledge` — un archivo dentro de `knowledge/`
- `command` — un comando transversal dentro de `commands/` (NO los `/arc-*`, esos solo viven en el arquitecto)
- `dashboard` — los 4 archivos canónicos en `templates/project-template/dashboard/` (`bridge.py`, `index.html`, `styles.css`, `app.js`)
- `supervisor-qa` — un agente supervisor copiado al `package-template/agents/` (auditor, evaluator, optimizer, cynic, boundary-walker)
- `template` — cambios estructurales en `templates/package-template/` (raros, requieren confirmación extra)
- `all-core` — todo lo listado en `config/core-manifest.yaml` (modo "sincronizar todo")

## Modos

### `/arc-propagate` (interactivo)

Diálogo guiado:

1. ¿Qué scope vas a propagar? (lista)
2. ¿Qué archivo concreto cambió? (resolver path)
3. ¿A qué destinos? (todos los paquetes, todos los proyectos clientes, ambos, subset)
4. ¿Dry-run primero? (recomendado)
5. Confirmación final antes de aplicar

### `/arc-propagate <scope> --dry-run`

Muestra:

- Archivos fuente que se propagarían
- Destinos (paquetes y/o proyectos clientes) donde aplicaría
- Diff por destino (qué se sobrescribiría)
- Detección de conflictos (archivos modificados localmente en algún destino que NO coinciden con la versión esperada del template)

NO toca nada. El PM revisa y luego ejecuta con `--apply`.

### `/arc-propagate <scope> --apply`

Aplica. Por cada destino:

1. Copia archivo(s) del template al destino
2. Si hay conflicto (ya descrito en `core-manifest.yaml` qué hacer): aplica estrategia configurada (`overwrite`, `prompt`, `preserve`)
3. Registra entrada en `changelog/propagations.md` del arquitecto
4. Si `--commit-each`: ejecuta `git add -A && git commit -m "chore: propagate <scope> from architect"` en el sub-repo del paquete o proyecto

### Propagación a proyectos clientes (`scope=dashboard`)

Caso especial — afecta a paths fuera de `AgentArchitect/`:

1. Lee `~/.claude/projects-registry.txt` (mantenido por `deploy.sh` de cada paquete; lista los proyectos clientes donde se ha desplegado algún paquete del arquitecto)
2. Para cada proyecto registrado: copia el código del dashboard a `<proyecto>/dashboard/`
3. **NUNCA toca** `<proyecto>/dashboard/sections/*.yaml` (config local) ni `<proyecto>/pm/config.json` (config local)
4. Reporta agregado: N proyectos actualizados, M sin cambios (ya estaban al día), K con conflicto local manual

## Reglas de operación

- **`config/core-manifest.yaml` es ley.** El propagator solo toca archivos listados ahí. Si quieres propagar algo no listado, primero añádelo al manifest (decisión consciente).
- **Idempotencia.** Ejecutar el propagator dos veces con el mismo cambio no causa daño. Detecta archivos ya iguales y los marca como `[identical]`.
- **Trazabilidad.** Cada aplicación deja entrada en `changelog/propagations.md`: timestamp, scope, archivos, destinos, conflictos.
- **No commit automático por defecto.** El PM hace commit cuando esté contento con el resultado. Excepción: `--commit-each` lo automatiza para usuarios avanzados.

## Después de ejecutar

- Revisar `changelog/propagations.md` para ver qué se aplicó
- En cada paquete tocado, hacer `git diff` para ver los cambios concretos antes de commitear
- Si el PM detecta que un paquete necesita variante específica (la propagación rompe algo), revertir en ese paquete con `git checkout` del archivo y documentar en `exports/<paquete>/context-ledger/` por qué diverge

## Limitaciones

- **No propaga lógica específica de un paquete.** Si una mejora en el `DUTIES.md` de un agente del paquete tiene sentido en varios paquetes, eso NO se propaga automáticamente — sería violación de `rul-scope-boundaries`. El PM debe extraer lo genérico a una skill/knowledge transversal y propagar ESA.
- **No propaga al `~/.claude/` global.** Esto lo hace `install.sh` de cada paquete (o el del arquitecto), no el propagator.
- **Conflictos requieren intervención humana.** Si un paquete tiene un archivo core modificado localmente, el propagator NO sobrescribe sin confirmación explícita.
