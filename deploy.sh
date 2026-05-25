#!/usr/bin/env bash
# pmx-product (PM x10) — Deploy COMPLETO
#
# Despliega PM x10 ENTERO en un proyecto cliente. NO es un esqueleto minimal:
# replica exactamente lo que /new-project crea (estructura V3 completa con
# todas las carpetas, configs y templates).
#
# El dashboard que se instala ES el dashboard oficial de PM x10 (los 4 archivos
# de dashboard-template/ del paquete). Este dashboard es el dashboard ESTANDAR
# del ecosistema del arquitecto: cuando otros paquetes (newsletter, marketing, etc.)
# se despliegan después, simplemente AÑADEN su area a pm/config.json > areas y
# el mismo dashboard renderiza la nueva area en el sidebar.
#
# Idempotente: ejecutar dos veces no rompe nada ni duplica.
# No interactivo: si un campo es stack-especifico (descripcion, framework), se
# deja con placeholder TODO que el usuario edita despues (o ejecuta /new-project
# desde Claude Code para entrevistarse y rellenarlos).
#
# Usage:
#   bash deploy.sh /ruta/al/proyecto-cliente
#   bash deploy.sh /ruta/al/proyecto-cliente --dry-run
#   bash deploy.sh /ruta/al/proyecto-cliente --force-update
#   bash deploy.sh .                                              # cwd actual

set -euo pipefail

PACKAGE_NAME="pmx-product"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
DASHBOARD_TEMPLATE_DIR="$SCRIPT_DIR/dashboard-template"

GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
RED=$'\033[0;31m'
NC=$'\033[0m'

# --- Parse args ---
TARGET_PROJECT="${1:-}"
DRY_RUN=false
FORCE_UPDATE=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --force-update) FORCE_UPDATE=true ;;
    esac
done

if [ -z "$TARGET_PROJECT" ]; then
    echo -e "${RED}Error:${NC} falta ruta del proyecto cliente."
    echo "Usage: bash deploy.sh /ruta/al/proyecto-cliente [--dry-run] [--force-update]"
    echo "       bash deploy.sh . [--dry-run] [--force-update]   # cwd actual"
    exit 1
fi

# Validacion ruta peligrosa
if [[ "$TARGET_PROJECT" == *".."* ]] || [ "$TARGET_PROJECT" = "/" ] || [ "$TARGET_PROJECT" = "$HOME" ]; then
    echo -e "${RED}Error:${NC} ruta no permitida: $TARGET_PROJECT"
    exit 1
fi

if [ ! -d "$TARGET_PROJECT" ]; then
    echo -e "${CYAN}La ruta '$TARGET_PROJECT' no existe. Creandola...${NC}"
    mkdir -p "$TARGET_PROJECT"
fi
TARGET_PROJECT="$(cd "$TARGET_PROJECT" && pwd)"

# Sanity check fuentes
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo -e "${RED}Error:${NC} no se encuentra templates/ en $TEMPLATES_DIR"
    exit 1
fi
if [ ! -d "$DASHBOARD_TEMPLATE_DIR" ]; then
    echo -e "${RED}Error:${NC} no se encuentra dashboard-template/ en $DASHBOARD_TEMPLATE_DIR"
    exit 1
fi

PROJECT_NAME=$(basename "$TARGET_PROJECT")
TODAY=$(date +%Y-%m-%d)
TODAY_ISO=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo ""
echo -e "${GREEN}pmx-product (PM x10) — Deploy COMPLETO${NC}"
echo "============================================"
echo "Source paquete:    $SCRIPT_DIR"
echo "Target proyecto:   $TARGET_PROJECT"
echo "Project name:      $PROJECT_NAME"
echo "Dry-run:           $DRY_RUN"
echo "Force-update:      $FORCE_UPDATE"
echo ""

# --- Helpers ---
do_action() {
    local desc="$1"
    shift
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[dry-run]${NC} $desc"
    else
        "$@" && echo -e "  ${GREEN}[done]${NC} $desc"
    fi
}

