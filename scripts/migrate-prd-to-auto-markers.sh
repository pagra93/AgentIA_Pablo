#!/usr/bin/env bash
# migrate-prd-to-auto-markers.sh — Añade marcadores <!-- AUTO:section --> a PRDs legacy.
#
# Para cada `docs/producto/features/*/prd.md` SIN marcadores AUTO, envuelve sus
# secciones canónicas (Problema, Métricas, AS-IS/TO-BE, Actores, Scope, Diseño técnico,
# User Stories) en marcadores `<!-- AUTO:X --> ... <!-- /AUTO:X -->`. Secciones extra
# no-canónicas (Restricciones, Riesgos, etc.) se preservan tal cual.
#
# Idempotente: si un PRD YA tiene marcadores AUTO, se respeta y no se toca.
# Backup automático antes de cualquier escritura.
# Por defecto: --dry-run.
#
# Uso:
#   bash migrate-prd-to-auto-markers.sh "/ruta/proyecto"             # dry-run
#   bash migrate-prd-to-auto-markers.sh "/ruta/proyecto" --apply     # ejecuta
#
# Tras la migración, el PM en modo dossier puede enriquecer las secciones AUTO
# del PRD con la información de research.md, jtbds.md, architecture.md.

set -euo pipefail

APPLY=false
PROJECT_PATH=""

while [ $# -gt 0 ]; do
    case "$1" in
        --apply) APPLY=true; shift ;;
        --help|-h) sed -n '2,21p' "$0" | sed 's/^# //; s/^#//'; exit 0 ;;
        --*) echo "Argumento desconocido: $1"; exit 1 ;;
        *) PROJECT_PATH="$1"; shift ;;
    esac
done

if [ -z "$PROJECT_PATH" ]; then
    echo "Uso: bash migrate-prd-to-auto-markers.sh <ruta-proyecto> [--apply]"
    exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "Error: no existe $PROJECT_PATH"
    exit 1
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

if [ "$APPLY" = false ]; then
    echo -e "${YELLOW}Modo dry-run.${NC} Pasa --apply para escribir."
    echo ""
fi

python3 - "$PROJECT_PATH" "$APPLY" <<'PYEOF'
import os, sys, re, shutil
from datetime import datetime

project = sys.argv[1]
apply = sys.argv[2] == "true"
features_dir = os.path.join(project, "docs", "producto", "features")

GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
CYAN = "\033[0;36m"
RED = "\033[0;31m"
NC = "\033[0m"

# Mapeo de heading (regex) → nombre canónico de la sección AUTO
# Tolerante a numeración variable, acentos, mayúsculas/minúsculas, sinónimos comunes
CANONICAL_SECTIONS = [
    ("problema",      re.compile(r"^##\s+\d*\.?\s*Problema\b", re.IGNORECASE)),
    ("metricas",      re.compile(r"^##\s+\d*\.?\s*M[eé]tricas?(\s+de\s+([eé]xito|success))?\b", re.IGNORECASE)),
    ("as_is_to_be",   re.compile(r"^##\s+\d*\.?\s*AS[\-\s_]?IS(\s*/\s*TO[\-\s_]?BE)?\b|^##\s+\d*\.?\s*AS\-IS\b", re.IGNORECASE)),
    ("actores",       re.compile(r"^##\s+\d*\.?\s*Actores\b", re.IGNORECASE)),
    ("scope",         re.compile(r"^##\s+\d*\.?\s*Scope\b|^##\s+\d*\.?\s*Alcance\b", re.IGNORECASE)),
    ("diseno_tecnico", re.compile(r"^##\s+\d*\.?\s*Dise[ñn]o\s+t[eé]cnico\b|^##\s+\d*\.?\s*Restricciones\s+t[eé]cnicas\b", re.IGNORECASE)),
    ("stories",       re.compile(r"^##\s+\d*\.?\s*(Stories|User\s+Stories|Historias?(\s+de\s+usuario)?|Stories\s+Asociadas)\b", re.IGNORECASE)),
]

# Regex para detectar inicio de cualquier sección H2 (para delimitar el fin de la actual)
H2_RE = re.compile(r"^##\s+", re.MULTILINE)
AUTO_MARKER_RE = re.compile(r"<!--\s*AUTO:\w+\s*-->")
USER_NOTES_RE = re.compile(r"<!--\s*USER:notes\s*-->")

total_files = 0
total_already_done = 0
total_migrated = 0
total_no_canonical = 0

