#!/usr/bin/env bash
# new-package.sh — atajo CLI para crear un paquete nuevo.
#
# Realmente NO crea el paquete: el generator necesita el mini-discovery
# interactivo que requiere Claude Code. Este script muestra instrucciones.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHITECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CYAN=$'\033[0;36m'
YELLOW=$'\033[1;33m'
GREEN=$'\033[0;32m'
NC=$'\033[0m'

NAME="${1:-}"

echo ""
echo -e "${GREEN}AgentArchitect — Crear paquete nuevo${NC}"
echo "================================"
echo ""
echo "Para crear un paquete, ejecuta el slash command desde Claude Code:"
echo ""
echo -e "  ${CYAN}1.${NC} Abrir Claude Code en: $ARCHITECT_ROOT"
echo -e "  ${CYAN}2.${NC} Ejecutar comando:"
echo ""
if [ -n "$NAME" ]; then
    echo -e "     ${YELLOW}/arc-new-package $NAME${NC}"
else
    echo -e "     ${YELLOW}/arc-new-package${NC}"
fi
echo ""
echo "  El generator hara mini-discovery (5 preguntas) y creara"
echo "  exports/<nombre>/ con stubs de agentes previstos."
echo ""
echo "Verifica resultado: bash $SCRIPT_DIR/../scripts/arc.template list"
echo "(O instalado: arc list)"
echo ""