materialize_tmpl() {
    local src="$1"
    local dest="$2"
    local label="${3:-$(basename "$dest")}"

    if [ ! -f "$src" ]; then
        echo -e "  ${YELLOW}[skip]${NC} template no encontrado: $src"
        return 0
    fi
    if [ -f "$dest" ] && [ "$FORCE_UPDATE" = false ]; then
        echo -e "  ${YELLOW}[exists]${NC} $label (use --force-update para refrescar)"
        return 0
    fi
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[dry-run]${NC} Materializar $label"
        return 0
    fi

    sed \
        -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
        -e "s|{{DATE}}|$TODAY|g" \
        -e "s|{{LAST_UPDATED_ISO}}|$TODAY_ISO|g" \
        -e "s|{{CREATED_AT}}|$TODAY_ISO|g" \
        -e "s|{{PROJECT_DESCRIPTION}}|TODO: describe el proyecto en 1-2 frases (edita .claude/CLAUDE.md o ejecuta /new-project desde Claude Code para entrevistarte)|g" \
        -e "s|{{TECH_STACK}}|TODO: define el stack tecnologico (ej: Next.js + PostgreSQL + Supabase)|g" \
        -e "s|{{TEST_FRAMEWORK}}|TODO: define test framework (ej: Vitest, Jest, Pytest)|g" \
        -e "s|{{TEST_FILE_LOCATION}}|TODO: define ubicacion de tests (ej: co-located __tests__/, tests/)|g" \
        -e "s|{{TEST_COMMAND}}|TODO: define test command (ej: npm test, pytest)|g" \
        -e "s|{{COVERAGE_COMMAND}}|TODO: define coverage command (ej: npm test -- --coverage)|g" \
        -e "s|{{TEST_DATA_STRATEGY}}|TODO: define data strategy (ej: factories con faker, MSW para mocking)|g" \
        -e "s|{{CODING_STANDARDS}}|TODO: define coding standards apropiados para el stack|g" \
        "$src" > "$dest"
    echo -e "  ${GREEN}[done]${NC} Materializar $label"
}

ensure_file() {
    local dest="$1"
    local content="$2"
    local label="${3:-$(basename "$dest")}"

    if [ -f "$dest" ] && [ "$FORCE_UPDATE" = false ]; then
        echo -e "  ${YELLOW}[exists]${NC} $label"
        return 0
    fi
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[dry-run]${NC} Crear $label"
        return 0
    fi
    printf '%s\n' "$content" > "$dest"
    echo -e "  ${GREEN}[done]${NC} Crear $label"
}

copy_file() {
    local src="$1"
    local dest="$2"
    local label="${3:-$(basename "$dest")}"

    if [ ! -f "$src" ]; then
        echo -e "  ${YELLOW}[skip]${NC} source no encontrado: $src"
        return 0
    fi
    if [ -f "$dest" ] && [ "$FORCE_UPDATE" = false ]; then
        echo -e "  ${YELLOW}[exists]${NC} $label"
        return 0
    fi
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[dry-run]${NC} Copiar $label"
        return 0
    fi
    cp "$src" "$dest"
    echo -e "  ${GREEN}[done]${NC} Copiar $label"
}

# ============================================
# 1. CREAR ESTRUCTURA V3 DE CARPETAS
# ============================================
echo -e "${CYAN}1. Crear estructura V3 de carpetas...${NC}"
DIRS=(
    .claude
    pm
    memory
    docs/general
    docs/general/wiki
    docs/producto
    docs/producto/features
    docs/marketing
    docs/rrhh
    docs/operaciones
    raw
    dashboard
)
for d in "${DIRS[@]}"; do
    if [ ! -d "$TARGET_PROJECT/$d" ]; then
        do_action "Crear $d/" mkdir -p "$TARGET_PROJECT/$d"
    fi
done

