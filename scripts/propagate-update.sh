#!/usr/bin/env bash
# propagate-update.sh — atajo CLI para propagar cambios.
#
# Como en new-package, la propagacion necesita Claude Code para los
# checkpoints interactivos y resolucion de conflictos. Este script muestra
# instrucciones y verificaciones rapidas.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHITECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CYAN=$'\033[0;36m'
YELLOW=$'\033[1;33m'
GREEN=$'\033[0;32m'
NC=$'\033[0m'

SCOPE="${1:-}"

echo ""
echo -e "${GREEN}AgentArchitect — Propagar mejora${NC}"
echo "================================"
echo ""

if [ -z "$SCOPE" ]; then
    echo "Scopes validos:"
    echo "  skill | rule | knowledge | command | dashboard | supervisor-qa | template | all-core"
    echo ""
    echo "Uso: $0 <scope>"
    echo ""
fi

echo "Para propagar, ejecuta el slash command desde Claude Code:"
echo ""
echo -e "  ${CYAN}1.${NC} Abrir Claude Code en: $ARCHITECT_ROOT"
echo -e "  ${CYAN}2.${NC} Ejecutar:"
if [ -n "$SCOPE" ]; then
    echo -e "     ${YELLOW}/arc-propagate $SCOPE --dry-run${NC}"
    echo "     (revisar dry-run primero)"
    echo -e "     ${YELLOW}/arc-propagate $SCOPE --apply${NC}"
else
    echo -e "     ${YELLOW}/arc-propagate${NC}"
fi
echo ""
echo "Verifica resultado:"
echo "  cat $ARCHITECT_ROOT/changelog/propagations.md | head -50"
echo ""
echo "Para auditar conformidad tras propagar:"
echo -e "  ${YELLOW}/arc-audit${NC}"
echo ""
