#!/usr/bin/env bash
# clone-all-exports.sh — clona todos los sub-repos de paquetes en exports/.
#
# Cada paquete tiene su propio repo Git anidado. Este script lee exports/README.md
# (catalogo del cataloger) o consulta el remoto de cada paquete si tienen origin
# configurado, y los clona en una maquina nueva.
#
# Util cuando empiezas en una maquina limpia: clonas el arquitecto y luego este
# script trae todos los paquetes asociados.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHITECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXPORTS_DIR="$ARCHITECT_ROOT/exports"

CYAN=$'\033[0;36m'
YELLOW=$'\033[1;33m'
GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
NC=$'\033[0m'

echo ""
echo -e "${GREEN}AgentArchitect — Clone all exports${NC}"
echo "================================"
echo ""

mkdir -p "$EXPORTS_DIR"

# Estado actual: que paquetes ya existen localmente
echo -e "${CYAN}Paquetes detectados localmente:${NC}"
local_count=0
for d in "$EXPORTS_DIR"/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    [ "$name" = "template" ] && continue
    echo "  - $name"
    local_count=$((local_count + 1))
done
if [ $local_count -eq 0 ]; then
    echo "  (ninguno)"
fi
echo ""

# Si existe exports/README.md, leer ahí las URLs de los repos (si las hay)
if [ -f "$EXPORTS_DIR/README.md" ]; then
    echo -e "${CYAN}Buscando URLs de repos en exports/README.md...${NC}"
    # Heuristica: buscar lineas con github.com o git+ssh
    if grep -qE "github\.com|git@" "$EXPORTS_DIR/README.md"; then
        echo "  URLs detectadas. (Convencion futura: el cataloger anadira URLs en el README cuando estén disponibles.)"
    else
        echo "  README no tiene URLs de repos. Anade las URLs manualmente en exports/README.md y reejecuta."
    fi
    echo ""
fi

cat <<EOF
${YELLOW}Nota:${NC} este script es un esqueleto. La automatizacion completa requiere
que el cataloger registre las URLs de los repos remotos de cada paquete en
exports/README.md, o que exista un manifest aparte (sugerido: exports/repos.yaml).

Por ahora, clonar manualmente:
  cd $EXPORTS_DIR
  git clone <url-paquete-1> nombre-paquete-1
  git clone <url-paquete-2> nombre-paquete-2
  ...

O en el flujo nuevo: usar /arc-new-package para generar paquetes desde cero.

${CYAN}Tras clonar, ejecutar:${NC}
  /arc-catalog     (refresca exports/README.md)
  /arc-audit       (verifica conformidad de los paquetes clonados)
EOF
echo ""
