#!/usr/bin/env bash
# pmx-product (PM x10) — Deploy
#
# Despliega PM x10 en un proyecto cliente como pestaña del dashboard multi-paquete
# del arquitecto. Equivalente "first-class" al /new-project clásico de PM x10.
#
# NOTA: PM x10 tiene un flow tradicional via /new-project (desde Claude Code) que
# crea la estructura COMPLETA de PM x10 con su dashboard original. Este deploy.sh
# es para el modelo MULTI-PAQUETE del arquitecto: añade una pestaña 'Producto' al
# dashboard multi-paquete del proyecto sin tocar lo demás. Si quieres el flow
# completo de PM x10, ejecuta /new-project después.
#
# Que hace este script:
# 1. Si el proyecto NO tiene estructura todavia: la materializa desde
#    templates/project-template/ del arquitecto (dashboard multi-paquete, pm/config.json, etc.)
# 2. Crea docs/producto/ con la estructura del dominio
# 3. Anade 'pmx-product' a pm/config.json (deployed_packages)
# 4. Copia dashboard-section.yaml -> proyecto/dashboard/sections/pmx-product-section.yaml
# 5. Registra el deployment en ~/.claude/projects-registry.txt
#
# Idempotente: ejecutar dos veces no rompe nada ni duplica.
#
# Usage:
#   bash deploy.sh /ruta/al/proyecto-cliente
#   bash deploy.sh /ruta/al/proyecto-cliente --dry-run
#   bash deploy.sh /ruta/al/proyecto-cliente --force-update

set -euo pipefail

PACKAGE_NAME="pmx-product"
PREFIX="pmx"
DOMAIN="product-management"
DOMAIN_FOLDER="producto"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# El package esta en .../AgentArchitect/exports/<paquete>/, asi que el arquitecto es ../..
ARCHITECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECT_TEMPLATE_DIR="$ARCHITECT_DIR/templates/project-template"

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
    echo ""
    echo "Tip: si quieres el flow completo de PM x10 (dashboard original, estructura PM),"
    echo "ejecuta /new-project desde Claude Code en el proyecto cliente en lugar de este script."
    exit 1
fi

# Validacion: ruta no peligrosa
if [[ "$TARGET_PROJECT" == *".."* ]] || [[ "$TARGET_PROJECT" == "/" ]] || [[ "$TARGET_PROJECT" == "$HOME" ]]; then
    echo -e "${RED}Error:${NC} ruta no permitida: $TARGET_PROJECT"
    exit 1
fi

if [ -d "$TARGET_PROJECT" ]; then
    TARGET_PROJECT="$(cd "$TARGET_PROJECT" && pwd)"
else
    echo -e "${RED}Error:${NC} la ruta no existe o no es directorio: $TARGET_PROJECT"
    exit 1
fi

if [ ! -d "$PROJECT_TEMPLATE_DIR" ]; then
    echo -e "${RED}Error:${NC} no se encuentra templates/project-template/ del arquitecto en $PROJECT_TEMPLATE_DIR"
    echo "Este paquete debe vivir bajo AgentArchitect/exports/ para que deploy.sh funcione."
    exit 1
fi

echo ""
echo -e "${GREEN}pmx-product (PM x10) — Deploy${NC}"
echo "================================"
echo "Source:           $SCRIPT_DIR"
echo "Target proyecto:  $TARGET_PROJECT"
echo "Project template: $PROJECT_TEMPLATE_DIR"
echo "Domain folder:    $DOMAIN_FOLDER"
echo "Dry-run:          $DRY_RUN"
echo ""

# Helper
do_action() {
    local action_desc="$1"
    shift
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[dry-run]${NC} $action_desc"
    else
        "$@" && echo -e "  ${GREEN}[done]${NC} $action_desc"
    fi
}

