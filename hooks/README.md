# Hooks — Lifecycle Events in Claude Code

## How Hooks Work

Hooks are shell scripts that run automatically at specific points in the agent lifecycle. In Claude Code, hooks are configured in `~/.claude/settings.json` or project-level `.claude/settings.json`.

## Available Hooks

| Event | Script | Purpose |
|-------|--------|---------|
| `on_session_start` | `hooks/scripts/load-context.sh` | Load memory, lessons, and project knowledge |
| `post_workflow` | `hooks/scripts/update-memory.sh` | Save session findings to working memory |
| `post_review` | `hooks/scripts/append-qa-report.sh` | Append QA results to qa-report.md |

## Claude Code Integration

To use these hooks in Claude Code, add to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Agent",
        "hooks": [
          {
            "type": "command",
            "command": "bash hooks/scripts/load-context.sh"
          }
        ]
      }
    ]
  }
}
```

Or configure them as instructions in CLAUDE.md:
```markdown
## Orchestration Rules
- At session start, read: memory/MEMORY.md, tasks/lessons.md, docs/PROJECT_KNOWLEDGE.md
- After /review, append results to qa/qa-report.md
- After features, update memory/MEMORY.md with new patterns
```

## Note

For most use cases, the CLAUDE.md instructions approach is simpler and more reliable than shell hooks. The scripts here serve as reference implementations.