if not os.path.isdir(features_dir):
    print(f"Sin features/: {project}")
    sys.exit(0)

for feat_name in sorted(os.listdir(features_dir)):
    feat_path = os.path.join(features_dir, feat_name)
    if not os.path.isdir(feat_path) or feat_name.startswith((".", "_")):
        continue
    prd_path = os.path.join(feat_path, "prd.md")
    if not os.path.exists(prd_path):
        continue
    total_files += 1

    with open(prd_path) as f:
        content = f.read()

    # ¿Ya tiene marcadores AUTO? → idempotente, skip
    if AUTO_MARKER_RE.search(content):
        rel = os.path.relpath(prd_path, project)
        print(f"  {GREEN}[skip]{NC} {rel} (ya tiene marcadores AUTO)")
        total_already_done += 1
        continue

    # Localizar headings H2 y su offset
    headings = []
    for m in re.finditer(H2_RE, content):
        # Línea completa del heading (hasta \n)
        line_start = m.start()
        line_end = content.find("\n", line_start)
        if line_end == -1:
            line_end = len(content)
        heading_line = content[line_start:line_end]
        headings.append((line_start, line_end, heading_line))

    if not headings:
        rel = os.path.relpath(prd_path, project)
        print(f"  {YELLOW}[skip]{NC} {rel} (sin headings H2 — formato no reconocido)")
        total_no_canonical += 1
        continue

    # Identificar qué heading corresponde a qué sección canónica
    # Para cada heading, intentar match con cada regex canónica
    section_for_heading = {}  # idx → section_name
    for idx, (_, _, heading_line) in enumerate(headings):
        for sec_name, sec_re in CANONICAL_SECTIONS:
            if sec_re.match(heading_line):
                section_for_heading[idx] = sec_name
                break

    if not section_for_heading:
        rel = os.path.relpath(prd_path, project)
        print(f"  {YELLOW}[skip]{NC} {rel} (no se detectó ninguna sección canónica)")
        total_no_canonical += 1
        continue

    # Construir nuevo contenido recorriendo headings de atrás hacia adelante
    # para no desplazar offsets al insertar marcadores
    new_content = content
    for idx in reversed(range(len(headings))):
        sec_name = section_for_heading.get(idx)
        if not sec_name:
            continue
        line_start, line_end, heading_line = headings[idx]
        # El cuerpo de la sección va desde line_end+1 (después del \n del heading) hasta:
        #   - el inicio del siguiente heading H2 (si existe)
        #   - el final del archivo
        if idx + 1 < len(headings):
            body_end = headings[idx + 1][0]
        else:
            body_end = len(new_content)

        body_start = line_end + 1
        body = new_content[body_start:body_end].rstrip("\n")
        # Marcadores AUTO + body + cierre + 2 saltos antes del siguiente heading (o final)
        wrapped = f"\n<!-- AUTO:{sec_name} -->\n{body}\n<!-- /AUTO:{sec_name} -->\n\n"
        new_content = new_content[:body_start] + wrapped + new_content[body_end:]

    # Añadir sección USER:notes al final si no existe
    if not USER_NOTES_RE.search(new_content):
        if not new_content.endswith("\n"):
            new_content += "\n"
        new_content += "\n---\n\n## 📝 Notas del usuario\n\n<!-- USER:notes -->\n_(vacío — añade aquí notas manuales; los agentes nunca tocan esta sección)_\n<!-- /USER:notes -->\n"

    rel = os.path.relpath(prd_path, project)
    if apply:
        backup = prd_path + ".bak-" + datetime.now().strftime("%Y%m%d-%H%M%S")
        shutil.copy2(prd_path, backup)
        with open(prd_path, "w") as f:
            f.write(new_content)
        print(f"  {GREEN}[migrated]{NC} {rel} (+{len(section_for_heading)} secciones, backup: {os.path.basename(backup)})")
    else:
        print(f"  {YELLOW}[would migrate]{NC} {rel} (detectadas {len(section_for_heading)} secciones canónicas)")
    total_migrated += 1

print()
print("=" * 60)
print(f"{CYAN}Resumen:{NC}")
print(f"  PRDs escaneados: {total_files}")
print(f"  Ya tenían marcadores AUTO: {total_already_done}")
print(f"  {'Migrados' if apply else 'A migrar'}: {total_migrated}")
print(f"  Sin secciones canónicas reconocibles: {total_no_canonical}")
if not apply and total_migrated > 0:
    print()
    print(f"{YELLOW}Re-ejecuta con --apply para escribir.{NC}")
PYEOF