# ============================================
# 2. MATERIALIZAR TEMPLATES CORE DE PM X10
# ============================================
echo ""
echo -e "${CYAN}2. Materializar templates core de PM x10...${NC}"

materialize_tmpl "$TEMPLATES_DIR/CLAUDE-template.md"        "$TARGET_PROJECT/.claude/CLAUDE.md"        ".claude/CLAUDE.md"
materialize_tmpl "$TEMPLATES_DIR/config-template.json"       "$TARGET_PROJECT/pm/config.json"           "pm/config.json"
materialize_tmpl "$TEMPLATES_DIR/tasks-template.json"        "$TARGET_PROJECT/pm/tasks.json"            "pm/tasks.json"
materialize_tmpl "$TEMPLATES_DIR/id-counters-template.json"  "$TARGET_PROJECT/pm/id-counters.json"      "pm/id-counters.json"
materialize_tmpl "$TEMPLATES_DIR/inbox-template.md"          "$TARGET_PROJECT/docs/producto/inbox.md"   "docs/producto/inbox.md"

# pm/events.jsonl: archivo vacio
if [ ! -f "$TARGET_PROJECT/pm/events.jsonl" ]; then
    do_action "Crear pm/events.jsonl (vacio)" touch "$TARGET_PROJECT/pm/events.jsonl"
fi

# ============================================
# 3. CREAR ARCHIVOS CANONICOS QUE NO TIENEN TEMPLATE
# ============================================
echo ""
echo -e "${CYAN}3. Crear archivos canonicos de PM x10 (sprint, lessons, qa, knowledge, registry)...${NC}"

ensure_file "$TARGET_PROJECT/memory/MEMORY.md" "# Memory — $PROJECT_NAME

Persistent working memory across sessions. Agents read this at the start of each session.

## Format
- One entry per session or significant event
- Use ISO timestamp: YYYY-MM-DD
- Sections: Patterns, Decisions, Observations, References

## Patterns

(No patterns recorded yet.)

## Decisions

(No decisions recorded yet.)

## References

(No references recorded yet.)
" "memory/MEMORY.md"

ensure_file "$TARGET_PROJECT/docs/producto/sprint.md" "# Sprint actual — $PROJECT_NAME

Last updated: $TODAY

## Goal
TODO: define el objetivo del sprint en una frase.

## Stories

(No stories en el sprint todavia. Usa /story para crear una desde una idea, o /define para procesar JTBDs y crear stories.)

## Done

(Vacio)
" "docs/producto/sprint.md"

ensure_file "$TARGET_PROJECT/docs/producto/lessons.md" "# Lessons Learned — $PROJECT_NAME

Registro append-only de aprendizajes. Cada vez que se resuelva un bug tricky, se descubra algo, se cometa un error que valga la pena recordar — añade aqui.

## Format

