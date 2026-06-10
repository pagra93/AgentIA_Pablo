#!/usr/bin/env bash
# newsletter-system — Deploy
#
# Despliega este paquete en un proyecto cliente. NO instala dashboard propio:
# el dashboard del proyecto es el de PM x10 (instalado por pmx-product) y este
# script solo AÑADE un area "newsletter" a pm/config.json > areas. El sidebar
# del dashboard renderiza la nueva area automaticamente.
#
# REQUIERE que pmx-product este desplegado primero. Si no lo esta, este script
# aborta con error claro indicando que ejecutes pmx-product antes.
#
# Idempotente: ejecutar dos veces no rompe nada ni duplica.
#
# Usage:
#   bash deploy.sh /ruta/al/proyecto-cliente
#   bash deploy.sh . --dry-run
#   bash deploy.sh /ruta/al/proyecto-cliente --force-update

set -euo pipefail

PACKAGE_NAME="newsletter-system"
AREA_ID="newsletter"
AREA_LABEL="Newsletter"
DOMAIN_FOLDER="newsletter"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
RED=$'\033[0;31m'
NC=$'\033[0m'

# --- Parse args ---
TARGET_PROJECT="${1:-}"
DRY_RUN=false
FORCE_UPDATE=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --force-update) FORCE_UPDATE=true ;;
    esac
done

if [ -z "$TARGET_PROJECT" ]; then
    echo -e "${RED}Error:${NC} falta ruta del proyecto cliente."
    echo "Usage: bash deploy.sh /ruta/al/proyecto-cliente [--dry-run] [--force-update]"
    exit 1
fi

# Validacion ruta peligrosa
if [[ "$TARGET_PROJECT" == *".."* ]] || [ "$TARGET_PROJECT" = "/" ] || [ "$TARGET_PROJECT" = "$HOME" ]; then
    echo -e "${RED}Error:${NC} ruta no permitida: $TARGET_PROJECT"
    exit 1
fi

if [ ! -d "$TARGET_PROJECT" ]; then
    echo -e "${RED}Error:${NC} la ruta no existe: $TARGET_PROJECT"
    echo "newsletter-system requiere un proyecto YA inicializado con pmx-product."
    echo "Si es un proyecto nuevo: ejecuta primero 'arc deploy pmx-product .' y despues este."
    exit 1
fi
TARGET_PROJECT="$(cd "$TARGET_PROJECT" && pwd)"

# ============================================
# 0. VERIFICAR QUE PMX-PRODUCT ESTA DESPLEGADO
# ============================================
echo ""
echo -e "${GREEN}newsletter-system — Deploy${NC}"
echo "============================================"
echo "Target proyecto:  $TARGET_PROJECT"
echo "Area que añade:   $AREA_ID (label: $AREA_LABEL)"
echo "Domain folder:    docs/$DOMAIN_FOLDER/"
echo "Dry-run:          $DRY_RUN"
echo ""

if [ ! -f "$TARGET_PROJECT/pm/config.json" ] || [ ! -f "$TARGET_PROJECT/dashboard/bridge.py" ]; then
    echo -e "${RED}Error:${NC} este proyecto NO tiene pmx-product (PM x10) desplegado."
    echo ""
    echo "newsletter-system depende del dashboard y la estructura V3 que aporta PM x10."
    echo "Despliega primero pmx-product:"
    echo ""
    echo "  arc deploy pmx-product '$TARGET_PROJECT'"
    echo ""
    echo "Y despues vuelve a ejecutar este deploy."
    exit 1
fi

echo -e "${GREEN}pmx-product detectado en el proyecto. Procediendo...${NC}"
echo ""

# --- Helpers ---
do_action() {
    local desc="$1"
    shift
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[dry-run]${NC} $desc"
    else
        "$@" && echo -e "  ${GREEN}[done]${NC} $desc"
    fi
}

# ============================================
# 1. CREAR docs/newsletter/ DEL DOMINIO
# ============================================
echo -e "${CYAN}1. Crear docs/$DOMAIN_FOLDER/ del dominio...${NC}"

DOMAIN_DIR="$TARGET_PROJECT/docs/$DOMAIN_FOLDER"
if [ ! -d "$DOMAIN_DIR" ]; then
    do_action "Crear docs/$DOMAIN_FOLDER/" mkdir -p "$DOMAIN_DIR"
