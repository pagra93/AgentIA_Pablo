#!/usr/bin/env bash
# Update working memory after a session
# Appends new findings to memory/MEMORY.md
#
# In practice, agents (Code Reviewer, Optimizer) write to MEMORY.md directly
# via the Write tool. This script is a reference for automation.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MEMORY_FILE="$PROJECT_ROOT/memory/MEMORY.md"
MAX_LINES=200

if [ -f "$MEMORY_FILE" ]; then
    LINE_COUNT=$(wc -l < "$MEMORY_FILE")
    if [ "$LINE_COUNT" -gt "$MAX_LINES" ]; then
        echo "WARNING: MEMORY.md has $LINE_COUNT lines (max: $MAX_LINES)"
        echo "Consider archiving older entries to memory/archive/"
    fi
fi

# Update the "Last updated" line
if [ -f "$MEMORY_FILE" ]; then
    sed -i '' "s/^Last updated:.*/Last updated: $(date +%Y-%m-%d)/" "$MEMORY_FILE" 2>/dev/null || true
fi

echo "Memory check complete."