\`\`\`
## YYYY-MM-DD — Titulo breve
**Contexto**: Que estabamos haciendo
**Leccion**: Que aprendimos
**Aplicacion**: Como evitarlo / replicarlo
\`\`\`

## Aprendizajes

(Sin entradas todavia. Usa /learned desde Claude Code para añadir una.)
" "docs/producto/lessons.md"

ensure_file "$TARGET_PROJECT/docs/producto/qa.md" "# QA Audit Trail — $PROJECT_NAME

Append-only. Cada /review deja una entrada aqui.

## Format

\`\`\`
## YYYY-MM-DD — Feature/Story revisada
**Tests**: pass/fail
**Code review**: notas
**Audit**: cumplimiento de rules
**Evaluator score**: X/10 en 4 dimensiones
**Action items**: que hay que arreglar
\`\`\`

## Reviews

(Sin reviews todavia.)
" "docs/producto/qa.md"

ensure_file "$TARGET_PROJECT/docs/general/PROJECT_KNOWLEDGE.md" "# Project Knowledge — $PROJECT_NAME

Last updated: $TODAY

> **Lee esto primero cuando vuelvas al proyecto despues de un tiempo.** Es la fuente de verdad sobre que hace el proyecto, como esta construido, que decisiones se han tomado.

## Que hace este proyecto

TODO: describe el proyecto en 1-2 parrafos.

## Arquitectura

TODO: rellenar despues de /plan o cuando se decida la arquitectura.

## Features implementadas

| Feature | Fecha | Status | Notas |
|---------|-------|--------|-------|

## Decisiones clave

| Decision | Fecha | Por que |
|----------|-------|---------|

## Como funcionan las cosas

(Sirve para explicar flujos: como se autentica el usuario, como se procesan los pagos, etc. Se rellena a medida que se construye.)

## Issues conocidos / tech debt

| Issue | Prioridad | Notas |
|-------|-----------|-------|
" "docs/general/PROJECT_KNOWLEDGE.md"

ensure_file "$TARGET_PROJECT/docs/general/project-registry.md" "# Project Registry — $PROJECT_NAME

Last updated: $TODAY
Total assets: 0

Inventario tecnico del proyecto. Una fila = un asset (funcion, endpoint, componente, tabla DB).

## Reglas

- **Granularidad**: una fila por asset, no agrupar
- **Inventario puro**: solo hechos, no decisiones
- **Categorias base obligatorias**: las 6 categorias base nunca se eliminan, se dejan vacias si no aplican

## Quick Reference
<!-- SUMMARY -->
**DB**: (none yet)
**API**: (none yet)
**Components**: (none yet)
**Services**: (none yet)
**Types**: (none yet)
**Integrations**: (none yet)
<!-- /SUMMARY -->

## DB Models
<!-- CATEGORY:db -->
| Table | Key Fields | Relations | Feature | Story | Status |
|-------|-----------|-----------|---------|-------|--------|

## API Endpoints
<!-- CATEGORY:api -->
| Method | Path | Auth | Feature | Story | Status |
|--------|------|------|---------|-------|--------|

## Shared Components
<!-- CATEGORY:components -->
| Component | Path | Props/Interface | Feature | Story | Status |
|-----------|------|----------------|---------|-------|--------|

## Services & Utilities
<!-- CATEGORY:services -->
| Service | Path | Key Exports | Feature | Story | Status |
|---------|------|-------------|---------|-------|--------|

## Types & Interfaces
<!-- CATEGORY:types -->
| Type | Path | Key Fields | Feature | Story | Status |
|------|------|-----------|---------|-------|--------|

## External Integrations
<!-- CATEGORY:integrations -->
| Integration | Purpose | Auth Method | Feature | Story | Status |
|-------------|---------|-------------|---------|-------|--------|
" "docs/general/project-registry.md"

# README de areas extras (marketing, rrhh, operaciones)
for area in marketing rrhh operaciones; do
    AREA_LABEL=$(echo "$area" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    ensure_file "$TARGET_PROJECT/docs/$area/README.md" "# $AREA_LABEL — $PROJECT_NAME

Carpeta del area **$area**. Documentos, notas y artefactos viven aqui.

Esta area esta declarada en pm/config.json > areas.$area y aparece como pestaña en el sidebar del dashboard.

Para añadir contenido: crea archivos .md aqui. El dashboard los renderiza dinamicamente.
" "docs/$area/README.md"
done

# Wiki + raw
ensure_file "$TARGET_PROJECT/docs/general/wiki/README.md" "# Wiki — $PROJECT_NAME

Sintesis derivada (entidades, conceptos, topics) extraidas desde raw/ por el wiki-curator.

NO editar manualmente: estos archivos los regenera /wiki.

- index.md — indice de entidades y conceptos
- log.md — cronologia de cambios
- tags.md — etiquetas
- entities/ — una pagina por entidad
- concepts/ — una pagina por concepto
- topics/ — temas trasversales
" "docs/general/wiki/README.md"

ensure_file "$TARGET_PROJECT/raw/README.md" "# Raw Sources — $PROJECT_NAME

Fuente de verdad de la wiki. Aqui van los artefactos crudos sin procesar:

- **Articulos**: raw/articles/YYYY-MM-DD-slug.md (con frontmatter)
- **Reuniones**: raw/meetings/YYYY-MM-DD-slug.md
- **Notas**: raw/notes/YYYY-MM-DD-slug.md

Ejecuta /wiki ingestar desde Claude Code para procesarlos y derivar entidades/conceptos en docs/general/wiki/.

Templates disponibles en el paquete: raw-article-template.md, raw-meeting-template.md, raw-note-template.md.
" "raw/README.md"

# ============================================
# 4. INSTALAR EL DASHBOARD OFICIAL DE PM X10
# ============================================
echo ""
echo -e "${CYAN}4. Instalar dashboard oficial de PM x10 (extensible via pm/config.json > areas)...${NC}"

copy_file "$DASHBOARD_TEMPLATE_DIR/bridge.py"  "$TARGET_PROJECT/dashboard/bridge.py"  "dashboard/bridge.py"
copy_file "$DASHBOARD_TEMPLATE_DIR/index.html" "$TARGET_PROJECT/dashboard/index.html" "dashboard/index.html"
copy_file "$DASHBOARD_TEMPLATE_DIR/styles.css" "$TARGET_PROJECT/dashboard/styles.css" "dashboard/styles.css"
copy_file "$DASHBOARD_TEMPLATE_DIR/app.js"     "$TARGET_PROJECT/dashboard/app.js"     "dashboard/app.js"

# ============================================
# 5. REGISTRAR EN ~/.claude/projects-registry.txt
# ============================================
PROJECTS_REGISTRY="$HOME/.claude/projects-registry.txt"
if [ "$DRY_RUN" = false ]; then
    if ! grep -q "^${TARGET_PROJECT}|${PACKAGE_NAME}|" "$PROJECTS_REGISTRY" 2>/dev/null; then
        echo "${TARGET_PROJECT}|${PACKAGE_NAME}|$(date -u +%Y-%m-%dT%H:%M:%S%z)" >> "$PROJECTS_REGISTRY"
        echo ""
        echo -e "${CYAN}Registrado en ~/.claude/projects-registry.txt${NC}"
    fi
fi

# ============================================
# SUMMARY
# ============================================
echo ""
echo "============================================"
echo -e "${GREEN}Deploy ${PACKAGE_NAME} en ${TARGET_PROJECT}: COMPLETO${NC}"
echo ""
echo -e "${CYAN}Que tienes ahora:${NC}"
echo "  - Estructura V3 completa de PM x10 (.claude/, pm/, memory/, docs/, raw/, dashboard/)"
echo "  - Dashboard oficial de PM x10 instalado (extensible: otros paquetes añaden su area)"
echo "  - 18 agentes y 17 comandos disponibles (instalados globalmente via install.sh)"
echo "  - pm/config.json con areas 'general' y 'producto' activas"
echo ""
echo -e "${CYAN}Para personalizar el stack tecnologico:${NC}"
echo "  abre el proyecto en Claude Code y ejecuta /new-project"
echo "  (te entrevista 6 preguntas y rellena los placeholders TODO en CLAUDE.md)"
echo ""
echo -e "${CYAN}Para arrancar el dashboard:${NC}"
echo "  cd '$TARGET_PROJECT'"
echo "  python3 dashboard/bridge.py"
echo ""
echo -e "${CYAN}Para empezar a trabajar:${NC}"
echo "  abre Claude Code en este proyecto y ejecuta:"
echo "    /pm sync       (PM de Producto: indice + buzon)"
echo "    /story         (story autonomo desde una idea)"
echo "    /analyze       (evaluar problema/PRD)"
echo ""
echo -e "${YELLOW}Nota multi-paquete:${NC} si despues despliegas otro paquete (newsletter, marketing,...),"
echo "se añadira su area a pm/config.json y aparecera como pestaña en el sidebar del MISMO dashboard."
echo ""
