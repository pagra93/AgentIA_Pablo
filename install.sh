#!/usr/bin/env bash
# PM x10 Agent System — Installer
#
# What it does:
# 1. Compiles each agent (agent.yaml + SOUL.md + DUTIES.md) into ONE .md file
# 2. Copies commands/ directly (Claude Code reads them as /slash commands)
# 3. Copies skills/ directly (Claude Code reads SKILL.md)
# 4. Copies rules/ as skills (Claude Code doesn't have a rules/ folder)
# 5. Copies knowledge/ as skills (same reason)
#
# Safe: never deletes existing files, prompts before overwriting.
#
# Usage:
#   chmod +x install.sh
#   ./install.sh
#
# After install, open Claude Code in any project and run /new-project

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.claude"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${GREEN}PM x10 Agent System — Installer${NC}"
echo "================================"
echo ""
echo "Source:  $SCRIPT_DIR"
echo "Target:  $TARGET_DIR"
echo ""

# --- Safe write function ---
safe_write() {
    local dest="$1"
    local content="$2"

    if [ -f "$dest" ]; then
        # Check if content is same
        if echo "$content" | diff -q - "$dest" > /dev/null 2>&1; then
            echo -e "  ${GREEN}[identical]${NC} $(basename "$dest")"
            return 0
        fi
        echo -e "  ${YELLOW}[exists]${NC} $(basename "$dest")"
        read -p "    Overwrite? (y/N): " choice
        case "$choice" in
            y|Y)
                echo "$content" > "$dest"
                echo -e "    ${GREEN}[updated]${NC}"
                ;;
            *)
                echo -e "    ${YELLOW}[skipped]${NC}"
                ;;
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
            y|Y)
                cp "$src" "$dest"
                echo -e "    ${GREEN}[updated]${NC}"
                ;;
            *)
                echo -e "    ${YELLOW}[skipped]${NC}"
                ;;
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

# --- Create target directories ---
echo "Creating directories..."
mkdir -p "$TARGET_DIR/agents"
mkdir -p "$TARGET_DIR/commands"
mkdir -p "$TARGET_DIR/skills"
echo ""

# ============================================
# 1. COMPILE AGENTS (3 files → 1 .md)
# ============================================
echo -e "${CYAN}Compiling agents...${NC}"
echo "  (agent.yaml + SOUL.md + DUTIES.md → one .md file)"
echo ""