# ============================================
# 1. MATERIALIZAR PROYECTO SI NO EXISTE
# ============================================
PROJECT_INITIALIZED=false
if [ ! -d "$TARGET_PROJECT/dashboard" ] || [ ! -d "$TARGET_PROJECT/pm" ]; then
    echo -e "${CYAN}Proyecto no inicializado todavia. Materializando estructura desde project-template...${NC}"
    PROJECT_INITIALIZED=true

    for subdir in .claude pm memory dashboard; do
        if [ ! -d "$TARGET_PROJECT/$subdir" ]; then
            do_action "Crear $subdir/" mkdir -p "$TARGET_PROJECT/$subdir"
        fi
    done
    do_action "Crear docs/" mkdir -p "$TARGET_PROJECT/docs"

    # Materializar archivos del project-template con sustitucion de placeholders runtime
    # Nota: project-template usa __PROJECT_NAME__ / __DATE__ (no {{...}}).
    project_name=$(basename "$TARGET_PROJECT")
    today=$(date +%Y-%m-%d)

    materialize_tmpl() {
        local src="$1"
        local dest="$2"
        if [ -f "$src" ]; then
            if [ "$DRY_RUN" = false ]; then
                sed "s|__PROJECT_NAME__|$project_name|g; s|__DATE__|$today|g" "$src" > "$dest"
                echo -e "  ${GREEN}[done]${NC} Materializar $(basename "$dest")"
            else
                echo -e "  ${YELLOW}[dry-run]${NC} Materializar $(basename "$dest")"
            fi
        fi
    }

    materialize_tmpl "$PROJECT_TEMPLATE_DIR/.claude/CLAUDE.md.tmpl" "$TARGET_PROJECT/.claude/CLAUDE.md"
    materialize_tmpl "$PROJECT_TEMPLATE_DIR/pm/config.json.tmpl"    "$TARGET_PROJECT/pm/config.json"
    materialize_tmpl "$PROJECT_TEMPLATE_DIR/pm/tasks.json.tmpl"     "$TARGET_PROJECT/pm/tasks.json"
    materialize_tmpl "$PROJECT_TEMPLATE_DIR/memory/MEMORY.md.tmpl"  "$TARGET_PROJECT/memory/MEMORY.md"

    # Copiar codigo del dashboard multi-paquete (4 archivos canonicos)
    for dashfile in bridge.py index.html styles.css app.js; do
        if [ -f "$PROJECT_TEMPLATE_DIR/dashboard/$dashfile" ]; then
            do_action "Copiar dashboard/$dashfile" \
                cp "$PROJECT_TEMPLATE_DIR/dashboard/$dashfile" "$TARGET_PROJECT/dashboard/$dashfile"
        fi
    done
    do_action "Crear dashboard/sections/" mkdir -p "$TARGET_PROJECT/dashboard/sections"
fi

# ============================================
# 2. CREAR docs/producto/ DEL PAQUETE
# ============================================
DOMAIN_DOCS_DIR="$TARGET_PROJECT/docs/$DOMAIN_FOLDER"
if [ ! -d "$DOMAIN_DOCS_DIR" ]; then
    echo -e "${CYAN}Creando docs/${DOMAIN_FOLDER}/ en el proyecto...${NC}"
    do_action "Crear docs/$DOMAIN_FOLDER/" mkdir -p "$DOMAIN_DOCS_DIR"

    if [ "$DRY_RUN" = false ]; then
        cat > "$DOMAIN_DOCS_DIR/README.md" <<EOF
# ${DOMAIN_FOLDER}/

Documentos del paquete **${PACKAGE_NAME}** (dominio: ${DOMAIN}).

Estructura tipica de un proyecto PM x10:
- inbox.md          ← buzon de ideas/peticiones
- sprint.md         ← sprint actual (kanban de stories)
- lessons.md        ← lecciones aprendidas
- features/         ← una carpeta por feature
    - <feature-name>/
        - stories.md
        - jtbds.md
        - prd.md
        - architecture.md
        - research.md

