#!/usr/bin/env bash
# upgrade-project.sh — Upgrade completo de un proyecto PM x10 a V3 + dashboard V2.4
#
# Encadena en un solo comando:
#   1. git commit checkpoint (si hay repo git con cambios)
#   2. Migración de estructura V2 → V3 (delega a migrate-to-v3.sh)
#   3. Copia/actualiza dashboard/ desde dashboard-template
#   4. Asegura pm/config.json (lo crea desde template si falta)
#   5. Verifica python3 y muestra el comando para arrancar el bridge
#
# Por defecto: --dry-run (solo imprime, no toca nada).
# Idempotente: ejecutar dos veces no rompe nada.
#
# Uso:
#   bash upgrade-project.sh                       # dry-run sobre cwd
#   bash upgrade-project.sh --apply               # ejecutar
#   bash upgrade-project.sh --apply --root /path  # otro directorio
#   bash upgrade-project.sh --apply --no-git      # no crear commit checkpoint
#   bash upgrade-project.sh --apply --no-backup   # pasar --no-backup a migrate

set -euo pipefail

# ─────── Detectar paths del sistema ───────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MIGRATE_SCRIPT="$SCRIPT_DIR/migrate-to-v3.sh"
DASHBOARD_TEMPLATE_REPO="$SYSTEM_ROOT/dashboard-template"
DASHBOARD_TEMPLATE_INSTALLED="$HOME/.claude/dashboard-template"
CONFIG_TEMPLATE="$SYSTEM_ROOT/templates/config-template.json"

# ─────── Parsing args ───────
APPLY=false
PROJECT_ROOT="."
NO_GIT=false
NO_BACKUP=false
while [ $# -gt 0 ]; do
    case "$1" in
        --apply) APPLY=true; shift ;;
        --root) PROJECT_ROOT="$2"; shift 2 ;;
        --no-git) NO_GIT=true; shift ;;
        --no-backup) NO_BACKUP=true; shift ;;
        --help|-h)
            sed -n '2,21p' "$0" | sed 's/^# //; s/^#//'
            exit 0
            ;;
        *) echo "Argumento desconocido: $1"; exit 1 ;;
    esac
done

PROJECT_ROOT=$(cd "$PROJECT_ROOT" && pwd)
cd "$PROJECT_ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# ─────── Sanity checks ───────
is_pmx10_project() {
    [ -f .claude/CLAUDE.md ] || \
    [ -d pm ] || \
    [ -d docs/producto ] || \
    [ -f tasks.json ] || \
    [ -f docs/PROJECT_KNOWLEDGE.md ] || \
    [ -f docs/general/PROJECT_KNOWLEDGE.md ] || \
    [ -d docs/working-docs ] || \
    [ -d docs/working_docs ]
}

if ! is_pmx10_project; then
    echo -e "${RED}Esto no parece un proyecto PM x10.${NC}"
    echo "Buscaba alguno de estos marcadores en $PROJECT_ROOT:"
    echo "  .claude/CLAUDE.md, pm/, docs/producto/, tasks.json,"
    echo "  docs/(general/)PROJECT_KNOWLEDGE.md, docs/working-docs/"
    echo ""
    echo "Si quieres inicializar un proyecto NUEVO, usa /new-project en Claude Code."
    exit 1
fi

if [ ! -f "$MIGRATE_SCRIPT" ]; then
    echo -e "${RED}No encuentro migrate-to-v3.sh en $SCRIPT_DIR${NC}"
    echo "¿Estás ejecutando este script desde el repo del sistema PM x10?"
    exit 1
fi

