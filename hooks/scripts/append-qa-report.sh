#!/usr/bin/env bash
# Append QA results to qa-report.md after /review
#
# In practice, the QA agents (Auditor, Evaluator, Optimizer) write to
# qa/qa-report.md directly via the Write tool. This script ensures
# the separator is added between cycles.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
QA_REPORT="$PROJECT_ROOT/qa/qa-report.md"

if [ -f "$QA_REPORT" ]; then
    echo "" >> "$QA_REPORT"
    echo "---" >> "$QA_REPORT"
    echo "" >> "$QA_REPORT"
    echo "QA cycle separator added."
else
    echo "qa/qa-report.md not found. Create it first."
    exit 1
fi