fi

# Subcarpetas del dominio newsletter
for sub in issues sources drafts; do
    if [ ! -d "$DOMAIN_DIR/$sub" ]; then
        do_action "Crear docs/$DOMAIN_FOLDER/$sub/" mkdir -p "$DOMAIN_DIR/$sub"
    fi
done

# README del dominio
if [ ! -f "$DOMAIN_DIR/README.md" ] || [ "$FORCE_UPDATE" = true ]; then
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[dry-run]${NC} Crear docs/$DOMAIN_FOLDER/README.md"
    else
        cat > "$DOMAIN_DIR/README.md" <<EOF
# Newsletter — $(basename "$TARGET_PROJECT")

Carpeta del area **newsletter** (paquete: newsletter-system, dominio: editorial-content).

Flujo principal: research -> outline -> draft -> edit -> publish.

## Estructura

- \`issues/\` — números de la newsletter publicados (uno por archivo, ej. 2026-W21.md)
- \`sources/\` — fuentes investigadas (artículos, citas, estudios)
- \`drafts/\` — borradores en proceso

## Comandos disponibles

(Los comandos /news-* se documentan en cada agente del paquete: \`age-spe-news-topic-researcher\`, \`age-spe-news-outline-architect\`, \`age-spe-news-editorial-writer\`, \`age-spe-news-headline-architect\`, \`age-spe-news-content-curator\`, \`age-spe-news-editor-in-chief\`. Algunos son stubs y requieren implementacion.)

## Dashboard

Esta area aparece como pestaña "Newsletter" en el sidebar del dashboard. Para arrancar el dashboard:

\`\`\`bash
cd '$TARGET_PROJECT'
python3 dashboard/bridge.py
\`\`\`
EOF
        echo -e "  ${GREEN}[done]${NC} Crear docs/$DOMAIN_FOLDER/README.md"
    fi
else
    echo -e "  ${YELLOW}[exists]${NC} docs/$DOMAIN_FOLDER/README.md"
fi

# ============================================
# 2. AÑADIR AREA A pm/config.json > areas (con states + transitions + state_meta)
# ============================================
echo ""
echo -e "${CYAN}2. Añadir area '$AREA_ID' a pm/config.json > areas (con pipeline editorial)...${NC}"

CONFIG_JSON="$TARGET_PROJECT/pm/config.json"

if [ "$DRY_RUN" = true ]; then
    echo -e "  ${YELLOW}[dry-run]${NC} Añadir areas.$AREA_ID a $CONFIG_JSON (con states/transitions/state_meta)"
else
    python3 - <<PYTHON_SCRIPT
import json, sys
path = "$CONFIG_JSON"
area_id = "$AREA_ID"
area_label = "$AREA_LABEL"
domain_folder = "$DOMAIN_FOLDER"
force = "$FORCE_UPDATE" == "true"

# Pipeline editorial de newsletter: idea -> research -> outline -> draft -> edit -> publish
# + tray archivado. Estados y mapeo a agentes basados en exports/newsletter-system/agent.yaml.
NEWSLETTER_AREA = {
    "label": area_label,
    "active": True,
    "paths": [f"docs/{domain_folder}"],
    "pm_agent": f"age-spe-pm-{area_id}",  # no existe todavia, se creara cuando hagan falta sub-tabs avanzadas
    "states": ["idea", "research", "outline", "draft", "edit", "publish", "archivado"],
    "transitions": {
        "idea":      ["research", "outline", "draft", "edit", "publish", "archivado"],
        "research":  ["idea", "outline", "draft", "edit", "publish", "archivado"],
        "outline":   ["idea", "research", "draft", "edit", "publish", "archivado"],
        "draft":     ["idea", "research", "outline", "edit", "publish", "archivado"],
        "edit":      ["idea", "research", "outline", "draft", "publish", "archivado"],
        "publish":   ["idea", "research", "outline", "draft", "edit", "archivado"],
        "archivado": ["idea", "research", "outline", "draft", "edit", "publish"]
    },
    "state_meta": {
        "idea":      {"label": "Idea",     "type": "tray",  "agent": None, "command": None},
        "research":  {"label": "Research", "type": "agent", "agent": "age-spe-news-topic-researcher | age-spe-news-content-curator", "command": "/news-research"},
        "outline":   {"label": "Outline",  "type": "agent", "agent": "age-spe-news-outline-architect", "command": "/news-outline"},
        "draft":     {"label": "Draft",    "type": "agent", "agent": "age-spe-news-editorial-writer | age-spe-news-headline-architect", "command": "/news-draft"},
        "edit":      {"label": "Edit",     "type": "agent", "agent": "age-spe-news-editor-in-chief", "command": "/news-edit"},
        "publish":   {"label": "Publish",  "type": "terminal", "agent": None, "command": None},
        "archivado": {"label": "Archivado", "type": "tray", "agent": None, "command": None}
    }
}

with open(path, "r") as f:
    data = json.load(f)

areas = data.setdefault("areas", {})
if area_id in areas and not force:
    print(f"  [exists] areas.{area_id} ya esta en pm/config.json (use --force-update para refrescar)")
else:
    areas[area_id] = NEWSLETTER_AREA
    with open(path, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"  [done] areas.{area_id} añadida con 7 estados (idea/research/outline/draft/edit/publish/archivado)")
PYTHON_SCRIPT
fi

# ============================================
# 2b. CREAR pm/tasks-newsletter.json (vacio)
# ============================================
echo ""
echo -e "${CYAN}2b. Crear pm/tasks-$AREA_ID.json (archivo de tasks especifico del area)...${NC}"

TASKS_JSON="$TARGET_PROJECT/pm/tasks-$AREA_ID.json"
if [ -f "$TASKS_JSON" ] && [ "$FORCE_UPDATE" = false ]; then
    echo -e "  ${YELLOW}[exists]${NC} pm/tasks-$AREA_ID.json (use --force-update para reinicializar)"
elif [ "$DRY_RUN" = true ]; then
    echo -e "  ${YELLOW}[dry-run]${NC} Crear pm/tasks-$AREA_ID.json"
else
    cat > "$TASKS_JSON" <<EOF
{
  "schema_version": "1.0.0",
  "area": "$AREA_ID",
  "last_indexed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "tasks": [],
  "drift_warnings": []
}
EOF
    echo -e "  ${GREEN}[done]${NC} pm/tasks-$AREA_ID.json creado (vacio, listo para añadir tareas)"
fi

# ============================================
# 3. REGISTRAR EN ~/.claude/projects-registry.txt
# ============================================
PROJECTS_REGISTRY="$HOME/.claude/projects-registry.txt"
if [ "$DRY_RUN" = false ]; then
    if ! grep -q "^${TARGET_PROJECT}|${PACKAGE_NAME}|" "$PROJECTS_REGISTRY" 2>/dev/null; then
        echo "${TARGET_PROJECT}|${PACKAGE_NAME}|$(date -u +%Y-%m-%dT%H:%M:%S%z)" >> "$PROJECTS_REGISTRY"
        echo ""
        echo -e "${CYAN}Registrado en ~/.claude/projects-registry.txt${NC}"
    fi
fi

# ============================================
# SUMMARY
# ============================================
echo ""
echo "============================================"
echo -e "${GREEN}Deploy ${PACKAGE_NAME} en ${TARGET_PROJECT}: COMPLETO${NC}"
echo ""
echo -e "${CYAN}Que tienes ahora:${NC}"
echo "  - docs/$DOMAIN_FOLDER/{issues,sources,drafts}/ con README del dominio"
echo "  - Area 'newsletter' añadida a pm/config.json > areas"
echo "  - El dashboard de PM x10 (V3.4+) detecta nuevas areas en pm/config.json e inyecta"
echo "    boton de sidebar + section view dinamicamente. Si tu dashboard es < V3.4,"
echo "    necesitas refrescar el codigo del dashboard primero:"
echo "      arc deploy pmx-product '$TARGET_PROJECT' --force-update"
echo "    (Esto solo actualiza los 4 archivos de dashboard/ sin tocar tu contenido.)"
echo ""
echo -e "${CYAN}Para arrancar el dashboard (si no esta ya corriendo):${NC}"
echo "  cd '$TARGET_PROJECT'"
echo "  python3 dashboard/bridge.py"
echo ""
echo -e "${CYAN}Para empezar a trabajar:${NC}"
echo "  abre Claude Code en este proyecto y usa los comandos /news-* del paquete."
echo "  (Algunos agentes son stubs todavia — ver agents/age-spe-news-*/DUTIES.md)"
echo ""