Si prefieres el flow completo de PM x10 con dashboard original (no multi-paquete),
ejecuta \`/new-project\` desde Claude Code en este proyecto.
EOF
        echo -e "  ${GREEN}[done]${NC} Crear docs/$DOMAIN_FOLDER/README.md"
    fi
fi

# ============================================
# 3. ANADIR PAQUETE A pm/config.json DEL PROYECTO
# ============================================
CONFIG_JSON="$TARGET_PROJECT/pm/config.json"
if [ -f "$CONFIG_JSON" ]; then
    if grep -q "\"$PACKAGE_NAME\"" "$CONFIG_JSON"; then
        if [ "$FORCE_UPDATE" = false ]; then
            echo -e "${YELLOW}Paquete ya desplegado segun pm/config.json. Use --force-update para refrescar.${NC}"
        fi
    else
        echo -e "${CYAN}Anadiendo ${PACKAGE_NAME} a deployed_packages en pm/config.json...${NC}"
        if [ "$DRY_RUN" = false ]; then
            python3 - <<PYTHON_SCRIPT
import json
path = "$CONFIG_JSON"
package_name = "$PACKAGE_NAME"
with open(path, "r") as f:
    data = json.load(f)
if package_name not in data.get("deployed_packages", []):
    data.setdefault("deployed_packages", []).append(package_name)
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
PYTHON_SCRIPT
            echo -e "  ${GREEN}[done]${NC} Anadido a pm/config.json"
        else
            echo -e "  ${YELLOW}[dry-run]${NC} Anadir a pm/config.json"
        fi
    fi
fi

# ============================================
# 4. COPIAR DASHBOARD-SECTION.YAML
# ============================================
SECTIONS_DIR="$TARGET_PROJECT/dashboard/sections"
SECTION_DEST="$SECTIONS_DIR/${PACKAGE_NAME}-section.yaml"
if [ -f "$SCRIPT_DIR/dashboard-section.yaml" ]; then
    if [ ! -d "$SECTIONS_DIR" ]; then
        do_action "Crear dashboard/sections/" mkdir -p "$SECTIONS_DIR"
    fi
    if [ -f "$SECTION_DEST" ] && [ "$FORCE_UPDATE" = false ]; then
        echo -e "${YELLOW}dashboard/sections/${PACKAGE_NAME}-section.yaml ya existe. Use --force-update para refrescar.${NC}"
    else
        do_action "Copiar dashboard-section.yaml a $SECTION_DEST" \
            cp "$SCRIPT_DIR/dashboard-section.yaml" "$SECTION_DEST"
    fi
else
    echo -e "${YELLOW}Warning:${NC} dashboard-section.yaml no encontrado en el paquete."
fi

# ============================================
# 5. REGISTRAR DEPLOYMENT EN ~/.claude/projects-registry.txt
# ============================================
PROJECTS_REGISTRY="$HOME/.claude/projects-registry.txt"
if [ "$DRY_RUN" = false ]; then
    if ! grep -q "^${TARGET_PROJECT}|${PACKAGE_NAME}|" "$PROJECTS_REGISTRY" 2>/dev/null; then
        echo "${TARGET_PROJECT}|${PACKAGE_NAME}|$(date -u +%Y-%m-%dT%H:%M:%S%z)" >> "$PROJECTS_REGISTRY"
        echo -e "${CYAN}Registrado en ~/.claude/projects-registry.txt${NC}"
    fi
fi

# ============================================
# SUMMARY
# ============================================
echo ""
echo "================================"
echo -e "${GREEN}Deploy ${PACKAGE_NAME} en ${TARGET_PROJECT}: complete!${NC}"
echo ""

if [ "$PROJECT_INITIALIZED" = true ]; then
    echo -e "${CYAN}Proyecto inicializado desde project-template (multi-paquete).${NC}"
fi

echo -e "${CYAN}Que tienes ahora:${NC}"
echo "  - docs/${DOMAIN_FOLDER}/        (carpeta para artefactos del dominio ${DOMAIN})"
echo "  - dashboard/sections/${PACKAGE_NAME}-section.yaml (pestaña 'Producto' del dashboard)"
echo "  - pm/config.json incluye '${PACKAGE_NAME}' en deployed_packages"
echo ""
echo -e "${CYAN}Proximos pasos:${NC}"
echo "  1. Arrancar el dashboard multi-paquete del proyecto:"
echo "     cd '$TARGET_PROJECT' && python3 dashboard/bridge.py"
echo "  2. Usar los comandos /pm, /define, /build, etc. del paquete PM x10 desde Claude Code"
echo "  3. Empezar a trabajar en docs/${DOMAIN_FOLDER}/"
echo ""
echo -e "${YELLOW}Nota:${NC} este deploy crea estructura minima compatible con el modelo multi-paquete."
echo "Si quieres el flow original de PM x10 (dashboard ORIGINAL, estructura completa con templates,"
echo "tasks/, qa/, etc.), ejecuta /new-project desde Claude Code en este proyecto."
echo ""
