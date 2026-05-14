#!/usr/bin/env bash
# add-story-frontmatter.sh — Añade frontmatter YAML retroactivo a stories.md de proyectos existentes.
#
# Para cada `## HU-XXX: Título` que NO tenga ya un bloque ```yaml``` debajo,
# añade uno mínimo derivando los campos del path + pm/tasks.json.
#
# Idempotente: si una story YA tiene frontmatter, se respeta y no se toca.
# Backup automático antes de cualquier escritura.
# Por defecto: --dry-run.
#
# Uso:
#   bash add-story-frontmatter.sh "/ruta/proyecto"             # dry-run
#   bash add-story-frontmatter.sh "/ruta/proyecto" --apply     # ejecuta
#
# Lo que añade a cada story sin frontmatter:
#   id: HU-XXX                              (extraído del título)
#   parent_epic: EPIC-YYY                   (de pm/tasks.json buscando por feature)
#   feature: <slug>                         (nombre de la carpeta padre)
#   status: <status actual>                 (de pm/tasks.json o "en_definicion")
#   origin: design                          (asunción: si no había frontmatter, vino de design-to-prd legacy)
#   created_at: <mtime del archivo>         (ISO 8601)

set -euo pipefail

APPLY=false
PROJECT_PATH=""

while [ $# -gt 0 ]; do
    case "$1" in
        --apply) APPLY=true; shift ;;
        --help|-h)
            sed -n '2,21p' "$0" | sed 's/^# //; s/^#//'
            exit 0
            ;;
        --*) echo "Argumento desconocido: $1"; exit 1 ;;
        *) PROJECT_PATH="$1"; shift ;;
    esac
done

if [ -z "$PROJECT_PATH" ]; then
    echo "Uso: bash add-story-frontmatter.sh <ruta-proyecto> [--apply]"
    exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "Error: no existe $PROJECT_PATH"
    exit 1
fi

FEATURES_DIR="$PROJECT_PATH/docs/producto/features"
if [ ! -d "$FEATURES_DIR" ]; then
    echo "Sin features/: $PROJECT_PATH"
    exit 0
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ "$APPLY" = false ]; then
    echo -e "${YELLOW}Modo dry-run.${NC} Pasa --apply para escribir."
    echo ""
fi

# Procesar con Python (parseo YAML/JSON robusto)
python3 - "$PROJECT_PATH" "$APPLY" <<'PYEOF'
import os, sys, json, re, shutil
from datetime import datetime, timezone

project = sys.argv[1]
apply = sys.argv[2] == "true"
features_dir = os.path.join(project, "docs", "producto", "features")
tasks_path = os.path.join(project, "pm", "tasks.json")

GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
CYAN = "\033[0;36m"
RED = "\033[0;31m"
NC = "\033[0m"

# Cargar tasks.json para derivar parent_epic y status
tasks_by_id = {}
epic_by_feature = {}
if os.path.exists(tasks_path):
    with open(tasks_path) as f:
        td = json.load(f)
    for t in td.get("tasks", []):
        tid = t.get("id")
        if tid:
            tasks_by_id[tid] = t
        if t.get("type") == "epic" and t.get("feature"):
            epic_by_feature[t["feature"]] = t.get("id")

# Patron de detección del título
title_re = re.compile(r'^##\s+(HU-\d+)(?:\s*:\s*(.*))?$', re.MULTILINE)

def iso_now():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def iso_from_mtime(path):
    mt = os.path.getmtime(path)
    return datetime.fromtimestamp(mt, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

total_files = 0
total_stories_seen = 0
total_added = 0
total_skipped_has_yaml = 0
total_modified_files = []

if not os.path.isdir(features_dir):
    print(f"Sin features/: {project}")
    sys.exit(0)

for feat_name in sorted(os.listdir(features_dir)):
    feat_path = os.path.join(features_dir, feat_name)
    if not os.path.isdir(feat_path) or feat_name.startswith((".", "_")):
        continue
    stories_path = os.path.join(feat_path, "stories.md")
    if not os.path.exists(stories_path):
        continue
    total_files += 1

    with open(stories_path) as f:
        content = f.read()

    # Encontrar todos los ## HU-XXX:
    matches = list(title_re.finditer(content))
    if not matches:
        continue

    parent_epic = epic_by_feature.get(feat_name, f"EPIC-???")
    file_mtime_iso = iso_from_mtime(stories_path)

    # Procesar de atrás hacia adelante para no desplazar offsets
    new_content = content
    modifications_this_file = 0
    for m in reversed(matches):
        hu_id = m.group(1)
        title = (m.group(2) or "").strip()
        total_stories_seen += 1

        # Posición justo después del título (incluye \n)
        insert_pos = m.end()
        # Saltar el \n si existe
        if insert_pos < len(new_content) and new_content[insert_pos] == '\n':
            insert_pos += 1

        # Mirar lo que viene después: ¿ya hay un ```yaml ?
        snippet = new_content[insert_pos:insert_pos + 200].lstrip()
        if snippet.startswith("```yaml"):
            total_skipped_has_yaml += 1
            continue

        # Sacar status real de tasks.json si existe
        status = tasks_by_id.get(hu_id, {}).get("status", "en_definicion")
        task_data = tasks_by_id.get(hu_id, {})
        task_parent = task_data.get("parent_id") or parent_epic
        agent_sug = task_data.get("agent_suggested") or "tech-architect"
        created_at = task_data.get("created_at") or file_mtime_iso

        # Construir bloque YAML
        yaml_block = f"""
```yaml
id: {hu_id}
parent_epic: {task_parent}
feature: {feat_name}
status: {status}
origin: design
agent_suggested: {agent_sug}
criticality: medium
depends_on: []
blocked: false
priority: null
platform: null
category: null
created_at: {created_at}
```

"""
        new_content = new_content[:insert_pos] + yaml_block + new_content[insert_pos:]
        modifications_this_file += 1
        total_added += 1

    if modifications_this_file > 0:
        rel_path = os.path.relpath(stories_path, project)
        if apply:
            backup = stories_path + ".bak-" + datetime.now().strftime("%Y%m%d-%H%M%S")
            shutil.copy2(stories_path, backup)
            with open(stories_path, "w") as f:
                f.write(new_content)
            print(f"  {GREEN}[modified]{NC} {rel_path} (+{modifications_this_file} frontmatters, backup: {os.path.basename(backup)})")
        else:
            print(f"  {YELLOW}[would modify]{NC} {rel_path} (+{modifications_this_file} frontmatters)")
        total_modified_files.append(rel_path)

print()
print("=" * 60)
print(f"{CYAN}Resumen:{NC}")
print(f"  stories.md escaneados: {total_files}")
print(f"  Stories totales: {total_stories_seen}")
print(f"  Frontmatters {'añadidos' if apply else 'a añadir'}: {total_added}")
print(f"  Stories ya con YAML (skipped): {total_skipped_has_yaml}")
print(f"  Archivos modificados: {len(total_modified_files)}")
if not apply and total_added > 0:
    print()
    print(f"{YELLOW}Re-ejecuta con --apply para escribir.{NC}")
PYEOF