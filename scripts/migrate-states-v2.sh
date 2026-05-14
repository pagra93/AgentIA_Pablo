#!/usr/bin/env bash
# migrate-states-v2.sh — Re-mapea estados viejos (V1) a nuevos (V2.0 cola de trabajo por agente).
#
# Cambia en pm/tasks.json y en frontmatter YAML de cada stories.md:
#   backlog_sin_priorizar → sin_priorizar
#   backlog_priorizado    → priorizada
#   en_analisis           → research
#   en_definicion         → definicion
#   en_planning           → planning
#   en_build              → build
#   en_testing            → review
#   hecho                 → hecho (sin cambio)
#   bloqueado             → bloqueada
#   cancelado             → cancelada
#
# También: si pm/config.json tiene "states"/"transitions" a nivel global (V1),
# los mueve a areas.producto.states/transitions y los actualiza al schema V2.0.
#
# Idempotente: si ya tiene estados nuevos, no toca.
# Backup automático. Dry-run por defecto.
#
# Uso:
#   bash migrate-states-v2.sh "/ruta/proyecto"             # dry-run
#   bash migrate-states-v2.sh "/ruta/proyecto" --apply

set -euo pipefail

APPLY=false
PROJECT_PATH=""

while [ $# -gt 0 ]; do
    case "$1" in
        --apply) APPLY=true; shift ;;
        --help|-h) sed -n '2,22p' "$0" | sed 's/^# //; s/^#//'; exit 0 ;;
        --*) echo "Argumento desconocido: $1"; exit 1 ;;
        *) PROJECT_PATH="$1"; shift ;;
    esac
done

if [ -z "$PROJECT_PATH" ] || [ ! -d "$PROJECT_PATH" ]; then
    echo "Uso: bash migrate-states-v2.sh <ruta-proyecto> [--apply]"
    exit 1
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

if [ "$APPLY" = false ]; then
    echo -e "${YELLOW}Modo dry-run.${NC} Pasa --apply para escribir.\n"
fi

python3 - "$PROJECT_PATH" "$APPLY" <<'PYEOF'
import os, sys, json, re, shutil
from datetime import datetime

project = sys.argv[1]
apply = sys.argv[2] == "true"

GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
CYAN = "\033[0;36m"
RED = "\033[0;31m"
NC = "\033[0m"

# Mapeo viejo → nuevo
STATE_MAP = {
    "backlog_sin_priorizar": "sin_priorizar",
    "backlog_priorizado":    "priorizada",
    "en_analisis":           "research",
    "en_definicion":         "definicion",
    "en_planning":           "planning",
    "en_build":              "build",
    "en_testing":            "review",
    "hecho":                 "hecho",
    "bloqueado":             "bloqueada",
    "cancelado":             "cancelada",
    # idempotencia: si ya tiene los nuevos, no cambiar
    "sin_priorizar":         "sin_priorizar",
    "priorizada":            "priorizada",
    "research":              "research",
    "definicion":            "definicion",
    "planning":              "planning",
    "build":                 "build",
    "review":                "review",
    "bloqueada":             "bloqueada",
    "cancelada":             "cancelada",
}

NEW_STATES_V2 = ["sin_priorizar", "priorizada", "research", "definicion",
                 "planning", "build", "review", "hecho", "bloqueada", "cancelada"]

# Transiciones libres V2: cada estado puede ir a cualquier otro
def free_transitions(states):
    return {s: [t for t in states if t != s] for s in states}

# ─────────────────────────────────────────────────────────────
# 1. Migrar pm/tasks.json
# ─────────────────────────────────────────────────────────────
tasks_path = os.path.join(project, "pm", "tasks.json")
tasks_changed = 0
if os.path.exists(tasks_path):
    with open(tasks_path) as f:
        td = json.load(f)
    for t in td.get("tasks", []):
        old = t.get("status")
        new = STATE_MAP.get(old, old)
        if new != old:
            t["status"] = new
            tasks_changed += 1

    if apply and tasks_changed > 0:
        backup = tasks_path + ".bak-" + datetime.now().strftime("%Y%m%d-%H%M%S")
        shutil.copy2(tasks_path, backup)
        with open(tasks_path, "w") as f:
            json.dump(td, f, indent=2, ensure_ascii=False)
        print(f"{GREEN}[tasks.json]{NC} {tasks_changed} estados migrados (backup: {os.path.basename(backup)})")
    elif tasks_changed > 0:
        print(f"{YELLOW}[tasks.json]{NC} {tasks_changed} estados a migrar (dry-run)")
    else:
        print(f"{GREEN}[tasks.json]{NC} ya tiene estados V2 (skip)")

