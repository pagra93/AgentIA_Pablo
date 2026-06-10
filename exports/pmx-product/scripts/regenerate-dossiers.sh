#!/usr/bin/env bash
# regenerate-dossiers.sh — Genera _dossier.md retroactivos en proyectos PM x10 existentes.
#
# Para cada feature folder bajo docs/producto/features/<feature>/, genera un
# _dossier.md MÍNIMO (esqueleto del template) si no existe, para que Claude Code
# tenga algo que renderizar y luego /pm dossier lo enriquezca con cada comando.
#
# Por defecto: --dry-run (solo lista qué crearía).
# Idempotente: si _dossier.md ya existe, NO lo sobrescribe.
#
# Uso:
#   bash regenerate-dossiers.sh /ruta/proyecto                  # dry-run
#   bash regenerate-dossiers.sh /ruta/proyecto --apply          # ejecuta
#   bash regenerate-dossiers.sh /ruta1 /ruta2 --apply           # múltiples
#
# Nota: este script genera el ESQUELETO. El llenado real lo hace
# age-spe-pm-producto via /pm dossier all desde Claude Code (lee artefactos
# de la feature y rellena las secciones AUTO).

set -euo pipefail

APPLY=false
PROJECT_PATHS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --apply) APPLY=true; shift ;;
        --help|-h)
            sed -n '2,18p' "$0" | sed 's/^# //; s/^#//'
            exit 0
            ;;
        --*) echo "Argumento desconocido: $1"; exit 1 ;;
        *) PROJECT_PATHS+=("$1"); shift ;;
    esac
done

if [ ${#PROJECT_PATHS[@]} -eq 0 ]; then
    echo "Uso: bash regenerate-dossiers.sh /ruta/proyecto [--apply]"
    echo "     bash regenerate-dossiers.sh --help"
    exit 1
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

TEMPLATE="$HOME/.claude/templates/feature-dossier-template.md"
if [ ! -f "$TEMPLATE" ]; then
    # Fallback al template en el repo del sistema
    REPO_TEMPLATE="$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")/../templates/feature-dossier-template.md"
    if [ -f "$REPO_TEMPLATE" ]; then
        TEMPLATE="$REPO_TEMPLATE"
    else
        echo -e "${RED}Error:${NC} template no encontrado en:"
        echo "  $HOME/.claude/templates/feature-dossier-template.md"
        echo "  $REPO_TEMPLATE"
        echo "Ejecuta 'bash install.sh' desde el repo del sistema PM x10 primero."
        exit 1
    fi
fi

if [ "$APPLY" = false ]; then
    echo -e "${YELLOW}Modo dry-run.${NC} Pasa --apply para ejecutar."
    echo ""
fi

TOTAL_CREATED=0
TOTAL_SKIPPED=0
TOTAL_NO_FEATURES=0

for PROJECT in "${PROJECT_PATHS[@]}"; do
    if [ ! -d "$PROJECT" ]; then
        echo -e "${RED}✗${NC} No existe: $PROJECT"
        continue
    fi
    FEATURES_DIR="$PROJECT/docs/producto/features"
    if [ ! -d "$FEATURES_DIR" ]; then
        echo -e "${YELLOW}~${NC} Sin features/: $PROJECT"
        TOTAL_NO_FEATURES=$((TOTAL_NO_FEATURES+1))
        continue
    fi

    PROJECT_NAME=$(basename "$PROJECT")
    echo -e "${CYAN}📁 $PROJECT_NAME${NC} ($PROJECT)"

    CREATED=0
    SKIPPED=0
    for FEAT_PATH in "$FEATURES_DIR"/*/; do
        [ -d "$FEAT_PATH" ] || continue
        FEAT_NAME=$(basename "$FEAT_PATH")
        # Skip carpetas que empiezan con _ o .
        case "$FEAT_NAME" in
            _*|.*) continue ;;
        esac
        DOSSIER_PATH="${FEAT_PATH}_dossier.md"
        if [ -f "$DOSSIER_PATH" ]; then
            echo -e "  ${GREEN}[skip]${NC} $FEAT_NAME (ya tiene _dossier.md)"
            SKIPPED=$((SKIPPED+1))
            continue
        fi
        if [ "$APPLY" = true ]; then
            # Detectar título del feature (usa el slug capitalizado)
            FEAT_TITLE=$(echo "$FEAT_NAME" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
            # Generar dossier con placeholders del template
            sed -e "s|{{ENTITY_ID}}|$FEAT_NAME|g" \
                -e "s|{{FEATURE_TITLE}}|$FEAT_TITLE|g" \
                -e "s|{{LAST_UPDATED_ISO}}|$(date -u +%Y-%m-%dT%H:%M:%SZ)|g" \
                "$TEMPLATE" > "$DOSSIER_PATH"
            # Crear _events.jsonl vacío con un comentario inicial
            EVENTS_PATH="${FEAT_PATH}_events.jsonl"
            if [ ! -f "$EVENTS_PATH" ]; then
                echo '{"_comment":"Timeline append-only por feature. Ver ~/.claude/templates/feature-events-jsonl-schema.md"}' > "$EVENTS_PATH"
                echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"agent\":\"migrate\",\"event\":\"dossier_created_retroactive\",\"summary\":\"Esqueleto creado por regenerate-dossiers.sh\",\"entity\":\"$FEAT_NAME\"}" >> "$EVENTS_PATH"
            fi
            echo -e "  ${GREEN}[created]${NC} $FEAT_NAME"
        else
            echo -e "  ${YELLOW}[would create]${NC} $FEAT_NAME"
        fi
        CREATED=$((CREATED+1))
    done
    TOTAL_CREATED=$((TOTAL_CREATED+CREATED))
    TOTAL_SKIPPED=$((TOTAL_SKIPPED+SKIPPED))
    echo -e "  Subtotal: $CREATED creados, $SKIPPED ya existían"
    echo ""
done

echo "================================"
if [ "$APPLY" = true ]; then
    echo -e "${GREEN}✓ Done.${NC} $TOTAL_CREATED dossiers creados, $TOTAL_SKIPPED ya existían."
    echo ""
    echo "Siguiente paso: abre Claude Code en cada proyecto y ejecuta:"
    echo "  /pm dossier all"
    echo "Esto rellena los esqueletos con la información real de cada feature."
else
    echo -e "${YELLOW}Dry-run.${NC} $TOTAL_CREATED dossiers se crearían."
    echo "Re-ejecuta con --apply para aplicar."
fi