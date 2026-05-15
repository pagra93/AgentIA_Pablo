#!/usr/bin/env bash
# audit-drift.sh — verificacion rapida de drift sin invocar Claude Code.
#
# Comprueba checksum SHA256 de archivos core en cada paquete contra el template.
# Util como check rapido pre-/arc-audit completo desde terminal.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHITECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
RED=$'\033[0;31m'
NC=$'\033[0m'

TEMPLATE_DIR="$ARCHITECT_ROOT/templates/package-template"
EXPORTS_DIR="$ARCHITECT_ROOT/exports"

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo -e "${RED}Error:${NC} template no encontrado en $TEMPLATE_DIR"
    exit 1
fi

if [ ! -d "$EXPORTS_DIR" ]; then
    echo -e "${YELLOW}No hay exports/ todavia. Nada que auditar.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}AgentArchitect — Drift check rapido${NC}"
echo "================================"
echo ""
echo "Compara checksum de archivos core en cada paquete vs template canonico."
echo "Para audit completo: /arc-audit desde Claude Code."
echo ""

# Archivos core a chequear (subset del core-manifest, lo más importante)
CORE_FILES=(
    "skills/ski-plan-mode/SKILL.md"
    "skills/ski-context-ledger/SKILL.md"
    "skills/ski-mini-discovery/SKILL.md"
    "rules/rul-spanish-orthography.md"
    "rules/rul-scope-boundaries.md"
    "rules/rul-lazy-loading.md"
    "knowledge/kno-elicitation-methods.md"
)

# Por cada paquete en exports/
for pkg_dir in "$EXPORTS_DIR"/*/; do
    [ -d "$pkg_dir" ] || continue
    pkg_name=$(basename "$pkg_dir")
    [ "$pkg_name" = "template" ] && continue

    echo -e "${CYAN}═══ Paquete: $pkg_name ═══${NC}"

    ok_count=0
    drift_count=0
    missing_count=0

    for core_file in "${CORE_FILES[@]}"; do
        local_path="$pkg_dir/$core_file"
        template_path="$TEMPLATE_DIR/$core_file"

        if [ ! -f "$template_path" ]; then
            # Template no tiene el archivo (raro, ignorar)
            continue
        fi

        if [ ! -f "$local_path" ]; then
            echo -e "  ${RED}[MISSING]${NC} $core_file"
            missing_count=$((missing_count + 1))
            continue
        fi

        local_hash=$(shasum -a 256 "$local_path" | cut -d' ' -f1)
        template_hash=$(shasum -a 256 "$template_path" | cut -d' ' -f1)

        if [ "$local_hash" = "$template_hash" ]; then
            echo -e "  ${GREEN}[OK]${NC} $core_file"
            ok_count=$((ok_count + 1))
        else
            echo -e "  ${YELLOW}[DRIFT]${NC} $core_file (checksum distinto al template)"
            drift_count=$((drift_count + 1))
        fi
    done

    echo "  Resumen: $ok_count OK · $drift_count drift · $missing_count missing"
    echo ""
done

echo -e "${CYAN}Drift check completado.${NC}"
echo ""
echo "Para audit completo (8 checks + reportes): /arc-audit desde Claude Code."
echo ""
