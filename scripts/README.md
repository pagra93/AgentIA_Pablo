# Scripts de mantenimiento del sistema PM x10

Tres scripts disponibles:

| Script | Para qué |
|---|---|
| `upgrade-project.sh` | **Upgrade completo** de un proyecto (lo que normalmente quieres). Encadena git checkpoint + migración V2→V3 + dashboard + config. |
| `migrate-to-v3.sh` | Solo la migración de carpetas V2 → V3. Lo llama internamente `upgrade-project.sh`. |
| `../install.sh` | Reinstala los agentes, commands, skills, dashboard-template en `~/.claude/`. Una vez por máquina, no por proyecto. |

---

## upgrade-project.sh — Upgrade completo (recomendado)

Encadena en un solo comando todo lo que un proyecto vivo necesita:

1. **Git checkpoint** — commit con los cambios pendientes (red de seguridad)
2. **Migración V2 → V3** — delega a `migrate-to-v3.sh` (con backup automático)
3. **Dashboard** — copia `dashboard-template` al proyecto si no existe; actualiza archivos individuales si ya existe
4. **`pm/config.json`** — lo crea desde el template si falta
5. **Resumen** — te dice cómo arrancar el bridge

### Uso

```bash
# Dry-run (no toca nada, solo imprime)
bash /ruta/al/sistema/scripts/upgrade-project.sh --root /ruta/a/tu/proyecto

# Aplicar
bash /ruta/al/sistema/scripts/upgrade-project.sh --apply --root /ruta/a/tu/proyecto

# Sin git commit (si tu proyecto no usa git, o lo manejas tú)
bash /ruta/al/sistema/scripts/upgrade-project.sh --apply --no-git --root .

# Sin backup (no recomendado)
bash /ruta/al/sistema/scripts/upgrade-project.sh --apply --no-backup --root .
```

### Procedimiento típico para un proyecto vivo

```bash
# 1. Asegurar el sistema actualizado en ~/.claude/ (una vez)
cd "/Users/pablogranados/Desktop/PABLO/Proyectos/AgentArchitect/exports/pmx-product"
bash install.sh

# 2. Para CADA proyecto vivo:
SISTEMA="/Users/pablogranados/Desktop/PABLO/Proyectos/AgentArchitect/exports/pmx-product"

# Dry-run primero
bash "$SISTEMA/scripts/upgrade-project.sh" --root /ruta/a/proyecto

# Si te cuadra, aplicar
bash "$SISTEMA/scripts/upgrade-project.sh" --apply --root /ruta/a/proyecto

# 3. Arrancar el dashboard
cd /ruta/a/proyecto
python3 dashboard/bridge.py
# → http://localhost:7700/

# 4. En Claude Code: /pm sync para indexar tareas existentes

# 5. Si todo va bien
git add -A && git commit -m "upgrade to PM x10 V3 + dashboard V2.4"
rm -rf .pm-backup-*  # cuando estés seguro
```

### Idempotencia

El script es **idempotente**: ejecutarlo 2 veces no rompe nada. Detecta si el proyecto ya está en V3 (no migra), si el dashboard ya está actualizado (no copia), si el config.json ya existe (no sobrescribe).

### Si algo sale mal

- Backup en `.pm-backup-<timestamp>/` con todos los archivos originales
- El git commit del Step 1 te permite hacer `git reset --hard HEAD~1` para volver al estado pre-upgrade

---

## migrate-to-v3.sh — Reorganizar proyecto V2 → V3

Reorganiza un proyecto que usaba la estructura V2 (con `tasks/`, `qa/`, archivos en raíz) a la nueva estructura V3 (`pm/`, `docs/<area>/`).

### Cuándo ejecutarlo

Ejecuta este script en CADA proyecto vivo que use el sistema PM x10 antes de la versión V3.

Detecta automáticamente si el proyecto necesita migración. Si ya está en V3, no hace nada.

### Pasos recomendados (proyectos vivos en producción)

1. **Hacer commit del estado actual** del proyecto antes de migrar:
   ```bash
   cd /ruta/a/tu/proyecto
   git add -A && git commit -m "checkpoint pre-V3 migration"
   ```

2. **Probar primero con dry-run** (no toca nada, solo imprime):
   ```bash
   bash /ruta/al/repo/sistema/scripts/migrate-to-v3.sh --root .
   ```
   Revisa el output. Verifica que las acciones propuestas tienen sentido.

3. **Aplicar la migración**:
   ```bash
   bash /ruta/al/repo/sistema/scripts/migrate-to-v3.sh --apply --root .
   ```
   El script:
   - Pide confirmación (escribe `si` para continuar)
   - Crea backup automático en `.pm-backup-<timestamp>/`
   - Mueve archivos a sus nuevas rutas
   - Crea las carpetas de áreas inactivas con README

4. **Reinstalar el sistema actualizado** (compila los agentes con las rutas nuevas):
   ```bash
   cd /ruta/al/repo/sistema
   bash install.sh
   ```

5. **Verificar el dashboard** (V2.1 — solo si lo tienes instalado):
   ```bash
   cd /ruta/a/tu/proyecto
   python3 dashboard/bridge.py
   ```
   Abre `http://localhost:7700/` y comprueba que ves la estructura nueva.

6. **Si todo va bien**, commit de la migración:
   ```bash
   git add -A && git commit -m "migrate to V3 structure (cerebro digital de empresa)"
   ```

7. **Limpiar el backup** cuando estés seguro de que todo funciona:
   ```bash
   rm -rf .pm-backup-*
   ```

### Si algo sale mal

El backup en `.pm-backup-<timestamp>/` contiene los archivos originales. Para restaurar:

```bash
# Borrar las carpetas nuevas
rm -rf pm/ docs/general/ docs/producto/ docs/marketing/ docs/rrhh/ docs/operaciones/

# Restaurar desde backup
cp -R .pm-backup-<timestamp>/* .

# Volver atrás el commit (si lo hiciste)
git reset --hard HEAD~1
```

### Opciones del script

```
bash migrate-to-v3.sh                       # dry-run (default)
bash migrate-to-v3.sh --apply               # ejecutar de verdad (con backup)
bash migrate-to-v3.sh --apply --no-backup   # ejecutar sin backup (no recomendado)
bash migrate-to-v3.sh --root /otro/path     # migrar otro proyecto
bash migrate-to-v3.sh --help                # ver help
```

### Idempotencia

El script es **idempotente**: si ya está en V3 (o ya se ejecutó), no hace nada. Puedes correrlo múltiples veces sin riesgo.

### Mapeo de rutas

| V2 | V3 |
|---|---|
| `inbox.md` | `docs/producto/inbox.md` |
| `tasks.json` | `pm/tasks.json` |
| `config.json` | `pm/config.json` |
| `tasks/todo.md` | `docs/producto/sprint.md` |
| `tasks/lessons.md` | `docs/producto/lessons.md` |
| `tasks/events.jsonl` | `pm/events.jsonl` |
| `tasks/build-state.md` | `pm/build-state.md` |
| `qa/qa-report.md` | `docs/producto/qa.md` |
| `qa-reports/` | (eliminar — duplicado) |
| `docs/PROJECT_KNOWLEDGE.md` | `docs/general/PROJECT_KNOWLEDGE.md` |
| `docs/project-registry.md` | `docs/general/project-registry.md` |
| `docs/working-docs/[feature]/` | `docs/producto/features/[feature]/` |
| `docs/project-docs/` | `docs/general/exportable/` |

Lo que NO cambia: `.claude/`, `dashboard/`, `memory/`, código del usuario.
