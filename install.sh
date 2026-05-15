#!/usr/bin/env bash
# AgentArchitect — Installer
#
# Compila e instala el meta-sistema arquitecto en ~/.claude/:
# 1. Compila los 9 agentes arc-* (agent.yaml + SOUL.md + DUTIES.md → un .md)
# 2. Copia los 6 comandos /arc-* a ~/.claude/commands/
# 3. Instala las 3 skills nuevas (ski-context-ledger, ski-compression, ski-mini-discovery)
# 4. Instala las 2 rules nuevas (rul-scope-boundaries, rul-lazy-loading)
# 5. Instala los 2 knowledge nuevos (kno-elicitation-methods, kno-mcp-integration)
# 6. Copia templates/project-template/ y templates/package-template/ a ~/.claude/architect/
# 7. Genera wrapper CLI ~/.claude/arc (paralelo al pmx10 de PM x10)
#
# NO toca skills/rules/knowledge genericos heredados de PM x10 (asume que PM x10
# ya los instalo). Idempotente: ejecutar dos veces no rompe nada.
#
# Usage:
#   chmod +x install.sh
#   ./install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.claude"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${GREEN}AgentArchitect — Installer${NC}"
echo "================================"
echo ""
echo "Source:  $SCRIPT_DIR"
echo "Target:  $TARGET_DIR"
echo ""

# --- Sanity check: ~/.claude debe existir ---
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}Aviso:${NC} ~/.claude/ no existe."
    echo "Recomendado: instalar primero PM x10 (que crea la estructura base de ~/.claude/)."
    echo ""
    read -p "Crear ~/.claude/ y continuar? (y/N): " choice
    case "$choice" in
        y|Y)
            mkdir -p "$TARGET_DIR/agents" "$TARGET_DIR/commands" "$TARGET_DIR/skills"
            ;;
        *)
            echo "Aborted."
            exit 1
            ;;
    esac
fi

# --- Safe write/copy ---
safe_write() {
    local dest="$1"
    local content="$2"
    if [ -f "$dest" ]; then
        if echo "$content" | diff -q - "$dest" > /dev/null 2>&1; then
            echo -e "  ${GREEN}[identical]${NC} $(basename "$dest")"
            return 0
        fi
        echo -e "  ${YELLOW}[exists]${NC} $(basename "$dest")"
        read -p "    Overwrite? (y/N): " choice
        case "$choice" in
            y|Y) echo "$content" > "$dest"; echo -e "    ${GREEN}[updated]${NC}" ;;
            *) echo -e "    ${YELLOW}[skipped]${NC}" ;;
        esac
    else
        echo "$content" > "$dest"
        echo -e "  ${GREEN}[installed]${NC} $(basename "$dest")"
    fi
}

safe_copy() {
    local src="$1"
    local dest="$2"
    if [ -f "$dest" ]; then
        if diff -q "$src" "$dest" > /dev/null 2>&1; then
            echo -e "  ${GREEN}[identical]${NC} $(basename "$dest")"
            return 0
        fi
        echo -e "  ${YELLOW}[exists]${NC} $(basename "$dest")"
        read -p "    Overwrite? (y/N): " choice
        case "$choice" in
            y|Y) cp "$src" "$dest"; echo -e "    ${GREEN}[updated]${NC}" ;;
            *) echo -e "    ${YELLOW}[skipped]${NC}" ;;
        esac
    else
        cp "$src" "$dest"
        echo -e "  ${GREEN}[installed]${NC} $(basename "$dest")"
    fi
}

