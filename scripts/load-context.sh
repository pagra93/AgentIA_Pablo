#!/usr/bin/env bash
# load-context.sh — Carga la "capa barata" de contexto al arrancar una sesión.
#
# Lo invoca el hook SessionStart (.claude/settings.json). Su stdout se inyecta
# en el contexto de la sesión. Carga SOLO lo barato y acotado:
#   - memory/MEMORY.md         (índice de memoria del arquitecto)
#   - context-ledger/INDEX.md  (índice del ledger, NO las entradas completas)
#   - changelog/propagations.md (últimas entradas)
#
# NO vuelca CLAUDE.md: Claude Code ya lo auto-carga como project instructions.
# fail_open: nunca bloquea el arranque (cualquier ausencia se ignora en silencio).

set -uo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$PROJECT_ROOT" 2>/dev/null || exit 0

echo "=== Contexto de sesión (AgentArchitect) ==="
echo ""

# Memoria del arquitecto
if [ -s "memory/MEMORY.md" ]; then
    echo "--- memory/MEMORY.md ---"
    cat "memory/MEMORY.md"
    echo ""
fi

# Índice del context-ledger (capa barata; abrir entradas completas bajo demanda)
if [ -s "context-ledger/INDEX.md" ]; then
    echo "--- context-ledger/INDEX.md (abre entradas completas solo si las necesitas) ---"
    cat "context-ledger/INDEX.md"
    echo ""
elif [ -d "context-ledger" ]; then
    echo "--- context-ledger/ existe pero sin INDEX.md: regenera con 'bash skills/ski-context-ledger/ledger-index.sh' ---"
    echo ""
fi

# Últimas propagaciones aplicadas
if [ -s "changelog/propagations.md" ]; then
    echo "--- changelog/propagations.md (últimas líneas) ---"
    tail -n 20 "changelog/propagations.md"
    echo ""
fi

echo "=== Contexto cargado ==="