# ─────── Banner ───────
echo ""
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Upgrade proyecto PM x10 → V3 + dashboard V2.4${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
echo "Sistema:  $SYSTEM_ROOT"
echo "Proyecto: $PROJECT_ROOT"
if $APPLY; then
    echo -e "Modo:     ${RED}APPLY${NC} (cambios reales al filesystem)"
else
    echo -e "Modo:     ${YELLOW}DRY-RUN${NC} (solo imprime, no toca nada)"
fi
echo ""

# ─────── Verificar python3 ───────
if command -v python3 >/dev/null 2>&1; then
    PY_VER=$(python3 --version 2>&1)
    echo -e "${GREEN}python3 disponible: $PY_VER${NC}"
else
    echo -e "${YELLOW}WARN: python3 no encontrado. El dashboard no podrá arrancar hasta instalarlo.${NC}"
fi
echo ""

# ─────── Step 1: Git checkpoint ───────
echo -e "${CYAN}Step 1: Git checkpoint${NC}"
if $NO_GIT; then
    echo "  Saltado por --no-git"
elif [ ! -d .git ]; then
    echo "  No hay repo git en este proyecto. Saltando."
elif [ -z "$(git status --porcelain 2>/dev/null)" ]; then
    echo "  Working tree limpio. Nada que commitear."
else
    if $APPLY; then
        git add -A
        git commit -m "checkpoint pre-V3 upgrade (PM x10)" >/dev/null
        SHA=$(git rev-parse --short HEAD)
        echo -e "  ${GREEN}[committed]${NC} $SHA"
    else
        CHANGES=$(git status --porcelain | wc -l | tr -d ' ')
        echo -e "  ${CYAN}[would]${NC} git commit con $CHANGES cambios pendientes"
    fi
fi
echo ""

# ─────── Step 2: migrate-to-v3 ───────
echo -e "${CYAN}Step 2: Migrar estructura V2 → V3${NC}"
MIGRATE_ARGS=("--root" "$PROJECT_ROOT")
if $APPLY; then
    MIGRATE_ARGS+=("--apply")
    if $NO_BACKUP; then
        MIGRATE_ARGS+=("--no-backup")
    fi
fi
# Auto-confirmar 'si' si --apply (ya hicimos checkpoint git)
if $APPLY; then
    echo "si" | bash "$MIGRATE_SCRIPT" "${MIGRATE_ARGS[@]}" | sed 's/^/  /'
else
    bash "$MIGRATE_SCRIPT" "${MIGRATE_ARGS[@]}" | sed 's/^/  /'
fi
echo ""

# ─────── Step 3: Copiar / actualizar dashboard ───────
echo -e "${CYAN}Step 3: Dashboard${NC}"
# Preferir dashboard-template del repo (puede ser más nuevo que el instalado en ~/.claude/)
SOURCE_DASHBOARD=""
if [ -d "$DASHBOARD_TEMPLATE_REPO" ]; then
    SOURCE_DASHBOARD="$DASHBOARD_TEMPLATE_REPO"
elif [ -d "$DASHBOARD_TEMPLATE_INSTALLED" ]; then
    SOURCE_DASHBOARD="$DASHBOARD_TEMPLATE_INSTALLED"
fi

if [ -z "$SOURCE_DASHBOARD" ]; then
    echo -e "  ${YELLOW}WARN: no hay dashboard-template ni en $DASHBOARD_TEMPLATE_REPO${NC}"
    echo -e "  ${YELLOW}     ni en $DASHBOARD_TEMPLATE_INSTALLED${NC}"
    echo -e "  ${YELLOW}     Ejecuta primero: cd $SYSTEM_ROOT && bash install.sh${NC}"
else
    if [ ! -d dashboard ]; then
        if $APPLY; then
            cp -R "$SOURCE_DASHBOARD" dashboard
            echo -e "  ${GREEN}[copied]${NC} $SOURCE_DASHBOARD → dashboard/"
        else
            echo -e "  ${CYAN}[would]${NC} cp -R $SOURCE_DASHBOARD → dashboard/"
        fi
    else
        # Ya existe: comparar y actualizar archivos individuales (preserva permisos)
        UPDATED=0
        for f in bridge.py index.html styles.css app.js; do
            src="$SOURCE_DASHBOARD/$f"
            dst="dashboard/$f"
            if [ -f "$src" ]; then
                if [ ! -f "$dst" ] || ! diff -q "$src" "$dst" >/dev/null 2>&1; then
                    if $APPLY; then
                        cp "$src" "$dst"
                        echo -e "  ${GREEN}[updated]${NC} dashboard/$f"
                    else
                        echo -e "  ${CYAN}[would]${NC} cp dashboard/$f"
                    fi
                    UPDATED=$((UPDATED+1))
                fi
            fi
        done
        if [ $UPDATED -eq 0 ]; then
            echo "  Dashboard ya está actualizado."
        fi
    fi
fi
echo ""

# ─────── Step 4: pm/config.json ───────
echo -e "${CYAN}Step 4: pm/config.json${NC}"
if [ -f pm/config.json ]; then
    echo "  Ya existe pm/config.json. Sin cambios."
elif [ ! -f "$CONFIG_TEMPLATE" ]; then
    echo -e "  ${YELLOW}WARN: no hay templates/config-template.json en el repo del sistema${NC}"
else
    if $APPLY; then
        mkdir -p pm
        cp "$CONFIG_TEMPLATE" pm/config.json
        echo -e "  ${GREEN}[created]${NC} pm/config.json desde template"
    else
        echo -e "  ${CYAN}[would]${NC} cp templates/config-template.json → pm/config.json"
    fi
fi
echo ""

# ─────── Step 5: Resumen + comando final ───────
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
if $APPLY; then
    echo -e "${GREEN}Upgrade completo.${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "  1. Arrancar el dashboard:"
    echo "       cd $PROJECT_ROOT"
    echo "       python3 dashboard/bridge.py"
    echo "     → http://localhost:7700/"
    echo ""
    echo "  2. En Claude Code, ejecutar /pm sync para indexar las tareas existentes."
    echo ""
    echo "  3. Si todo va bien, commit:"
    echo "       git add -A && git commit -m \"upgrade to PM x10 V3 + dashboard V2.4\""
    echo "       rm -rf .pm-backup-*  # solo cuando estés seguro"
else
    echo -e "${YELLOW}Esto fue dry-run. Para aplicar de verdad:${NC}"
    echo "  bash $0 --apply --root $PROJECT_ROOT"
fi
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