copy_dir_recursive() {
    local src_dir="$1"
    local dest_dir="$2"
    mkdir -p "$dest_dir"
    for item in "$src_dir"/*; do
        if [ -f "$item" ]; then
            safe_copy "$item" "$dest_dir/$(basename "$item")"
        elif [ -d "$item" ]; then
            copy_dir_recursive "$item" "$dest_dir/$(basename "$item")"
        fi
    done
}

mkdir -p "$TARGET_DIR/agents" "$TARGET_DIR/commands" "$TARGET_DIR/skills"

# ============================================
# 1. COMPILE AGENTES arc-*
# ============================================
echo -e "${CYAN}Compiling 9 agents del arquitecto (arc-*)...${NC}"
echo "  (agent.yaml + SOUL.md + DUTIES.md → un .md)"
echo ""

for agent_dir in "$SCRIPT_DIR/agents"/*/; do
    if [ -d "$agent_dir" ]; then
        agent_name=$(basename "$agent_dir")
        agent_yaml="$agent_dir/agent.yaml"
        soul_md="$agent_dir/SOUL.md"
        duties_md="$agent_dir/DUTIES.md"

        compiled=""

        if [ -f "$agent_yaml" ]; then
            name=$(grep '^name:' "$agent_yaml" | head -1 | sed 's/name: *//')
            desc=$(grep '^description:' "$agent_yaml" | head -1 | sed 's/description: *//' | tr -d '"')
            model=$(grep 'preferred:' "$agent_yaml" | head -1 | sed 's/.*preferred: *//')
            tools=$(grep '^tools:' "$agent_yaml" | head -1 | sed 's/tools: *//')

            compiled="---
name: $name
description: $desc
model: $model
tools: $tools
---
"
        fi

        if [ -f "$soul_md" ]; then
            compiled="$compiled
$(cat "$soul_md")
"
        fi

        if [ -f "$duties_md" ]; then
            compiled="$compiled

---

$(cat "$duties_md")
"
        fi

        # Inline preloaded skills (busca en skills/, rules/, knowledge/ del arquitecto)
        if [ -f "$agent_yaml" ]; then
            skills_list=$(awk '
                /^skills:/ { in_skills=1; next }
                in_skills && /^[a-zA-Z]/ { in_skills=0 }
                in_skills && /^[[:space:]]*-[[:space:]]+/ {
                    sub(/^[[:space:]]*-[[:space:]]+/, "")
                    sub(/[[:space:]]*#.*$/, "")
                    print
                }
            ' "$agent_yaml")

            for skill_name in $skills_list; do
                skill_content=""
                skill_source=""
                if [ -f "$SCRIPT_DIR/skills/$skill_name/SKILL.md" ]; then
                    skill_source="skills/$skill_name/SKILL.md"
                    skill_content=$(cat "$SCRIPT_DIR/skills/$skill_name/SKILL.md")
                elif [ -f "$SCRIPT_DIR/rules/$skill_name.md" ]; then
                    skill_source="rules/$skill_name.md"
                    skill_content=$(cat "$SCRIPT_DIR/rules/$skill_name.md")
                elif [ -f "$SCRIPT_DIR/knowledge/$skill_name.md" ]; then
                    skill_source="knowledge/$skill_name.md"
                    skill_content=$(cat "$SCRIPT_DIR/knowledge/$skill_name.md")
                elif [ -f "$TARGET_DIR/skills/$skill_name/SKILL.md" ]; then
                    # Fallback: skill ya instalada globalmente (ej. de PM x10)
                    skill_source="(global) skills/$skill_name/SKILL.md"
                    skill_content=$(cat "$TARGET_DIR/skills/$skill_name/SKILL.md")
                fi

                if [ -n "$skill_content" ]; then
                    compiled="$compiled

---

# Preloaded Skill: $skill_name
<!-- source: $skill_source -->

$skill_content
"
                fi
            done
        fi

        dest_file="$TARGET_DIR/agents/$agent_name.md"
        safe_write "$dest_file" "$compiled"
    fi
done
echo ""

# ============================================
# 2. COPY COMANDOS /arc-*
# ============================================
echo -e "${CYAN}Installing 6 comandos /arc-*...${NC}"
for cmd_file in "$SCRIPT_DIR/commands"/*.md; do
    if [ -f "$cmd_file" ]; then
        safe_copy "$cmd_file" "$TARGET_DIR/commands/$(basename "$cmd_file")"
    fi
done
echo ""

# ============================================
# 3. INSTALAR SKILLS NUEVAS (ski-context-ledger, ski-compression, ski-mini-discovery)
# ============================================
echo -e "${CYAN}Installing skills nuevas del arquitecto...${NC}"
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        # Solo instalar si NO existe ya en ~/.claude/skills (heredadas de PM x10 las omitimos)
        if [ ! -d "$TARGET_DIR/skills/$skill_name" ]; then
            copy_dir_recursive "$skill_dir" "$TARGET_DIR/skills/$skill_name"
        else
            # Si ya existe, comprobar si es de arquitecto (nuevas) y refrescar
            case "$skill_name" in
                ski-context-ledger|ski-compression|ski-mini-discovery)
                    echo -e "  ${YELLOW}[refreshing]${NC} $skill_name (nueva del arquitecto)"
                    copy_dir_recursive "$skill_dir" "$TARGET_DIR/skills/$skill_name"
                    ;;
                *)
                    echo -e "  ${GREEN}[already-installed]${NC} $skill_name (heredada de PM x10)"
                    ;;
            esac
        fi
    fi
done
echo ""

# ============================================
# 4. INSTALAR RULES NUEVAS (rul-scope-boundaries, rul-lazy-loading)
# ============================================
echo -e "${CYAN}Installing rules nuevas del arquitecto (como skills)...${NC}"
for rule_file in "$SCRIPT_DIR/rules"/*.md; do
    if [ -f "$rule_file" ]; then
        rule_name=$(basename "$rule_file" .md)
        rule_dest="$TARGET_DIR/skills/$rule_name"
        case "$rule_name" in
            rul-scope-boundaries|rul-lazy-loading)
                # Nuevas del arquitecto: instalar/refrescar
                mkdir -p "$rule_dest"
                safe_copy "$rule_file" "$rule_dest/SKILL.md"
                ;;
            *)
                # Heredadas de PM x10: omitir si ya están
                if [ ! -d "$rule_dest" ]; then
                    mkdir -p "$rule_dest"
                    safe_copy "$rule_file" "$rule_dest/SKILL.md"
                else
                    echo -e "  ${GREEN}[already-installed]${NC} $rule_name (heredada de PM x10)"
                fi
                ;;
        esac
    fi
done
echo ""

# ============================================
# 5. INSTALAR KNOWLEDGE NUEVOS (kno-elicitation-methods, kno-mcp-integration)
# ============================================
echo -e "${CYAN}Installing knowledge nuevos del arquitecto (como skills)...${NC}"
for kno_file in "$SCRIPT_DIR/knowledge"/kno-*.md; do
    if [ -f "$kno_file" ]; then
        kno_name=$(basename "$kno_file" .md)
        kno_dest="$TARGET_DIR/skills/$kno_name"
        case "$kno_name" in
            kno-elicitation-methods|kno-mcp-integration)
                mkdir -p "$kno_dest"
                safe_copy "$kno_file" "$kno_dest/SKILL.md"
                ;;
            *)
                if [ ! -d "$kno_dest" ]; then
                    mkdir -p "$kno_dest"
                    safe_copy "$kno_file" "$kno_dest/SKILL.md"
                else
                    echo -e "  ${GREEN}[already-installed]${NC} $kno_name (heredado de PM x10)"
                fi
                ;;
        esac
    fi
done
echo ""

# ============================================
# 6. INSTALAR TEMPLATES (package-template + project-template) a ~/.claude/architect/
# ============================================
ARCH_TARGET="$TARGET_DIR/architect"
mkdir -p "$ARCH_TARGET"

if [ -d "$SCRIPT_DIR/templates/package-template" ]; then
    echo -e "${CYAN}Installing package-template a ~/.claude/architect/package-template/...${NC}"
    copy_dir_recursive "$SCRIPT_DIR/templates/package-template" "$ARCH_TARGET/package-template"
    echo ""
fi

if [ -d "$SCRIPT_DIR/templates/project-template" ]; then
    echo -e "${CYAN}Installing project-template a ~/.claude/architect/project-template/...${NC}"
    copy_dir_recursive "$SCRIPT_DIR/templates/project-template" "$ARCH_TARGET/project-template"
    echo ""
fi

# ============================================
# 7. GENERAR WRAPPER CLI ~/.claude/arc
# ============================================
ARC_TEMPLATE="$SCRIPT_DIR/scripts/arc.template"
ARC_DEST="$TARGET_DIR/arc"
if [ -f "$ARC_TEMPLATE" ]; then
    echo -e "${CYAN}Installing arc wrapper...${NC}"
    sed "s|{{SYSTEM_REPO}}|$SCRIPT_DIR|g" "$ARC_TEMPLATE" > "$ARC_DEST"
    chmod +x "$ARC_DEST"
    echo -e "  ${GREEN}[installed]${NC} ~/.claude/arc  (uso: bash ~/.claude/arc help)"

    # Sugerir alias si no existe
    SHELL_RC=""
    [ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"
    [ -z "$SHELL_RC" ] && [ -f "$HOME/.bashrc" ] && SHELL_RC="$HOME/.bashrc"
    if [ -n "$SHELL_RC" ] && ! grep -q "alias arc=" "$SHELL_RC" 2>/dev/null; then
        echo -e "  ${YELLOW}Tip:${NC} para escribir 'arc' directamente en vez de 'bash ~/.claude/arc':"
        echo "       echo 'alias arc=\"bash \$HOME/.claude/arc\"' >> $SHELL_RC && source $SHELL_RC"
    fi
    echo ""
fi

# ============================================
# REGISTRAR EL ARQUITECTO COMO PAQUETE
# ============================================
PACKAGES_REGISTRY="$TARGET_DIR/packages-registry.txt"
if ! grep -q "^agent-architect|" "$PACKAGES_REGISTRY" 2>/dev/null; then
    echo "agent-architect|arc|${SCRIPT_DIR}|$(date -u +%Y-%m-%dT%H:%M:%S%z)" >> "$PACKAGES_REGISTRY"
    echo -e "${CYAN}Registrado en ${PACKAGES_REGISTRY}${NC}"
fi

# ============================================
# SUMMARY
# ============================================
echo ""
echo "================================"
echo -e "${GREEN}Installation complete!${NC}"
echo ""

agent_count=$(ls "$TARGET_DIR/agents/" 2>/dev/null | grep -c "arc-" || true)
cmd_count=$(ls "$TARGET_DIR/commands/" 2>/dev/null | grep -c "arc-" || true)

echo "Installed:"
echo "  Agents:   $agent_count agentes arc-* (compilados en ~/.claude/agents/)"
echo "  Commands: $cmd_count comandos /arc-* (en ~/.claude/commands/)"
echo "  Skills:   3 nuevas (ski-context-ledger, ski-compression, ski-mini-discovery)"
echo "  Rules:    2 nuevas como skills (rul-scope-boundaries, rul-lazy-loading)"
echo "  Knowledge: 2 nuevos como skills (kno-elicitation-methods, kno-mcp-integration)"
echo "  Templates: ~/.claude/architect/package-template/ y project-template/"
echo "  CLI:      ~/.claude/arc"
echo ""
echo -e "${CYAN}Lo que Claude Code tiene ahora del arquitecto:${NC}"
echo ""
echo "  /arc-new-package      Crear paquete via mini-discovery (5 preguntas)"
echo "  /arc-propagate        Propagar cambios genericos a paquetes/proyectos"
echo "  /arc-audit            Auditar conformidad estructural (read-only)"
echo "  /arc-catalog          Refrescar exports/README.md"
echo "  /arc-aggregate        Analisis macro cross-paquete (6 focos)"
echo "  /arc-adversarial      Revision adversarial (cynic + boundary-walker)"
echo ""
echo -e "${CYAN}Proximos pasos:${NC}"
echo "  1. Abrir Claude Code en AgentArchitect/"
echo "  2. Probar: /arc-new-package (crea un paquete via mini-discovery)"
echo "  3. CLI: bash ~/.claude/arc help"
echo ""