for agent_dir in "$SCRIPT_DIR/agents"/*/; do
    if [ -d "$agent_dir" ]; then
        agent_name=$(basename "$agent_dir")
        agent_yaml="$agent_dir/agent.yaml"
        soul_md="$agent_dir/SOUL.md"
        duties_md="$agent_dir/DUTIES.md"

        # Start building the compiled .md
        compiled=""

        # Extract frontmatter from agent.yaml
        if [ -f "$agent_yaml" ]; then
            # Read key fields from YAML and convert to MD frontmatter
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

        # Append SOUL.md content
        if [ -f "$soul_md" ]; then
            compiled="$compiled
$(cat "$soul_md")
"
        fi

        # Append DUTIES.md content
        if [ -f "$duties_md" ]; then
            compiled="$compiled

---

$(cat "$duties_md")
"
        fi

        # Write compiled agent
        dest_file="$TARGET_DIR/agents/$agent_name.md"
        safe_write "$dest_file" "$compiled"
    fi
done
echo ""

# ============================================
# 2. COPY COMMANDS (direct — already correct format)
# ============================================
echo -e "${CYAN}Installing commands...${NC}"
for cmd_file in "$SCRIPT_DIR/commands"/*.md; do
    if [ -f "$cmd_file" ]; then
        safe_copy "$cmd_file" "$TARGET_DIR/commands/$(basename "$cmd_file")"
    fi
done
echo ""

# ============================================
# 3. COPY SKILLS (direct — already correct format)
# ============================================
echo -e "${CYAN}Installing skills...${NC}"
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        copy_dir_recursive "$skill_dir" "$TARGET_DIR/skills/$skill_name"
    fi
done
echo ""

# ============================================
# 4. COPY RULES AS SKILLS (Claude Code doesn't have rules/)
# ============================================
echo -e "${CYAN}Installing rules (as skills)...${NC}"
for rule_file in "$SCRIPT_DIR/rules"/*.md; do
    if [ -f "$rule_file" ]; then
        rule_name=$(basename "$rule_file" .md)
        rule_dest="$TARGET_DIR/skills/$rule_name"
        mkdir -p "$rule_dest"
        safe_copy "$rule_file" "$rule_dest/SKILL.md"
    fi
done
echo ""

# ============================================
# 5. COPY KNOWLEDGE AS SKILLS (Claude Code doesn't have knowledge/)
# ============================================
echo -e "${CYAN}Installing knowledge bases (as skills)...${NC}"
for kno_file in "$SCRIPT_DIR/knowledge"/kno-*.md; do
    if [ -f "$kno_file" ]; then
        kno_name=$(basename "$kno_file" .md)
        kno_dest="$TARGET_DIR/skills/$kno_name"
        mkdir -p "$kno_dest"
        safe_copy "$kno_file" "$kno_dest/SKILL.md"
    fi
done
echo ""

# ============================================
# SUMMARY
# ============================================
echo "================================"
echo -e "${GREEN}Installation complete!${NC}"
echo ""

# Count what was installed
agent_count=$(ls "$TARGET_DIR/agents"/*.md 2>/dev/null | wc -l | tr -d ' ')
cmd_count=$(ls "$TARGET_DIR/commands"/*.md 2>/dev/null | wc -l | tr -d ' ')
skill_count=$(ls -d "$TARGET_DIR/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')

echo "Installed:"
echo "  Agents:   $agent_count (compiled to ~/.claude/agents/)"
echo "  Commands: $cmd_count (in ~/.claude/commands/)"
echo "  Skills:   $skill_count (skills + rules + knowledge in ~/.claude/skills/)"
echo ""
echo -e "${CYAN}What Claude Code now has:${NC}"
echo ""
echo "  /challenge          Challenge premises, debate, force evidence"
echo "  /analyze            Evaluate problem/PRD"
echo "  /define             Create JTBDs + stories"
echo "  /story              Build story from idea (autonomous)"
echo "  /plan               Architecture + sprint plan"
echo "  /build              Implement stories"
echo "  /save               Commit + push to GitHub"
echo "  /review             QA pipeline + feature docs"
echo "  /hotfix             Quick bug fix with learning"
echo "  /code-review        Just code review"
echo "  /new-project        Initialize a project"
echo "  /design-to-prd      Designs → PRDs"
echo "  /unknown-unknowns   Risk detection"
echo "  /docs               Project documentation"
echo "  /learned            Save a learning anytime"
echo ""

# ============================================
# PHASE 2: UPDATE EXISTING PROJECTS
# ============================================
echo ""
echo -e "${CYAN}Scanning for existing PM x10 projects...${NC}"
echo ""

# Find CLAUDE.md files that contain PM x10 markers
found_projects=()
while IFS= read -r -d '' claude_file; do
    if grep -q "PM x10\|pm-agent-system\|pm x10\|Orchestration Rules\|specialized agents" "$claude_file" 2>/dev/null; then
        project_dir=$(dirname "$claude_file")
        # Handle both .claude/CLAUDE.md and CLAUDE.md
        if [ "$(basename "$project_dir")" = ".claude" ]; then
            project_dir=$(dirname "$project_dir")
        fi
        found_projects+=("$claude_file")
    fi
done < <(find "$HOME" -maxdepth 8 -name "CLAUDE.md" -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/pm-agent-system/*" -not -path "$SCRIPT_DIR/*" -print0 2>/dev/null)

if [ ${#found_projects[@]} -eq 0 ]; then
    echo "  No existing PM x10 projects found."
else
    echo "  Found ${#found_projects[@]} project(s) with PM x10:"
    echo ""
    for pf in "${found_projects[@]}"; do
        project_dir=$(dirname "$pf")
        if [ "$(basename "$project_dir")" = ".claude" ]; then
            project_dir=$(dirname "$project_dir")
        fi
        echo "  - $(basename "$project_dir")  ($pf)"
    done
    echo ""
    read -p "  Update all project CLAUDE.md files? (y/N): " update_choice
    if [ "$update_choice" = "y" ] || [ "$update_choice" = "Y" ]; then
        echo ""
        for pf in "${found_projects[@]}"; do
            project_name=$(dirname "$pf")
            if [ "$(basename "$project_name")" = ".claude" ]; then
                project_name=$(dirname "$project_name")
            fi
            project_name=$(basename "$project_name")

            updated=false

            # Update agent count: 14/15 → 16
            if grep -q "14 specialized agents\|14 specialized (\|15 specialized agents\|15 specialized (" "$pf" 2>/dev/null; then
                sed -i '' 's/14 specialized agents (10 specialists/16 specialized agents (11 specialists + 5 supervisors/g; s/15 specialized agents (11 specialists/16 specialized agents (11 specialists + 5 supervisors/g' "$pf"
                updated=true
            fi

            # Update knowledge count: 3/4/5 → 6
            if grep -q "Knowledge: [345] " "$pf" 2>/dev/null; then
                sed -i '' 's/Knowledge: [345] .*/Knowledge: 6 (JTBD framework, Mom Test, story splitting, testing strategy, story ticket template, strategic thinking)/g' "$pf"
                updated=true
            fi

            # Update commands count: 13/14 → 15
            if grep -q "Commands: 1[34] " "$pf" 2>/dev/null; then
                sed -i '' 's/Commands: 1[34] slash commands/Commands: 15 slash commands/g' "$pf"
                updated=true
            fi

            # Add /story command if missing
            if ! grep -q "/story" "$pf" 2>/dev/null; then
                sed -i '' 's|/build.*Implement stories|/story              Build story from idea (autonomous)\n/build              Implement stories|' "$pf"
                updated=true
            fi

            # Add /challenge command if missing
            if ! grep -q "/challenge" "$pf" 2>/dev/null; then
                sed -i '' 's|/analyze.*Evaluate problem|/challenge          Challenge premises, debate, force evidence\n/analyze            Evaluate problem|' "$pf"
                updated=true
            fi

            # Add project registry line if missing
            if ! grep -q "project-registry" "$pf" 2>/dev/null; then
                if grep -q "PROJECT_KNOWLEDGE" "$pf" 2>/dev/null; then
                    sed -i '' '/PROJECT_KNOWLEDGE/a\
- Project registry: docs/project-registry.md — technical asset inventory (DB, APIs, components)
' "$pf"
                    updated=true
                fi
            fi

            # Add Testing section if missing
            if ! grep -q "## Testing" "$pf" 2>/dev/null; then
                # Insert before "## Coding Standards" or "## Core Principle"
                if grep -q "## Coding Standards" "$pf" 2>/dev/null; then
                    sed -i '' '/## Coding Standards/i\
## Testing\
\
### Framework\
[Fill in: e.g., Jest, Vitest, Pytest, Playwright]\
\
### Test File Location\
[Fill in: e.g., __tests__/ co-located, tests/ mirrored, e2e/ at root]\
\
### Test Commands\
- Unit/Integration: [e.g., npm test, pytest]\
- E2E: [e.g., npx playwright test]\
- Coverage: [e.g., npm test -- --coverage]\
\
### Test Data\
[Fill in: e.g., factories in tests/factories/, MSW handlers in tests/mocks/]\
' "$pf"
                    updated=true
                elif grep -q "## Core Principle" "$pf" 2>/dev/null; then
                    sed -i '' '/## Core Principle/i\
## Testing\
\
### Framework\
[Fill in: e.g., Jest, Vitest, Pytest, Playwright]\
\
### Test File Location\
[Fill in: e.g., __tests__/ co-located, tests/ mirrored, e2e/ at root]\
\
### Test Commands\
- Unit/Integration: [e.g., npm test, pytest]\
- E2E: [e.g., npx playwright test]\
- Coverage: [e.g., npm test -- --coverage]\
\
### Test Data\
[Fill in: e.g., factories in tests/factories/, MSW handlers in tests/mocks/]\
' "$pf"
                    updated=true
                fi
            fi

            if [ "$updated" = true ]; then
                echo -e "  ${GREEN}[updated]${NC} $project_name"
            else
                echo -e "  ${GREEN}[up-to-date]${NC} $project_name"
            fi
        done
        echo ""
    else
        echo ""
        echo "  Skipped. You can update manually with /new-project in each project."
    fi
fi

echo ""
echo "================================"
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Open Claude Code in any project"
echo "  2. Run /new-project to initialize (or /story to start fast)"
echo "  3. Or start working: /analyze, /define, /build..."
echo ""
echo "  For existing projects: /new-project detects existing CLAUDE.md"
echo "  and adds missing sections without overwriting your content."
echo ""
