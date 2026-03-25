---
description: "Initialize a new project with CLAUDE.md, docs structure, and task tracking."
---

# /new-project — Project Initializer

## Step 1: Interview

Ask the user:
1. **Project name**: "What's the project called?"
2. **Description**: "Describe it in 1-2 sentences"
3. **Tech stack**: "What technologies? (e.g., React + Node.js + PostgreSQL)"
4. **Platform**: "Web, mobile, API, or combination?"
5. **Team context**: "Solo with AI, or is there a team?"

## Step 2: Create Structure

### .claude/CLAUDE.md
Generate from templates/CLAUDE-template.md, filling in user answers.

### docs/PROJECT_KNOWLEDGE.md
```markdown
# Project Knowledge — [Name]
Last updated: [today]

## What This Project Does
[Description]

## Architecture Overview
[After /plan]

## Features Implemented
| Feature | Date | Status | Notes |

## Key Decisions
| Decision | Date | Why |
```

### tasks/todo.md
```markdown
# Tasks — [Name]
Status: INITIALIZED
[No sprint yet. Use /analyze → /define → /plan]
```

### tasks/lessons.md
```markdown
# Lessons Learned — [Name]

## Patterns to Follow
[Populated by QA Optimizer]

## Mistakes to Avoid
[Populated after corrections]
```

### qa-reports/ (empty directory)

## Step 3: Confirm

"Project initialized. Your PM Agent System is ready.

Next steps:
- /analyze — analyze a problem or PRD
- /define — create JTBDs and stories
- /plan — design architecture and sprint plan
- /build — implement stories
- /review — verify and document

All 14 agents, 4 skills, 5 rules, and 3 knowledge-bases are available."
