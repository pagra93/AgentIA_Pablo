#!/usr/bin/env bash
# update-dashboards.sh — Actualiza el dashboard/ en TODOS los proyectos PM x10 vivos.
#
# Detecta proyectos PM x10 bajo $HOME (busca pm/config.json + dashboard/bridge.py)
# y copia los 4 archivos (bridge.py, index.html, styles.css, app.js) desde
# ~/.claude/dashboard-template/ si difieren.
#
# Por defecto: --dry-run (solo lista qué actualizaría).
# Idempotente: si todo está al día, no hace nada.
#
# Uso:
#   bash update-dashboards.sh                  # dry-run
#   bash update-dashboards.sh --apply          # ejecuta
#   bash update-dashboards.sh --apply --search /ruta  # custom search root (default $HOME)

set -euo pipefail

APPLY=false
SEARCH_ROOT="$HOME"
EXPLICIT_PATHS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --apply) APPLY=true; shift ;;
        --search) SEARCH_ROOT="$2"; shift 2 ;;
        --help|-h)
            sed -n '2,16p' "$0" | sed 's/^# //; s/^#//'
            exit 0
            ;;
        --*) echo "Argumento desconocido: $1"; exit 1 ;;
        *) EXPLICIT_PATHS+=("$1"); shift ;;
    esac
done

# Lista de proyectos en ~/.claude/pm-projects.txt (uno por línea)
# Útil cuando macOS TCC bloquea find recursivo en Desktop/Documents.
PROJECTS_LIST="$HOME/.claude/pm-projects.txt"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

TEMPLATE_DIR="$HOME/.claude/dashboard-template"
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo -e "${RED}No existe $TEMPLATE_DIR${NC}"
    echo "Ejecuta primero: cd <repo-pm-x10> && bash install.sh"
    exit 1
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Mass-update del dashboard a proyectos PM x10${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
echo "Template:   $TEMPLATE_DIR"
echo "Buscando:   $SEARCH_ROOT"
if $APPLY; then
    echo -e "Modo:       ${RED}APPLY${NC}"
else
    echo -e "Modo:       ${YELLOW}DRY-RUN${NC}"
fi
echo ""

# Buscar proyectos: PM x10 = tienen pm/config.json Y dashboard/bridge.py
echo -e "${CYAN}Detectando proyectos...${NC}"
projects=()

# Fuente 1: paths explícitos pasados como argumento
for p in "${EXPLICIT_PATHS[@]:-}"; do
    [ -z "$p" ] && continue
    abs=$(cd "$p" 2>/dev/null && pwd) || { echo -e "  ${RED}[skip]${NC} $p (no existe)"; continue; }
    if [ -f "$abs/pm/config.json" ] && [ -f "$abs/dashboard/bridge.py" ]; then
        projects+=("$abs")
    else
        echo -e "  ${YELLOW}[skip]${NC} $abs (no es proyecto PM x10 — falta pm/config.json o dashboard/bridge.py)"
    fi
done

# Fuente 2: archivo de lista persistente
if [ -f "$PROJECTS_LIST" ]; then
    while IFS= read -r line; do
        [ -z "$line" ] || [[ "$line" =~ ^# ]] && continue
        # Expandir ~ si lo tiene
        path="${line/#\~/$HOME}"
        if [ -f "$path/pm/config.json" ] && [ -f "$path/dashboard/bridge.py" ]; then
            # Evitar duplicados
            already=false
            for existing in "${projects[@]:-}"; do
                [ "$existing" = "$path" ] && already=true && break
            done
            $already || projects+=("$path")
        fi
    done < "$PROJECTS_LIST"
fi

# Fuente 3: búsqueda recursiva (puede fallar en macOS TCC bajo Desktop/Documents)
while IFS= read -r -d '' bridge; do
    proj_dir="$(dirname "$(dirname "$bridge")")"
    if [ -f "$proj_dir/pm/config.json" ]; then
        already=false
        for existing in "${projects[@]}"; do
            [ "$existing" = "$proj_dir" ] && already=true && break
        done
        $already || projects+=("$proj_dir")
    fi
done < <(find "$SEARCH_ROOT" -maxdepth 8 \
    -name "bridge.py" \
    -path "*/dashboard/bridge.py" \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/.pm-backup-*" \
    -not -path "$HOME/.claude/*" \
    -print0 2>/dev/null)

if [ ${#projects[@]} -eq 0 ]; then
    echo -e "  ${YELLOW}No se encontraron proyectos PM x10.${NC}"
    echo ""
    echo "Opciones:"
    echo "  1. Pasa los paths como argumento:"
    echo "     bash $0 --apply /ruta/a/proyecto1 /ruta/a/proyecto2"
    echo ""
    echo "  2. Crea $PROJECTS_LIST (uno por línea):"
    echo "     mkdir -p ~/.claude && cat >> ~/.claude/pm-projects.txt <<EOF"
    echo "     /Users/usuario/path/a/proyecto1"
    echo "     /Users/usuario/path/a/proyecto2"
    echo "     EOF"
    echo ""
    echo "  Nota macOS: find recursivo bajo Desktop/Documents/Downloads requiere"
    echo "  Full Disk Access para el terminal en System Preferences > Privacy."
    exit 0
fi

echo -e "  ${GREEN}Encontrados ${#projects[@]} proyecto(s):${NC}"
for p in "${projects[@]}"; do
    echo "    · $(basename "$p")  ($p)"
done
echo ""

# Comparar y actualizar
total_updated=0
total_identical=0
for proj in "${projects[@]}"; do
    name=$(basename "$proj")
    echo -e "${CYAN}─── $name ───${NC}"
    updated_in_proj=0
    for f in bridge.py index.html styles.css app.js; do
        src="$TEMPLATE_DIR/$f"
        dst="$proj/dashboard/$f"
        if [ ! -f "$src" ]; then
            continue
        fi
        if [ ! -f "$dst" ] || ! diff -q "$src" "$dst" > /dev/null 2>&1; then
            if $APPLY; then
                cp "$src" "$dst"
                echo -e "  ${GREEN}[updated]${NC} dashboard/$f"
            else
                echo -e "  ${CYAN}[would]${NC}  dashboard/$f"
            fi
            updated_in_proj=$((updated_in_proj+1))
        fi
    done
    if [ $updated_in_proj -eq 0 ]; then
        echo -e "  ${GREEN}[ok]${NC} dashboard ya está al día"
        total_identical=$((total_identical+1))
    else
        total_updated=$((total_updated+1))
    fi
    echo ""
done

# Summary
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
if $APPLY; then
    echo -e "${GREEN}Actualizado en $total_updated proyecto(s).${NC} $total_identical ya estaban al día."
    if [ $total_updated -gt 0 ]; then
        echo ""
        echo "Recarga el dashboard en cada proyecto (Cmd+Shift+R en el navegador)."
    fi
else
    echo -e "${YELLOW}Esto fue dry-run. Para aplicar:${NC}"
    echo "  bash $0 --apply"
fi
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
