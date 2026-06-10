#!/usr/bin/env bash
# migrate-to-v3.sh — Reorganiza un proyecto PM x10 de estructura V2 → V3.
#
# - Por defecto: --dry-run (solo imprime, no toca nada).
# - Para ejecutar de verdad: --apply
# - Idempotente: ejecutar dos veces no rompe nada.
# - Crea backup en .pm-backup-<timestamp>/ antes de mover (cuando --apply).
#
# Uso:
#   bash migrate-to-v3.sh                  # dry-run
#   bash migrate-to-v3.sh --apply          # ejecuta
#   bash migrate-to-v3.sh --apply --no-backup  # ejecuta sin backup
#   bash migrate-to-v3.sh --root /path/to/proyecto

set -euo pipefail

# ─────── Parsing args ───────
APPLY=false
NO_BACKUP=false
ROOT="."
while [ $# -gt 0 ]; do
    case "$1" in
        --apply) APPLY=true; shift ;;
        --no-backup) NO_BACKUP=true; shift ;;
        --root) ROOT="$2"; shift 2 ;;
        --help|-h)
            sed -n '2,15p' "$0" | sed 's/^# //; s/^#//'
            exit 0
            ;;
        *) echo "Argumento desconocido: $1"; exit 1 ;;
    esac
done

ROOT=$(cd "$ROOT" && pwd)
cd "$ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# ─────── Detectar si necesita migración ───────
needs_migration() {
    [ -f "inbox.md" ] || \
    [ -f "tasks.json" ] || \
    [ -f "config.json" ] || \
    [ -d "tasks" ] || \
    [ -d "qa" ] || \
    [ -d "qa-reports" ] || \
    [ -f "docs/PROJECT_KNOWLEDGE.md" ] || \
    [ -f "docs/project-registry.md" ] || \
    [ -d "docs/working-docs" ] || \
    [ -d "docs/working_docs" ] || \
    [ -d "docs/project-docs" ]
}

if ! needs_migration; then
    echo -e "${GREEN}Este proyecto ya está en V3 (o no es un proyecto PM x10). No hay nada que migrar.${NC}"
    exit 0
fi

# ─────── Banner ───────
echo ""
echo -e "${CYAN}════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Migración PM x10 — Estructura V2 → V3${NC}"
echo -e "${CYAN}════════════════════════════════════════════${NC}"
echo ""
echo "Proyecto: $ROOT"
if $APPLY; then
    echo -e "Modo:     ${RED}APPLY${NC} (cambios reales al filesystem)"
else
    echo -e "Modo:     ${YELLOW}DRY-RUN${NC} (solo imprime, no toca nada)"
fi
echo ""

# ─────── Función: mover si existe ───────
mv_if_exists() {
    local src="$1"
    local dst="$2"
    if [ -e "$src" ]; then
        if [ -e "$dst" ]; then
            echo -e "  ${YELLOW}[skip]${NC}    $src → $dst (destino ya existe)"
            return
        fi
        if $APPLY; then
            mkdir -p "$(dirname "$dst")"
            mv "$src" "$dst"
            echo -e "  ${GREEN}[moved]${NC}   $src → $dst"
        else
            echo -e "  ${CYAN}[would]${NC}   $src → $dst"
        fi
    fi
}

