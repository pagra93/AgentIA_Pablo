#!/usr/bin/env bash
# Load context at session start
# Reads memory, lessons, and project knowledge into the agent's context.
#
# Usage: Called automatically by hooks system or manually by agent.
# In Claude Code, agents typically read these files directly via Read tool
# instead of using this script. This exists as a reference implementation.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

echo "=== Session Context ==="
echo ""

# Working memory
if [ -f "$PROJECT_ROOT/memory/MEMORY.md" ]; then
    echo "--- memory/MEMORY.md ---"
    cat "$PROJECT_ROOT/memory/MEMORY.md"
    echo ""
fi

# Lessons learned
if [ -f "$PROJECT_ROOT/tasks/lessons.md" ]; then
    echo "--- tasks/lessons.md ---"
    cat "$PROJECT_ROOT/tasks/lessons.md"
    echo ""
fi

# Project knowledge
if [ -f "$PROJECT_ROOT/docs/PROJECT_KNOWLEDGE.md" ]; then
    echo "--- docs/PROJECT_KNOWLEDGE.md ---"
    head -50 "$PROJECT_ROOT/docs/PROJECT_KNOWLEDGE.md"
    echo ""
fi

echo "=== Context loaded ==="
