#!/usr/bin/env bash
# ledger-index.sh — Regenera el INDEX.md de un directorio context-ledger/
#
# El índice es la "capa barata" de la recuperación en 3 capas del ski-context-ledger:
# una línea por entrada que se escanea antes de abrir archivos completos.
#
# Normalmente el índice se mantiene vivo con un append al escribir cada entrada
# (paso 6 de la API en skills/ski-context-ledger/SKILL.md). Este script lo
# reconstruye desde cero escaneando el frontmatter de cada entrada — útil para
# bootstrap de ledgers heredados o reparación si se desincroniza.
#
# Vive dentro de la carpeta de la skill para que viaje con ella al propagarse
# (ruta relativa idéntica en el arquitecto y en cada paquete).
#
# Uso:
#   bash skills/ski-context-ledger/ledger-index.sh [ruta-al-context-ledger]   # default: ./context-ledger
#
# Idempotente: ejecutarlo N veces produce el mismo INDEX.md.

set -euo pipefail

LEDGER_DIR="${1:-context-ledger}"

# Fail-safe: si el directorio no existe, no es un error — simplemente no hay nada que indexar.
if [ ! -d "$LEDGER_DIR" ]; then
    echo "ledger-index: '$LEDGER_DIR' no existe; nada que indexar." >&2
    exit 0
fi

INDEX_FILE="$LEDGER_DIR/INDEX.md"
TMP_ROWS="$(mktemp)"
trap 'rm -f "$TMP_ROWS"' EXIT

# Extrae un campo del frontmatter (primer bloque entre '---'). Limpia comillas.
extract_field() {
    local file="$1" key="$2"
    awk -v key="$key" '
        BEGIN { in_fm=0 }
        /^---[[:space:]]*$/ { fm++; if (fm==1) { in_fm=1; next } else { exit } }
        in_fm && $0 ~ "^"key"[[:space:]]*:" {
            sub("^"key"[[:space:]]*:[[:space:]]*", "")
            gsub(/^["'"'"']|["'"'"']$/, "")
            print
            exit
        }
    ' "$file"
}

shopt -s nullglob
for f in "$LEDGER_DIR"/*.md; do
    base="$(basename "$f")"
    [ "$base" = "INDEX.md" ] && continue

    ts="$(extract_field "$f" timestamp)"
    # Sin timestamp en frontmatter => no es una entrada del ledger (README, notas sueltas). Saltar.
    [ -z "$ts" ] && continue

    agent="$(extract_field "$f" agent)"
    step="$(extract_field "$f" step)"
    scope="$(extract_field "$f" scope)"
    outcome="$(extract_field "$f" outcome)"

    # Campos ausentes → marcador para que el hueco sea visible, no silencioso.
    ts="${ts:-?}"
    agent="${agent:-?}"
    step="${step:-?}"
    scope="${scope:-?}"
    outcome="${outcome:-?}"

    # Prefijo de orden = timestamp (TAB como separador para el sort).
    printf '%s\t| %s | %s | %s | %s | %s | %s |\n' \
        "$ts" "$ts" "$agent" "$step" "$scope" "$outcome" "$base" >> "$TMP_ROWS"
done

# Reescribe el índice: cabecera + filas ordenadas cronológicamente.
{
    echo "# Context Ledger — Índice"
    echo ""
    echo "> Generado por skills/ski-context-ledger/ledger-index.sh. Una línea por entrada (capa barata de recuperación en 3 capas)."
    echo ""
    echo "| timestamp | agente | step | scope | outcome | archivo |"
    echo "|---|---|---|---|---|---|"
    sort "$TMP_ROWS" | cut -f2-
} > "$INDEX_FILE"

count="$(wc -l < "$TMP_ROWS" | tr -d ' ')"
echo "ledger-index: $INDEX_FILE regenerado ($count entradas)."