# ─────── Función: mover contenido de carpeta ───────
mv_dir_contents() {
    local src="$1"
    local dst="$2"
    if [ -d "$src" ]; then
        if $APPLY; then
            mkdir -p "$dst"
            local moved=0
            for item in "$src"/*; do
                [ -e "$item" ] || continue
                local name=$(basename "$item")
                if [ -e "$dst/$name" ]; then
                    echo -e "  ${YELLOW}[skip]${NC}    $item → $dst/$name (destino ya existe)"
                else
                    mv "$item" "$dst/"
                    echo -e "  ${GREEN}[moved]${NC}   $item → $dst/$name"
                    moved=1
                fi
            done
            # Eliminar carpeta vacía
            rmdir "$src" 2>/dev/null && echo -e "  ${GREEN}[rmdir]${NC}   $src/ (vacía)"
        else
            for item in "$src"/*; do
                [ -e "$item" ] || continue
                echo -e "  ${CYAN}[would]${NC}   $item → $dst/$(basename "$item")"
            done
        fi
    fi
}

# ─────── Backup (solo en --apply) ───────
if $APPLY && ! $NO_BACKUP; then
    TS=$(date +%Y%m%d-%H%M%S)
    BACKUP_DIR=".pm-backup-$TS"
    echo -e "${CYAN}Creando backup en $BACKUP_DIR/...${NC}"
    mkdir -p "$BACKUP_DIR"
    for f in inbox.md tasks.json config.json; do
        [ -f "$f" ] && cp "$f" "$BACKUP_DIR/"
    done
    for d in tasks qa qa-reports docs; do
        [ -d "$d" ] && cp -R "$d" "$BACKUP_DIR/" 2>/dev/null || true
    done
    echo -e "${GREEN}Backup completo. Si algo sale mal, restaura desde $BACKUP_DIR/${NC}"
    echo ""
fi

# ─────── Confirmar antes de aplicar ───────
if $APPLY; then
    echo -e "${YELLOW}¿Continuar con la migración? (escribe 'si' para confirmar):${NC} "
    read -r CONFIRM
    if [ "$CONFIRM" != "si" ]; then
        echo -e "${RED}Cancelado.${NC}"
        exit 1
    fi
    echo ""
fi

# ─────── Crear nueva estructura de carpetas ───────
echo -e "${CYAN}1. Creando carpetas nuevas...${NC}"
for d in pm docs/general docs/general/exportable docs/producto docs/producto/features docs/marketing docs/rrhh docs/operaciones; do
    if [ ! -d "$d" ]; then
        if $APPLY; then
            mkdir -p "$d"
            echo -e "  ${GREEN}[mkdir]${NC}   $d/"
        else
            echo -e "  ${CYAN}[would]${NC}   mkdir -p $d/"
        fi
    fi
done
echo ""

# ─────── Mover archivos a pm/ ───────
echo -e "${CYAN}2. Moviendo estado operativo a pm/...${NC}"
mv_if_exists "tasks.json"            "pm/tasks.json"
mv_if_exists "config.json"           "pm/config.json"
mv_if_exists "tasks/events.jsonl"    "pm/events.jsonl"
mv_if_exists "tasks/build-state.md"  "pm/build-state.md"
echo ""

# ─────── Mover archivos a docs/producto/ ───────
echo -e "${CYAN}3. Moviendo archivos de Producto a docs/producto/...${NC}"
mv_if_exists "inbox.md"              "docs/producto/inbox.md"
mv_if_exists "tasks/todo.md"         "docs/producto/sprint.md"
mv_if_exists "tasks/lessons.md"      "docs/producto/lessons.md"
mv_if_exists "qa/qa-report.md"       "docs/producto/qa.md"
mv_if_exists "qa-reports/qa-report.md" "docs/producto/qa.md"
echo ""

# ─────── Mover docs cross-área a docs/general/ ───────
echo -e "${CYAN}4. Moviendo docs cross-área a docs/general/...${NC}"
mv_if_exists "docs/PROJECT_KNOWLEDGE.md" "docs/general/PROJECT_KNOWLEDGE.md"
mv_if_exists "docs/project-registry.md"  "docs/general/project-registry.md"
echo ""

# ─────── Mover features ───────
echo -e "${CYAN}5. Moviendo features a docs/producto/features/...${NC}"
mv_dir_contents "docs/working-docs"   "docs/producto/features"
mv_dir_contents "docs/working_docs"   "docs/producto/features"
echo ""

# ─────── Mover docs públicos exportables ───────
echo -e "${CYAN}6. Moviendo docs exportables a docs/general/exportable/...${NC}"
mv_dir_contents "docs/project-docs"   "docs/general/exportable"
echo ""

# ─────── Limpiar carpetas vacías ───────
echo -e "${CYAN}7. Limpiando carpetas vacías...${NC}"
for d in tasks qa qa-reports docs/working-docs docs/working_docs docs/project-docs; do
    if [ -d "$d" ] && [ -z "$(ls -A "$d" 2>/dev/null)" ]; then
        if $APPLY; then
            rmdir "$d"
            echo -e "  ${GREEN}[rmdir]${NC}   $d/"
        else
            echo -e "  ${CYAN}[would]${NC}   rmdir $d/"
        fi
    fi
done
echo ""

# ─────── Crear READMEs en áreas inactivas ───────
echo -e "${CYAN}8. Creando READMEs en áreas inactivas...${NC}"
for area in marketing rrhh operaciones; do
    target="docs/$area/README.md"
    if [ ! -f "$target" ]; then
        if $APPLY; then
            cat > "$target" <<EOF
# Área: $area

Esta área está preparada pero **no activada**.

Para activarla:
1. Edita \`pm/config.json\` y cambia \`areas.$area.active\` a \`true\`
2. Crea el agente PM correspondiente (\`age-spe-pm-$area\`) con sus propios estados
3. El dashboard la mostrará al recargar

Mientras tanto, este área aparece en el sidebar del dashboard como "sin activar".
EOF
            echo -e "  ${GREEN}[wrote]${NC}   $target"
        else
            echo -e "  ${CYAN}[would]${NC}   write $target"
        fi
    fi
done
echo ""

# ─────── Resumen ───────
echo -e "${CYAN}════════════════════════════════════════════${NC}"
if $APPLY; then
    echo -e "${GREEN}Migración completa.${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "  1. Reinstalar el sistema actualizado: cd <repo-pm-x10> && bash install.sh"
    echo "  2. Verificar que el dashboard funciona: python3 dashboard/bridge.py"
    echo "  3. Si algo sale mal, restaura desde el backup en .pm-backup-*/"
else
    echo -e "${YELLOW}Esto fue dry-run. Para aplicar de verdad:${NC}"
    echo "  bash $0 --apply"
fi
echo -e "${CYAN}════════════════════════════════════════════${NC}"
echo ""