# ─────────────────────────────────────────────────────────────
# 2. Migrar pm/config.json: mover states/transitions al área producto + schema V2
# ─────────────────────────────────────────────────────────────
cfg_path = os.path.join(project, "pm", "config.json")
cfg_changed = False
if os.path.exists(cfg_path):
    with open(cfg_path) as f:
        cfg = json.load(f)

    producto = cfg.get("areas", {}).get("producto", {})

    # Detectar si ya está en V2 (areas.producto.states existe)
    if not producto.get("states") or "research" not in (producto.get("states") or []):
        # V1 → V2
        producto["states"] = NEW_STATES_V2
        producto["state_meta"] = {
            "sin_priorizar": {"label": "Sin priorizar", "type": "tray", "command": None, "artifact": None},
            "priorizada":    {"label": "Priorizada", "type": "tray", "command": None, "artifact": None},
            "research":      {"label": "Research", "type": "agent", "agent": "age-spe-researcher", "command": "/analyze", "artifact": "research.md"},
            "definicion":    {"label": "Definición", "type": "agent", "agent": "design-analyst | story-writer | story-builder", "command": "/define", "artifact": "stories.md"},
            "planning":      {"label": "Planning", "type": "agent", "agent": "age-spe-tech-architect", "command": "/plan", "artifact": "architecture.md"},
            "build":         {"label": "Build", "type": "agent", "agent": "sub-agente de /build", "command": "/build", "artifact": "build-state.md"},
            "review":        {"label": "Review", "type": "agent", "agent": "age-spe-test-engineer + supervisores", "command": "/review", "artifact": "qa.md (aprobado)"},
            "hecho":         {"label": "Hecho", "type": "terminal", "command": None, "artifact": None},
            "bloqueada":     {"label": "Bloqueada", "type": "lateral", "command": None, "artifact": None},
            "cancelada":     {"label": "Cancelada", "type": "lateral", "command": None, "artifact": None},
        }
        producto["kanban_groups"] = {
            "main": NEW_STATES_V2[:8],
            "tray": NEW_STATES_V2[8:]
        }
        producto["transitions"] = free_transitions(NEW_STATES_V2)
        producto["_transitions_doc"] = "V2: transiciones TODAS LIBRES. Edita manualmente para restringir."
        cfg.setdefault("areas", {})["producto"] = producto

        # Limpiar campos a nivel global que ahora viven en areas.producto
        for legacy_key in ("states", "transitions", "_transitions_doc", "default_phase_agents"):
            cfg.pop(legacy_key, None)

        # Bump schema_version
        cfg["schema_version"] = "2.0.0"
        cfg_changed = True

    if apply and cfg_changed:
        backup = cfg_path + ".bak-" + datetime.now().strftime("%Y%m%d-%H%M%S")
        shutil.copy2(cfg_path, backup)
        with open(cfg_path, "w") as f:
            json.dump(cfg, f, indent=2, ensure_ascii=False)
        print(f"{GREEN}[config.json]{NC} migrado a schema V2 (backup: {os.path.basename(backup)})")
    elif cfg_changed:
        print(f"{YELLOW}[config.json]{NC} a migrar a schema V2 (dry-run)")
    else:
        print(f"{GREEN}[config.json]{NC} ya tiene schema V2 (skip)")

# ─────────────────────────────────────────────────────────────
# 3. Migrar frontmatter YAML de cada stories.md
# ─────────────────────────────────────────────────────────────
features_dir = os.path.join(project, "docs", "producto", "features")
stories_changed = 0
files_modified = 0
if os.path.isdir(features_dir):
    for feat_name in sorted(os.listdir(features_dir)):
        feat_path = os.path.join(features_dir, feat_name)
        if not os.path.isdir(feat_path) or feat_name.startswith((".", "_")):
            continue
        stories_path = os.path.join(feat_path, "stories.md")
        if not os.path.exists(stories_path):
            continue

        with open(stories_path) as f:
            content = f.read()

        original = content
        # Reemplazar status: <viejo> dentro de bloques ```yaml ... ```
        def replace_status(match):
            global stories_changed
            yaml_block = match.group(0)
            new_block = yaml_block
            for old, new in STATE_MAP.items():
                if old == new:
                    continue
                pattern = re.compile(r"^(\s*status:\s*)" + re.escape(old) + r"\s*$", re.MULTILINE)
                if pattern.search(new_block):
                    new_block = pattern.sub(r"\1" + new, new_block)
                    stories_changed += 1
            return new_block

        new_content = re.sub(
            r"```yaml\n(.*?)\n```",
            replace_status,
            content,
            flags=re.DOTALL
        )

        if new_content != original:
            if apply:
                backup = stories_path + ".bak-" + datetime.now().strftime("%Y%m%d-%H%M%S")
                shutil.copy2(stories_path, backup)
                with open(stories_path, "w") as f:
                    f.write(new_content)
            files_modified += 1
            rel = os.path.relpath(stories_path, project)
            print(f"  {GREEN if apply else YELLOW}[{'modified' if apply else 'would modify'}]{NC} {rel}")

print()
print("=" * 60)
print(f"{CYAN}Resumen:{NC}")
print(f"  tasks.json status migrados: {tasks_changed}")
print(f"  config.json schema V2: {'sí' if cfg_changed else 'ya estaba'}")
print(f"  stories.md frontmatter migrados: {stories_changed} status en {files_modified} archivos")
if not apply and (tasks_changed or cfg_changed or files_modified):
    print(f"\n{YELLOW}Re-ejecuta con --apply para escribir.{NC}")
PYEOF