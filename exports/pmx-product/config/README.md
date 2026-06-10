# Configuration System

## How It Works

Configuration uses **deep merge**: `default.yaml` is always loaded first, then environment-specific files override specific values.

```
default.yaml ← production.yaml  (production overrides only what's different)
```

## Files

| File | Purpose | When Used |
|------|---------|-----------|
| `default.yaml` | Base configuration for all environments | Always loaded |
| `production.yaml` | Stricter settings for production work | When deploying/releasing |

## Adding New Environments

Create `<env>.yaml` with only the overrides:

```yaml
# config/staging.yaml
log_level: debug
qa:
  tier: light           # Faster QA in staging
scoring:
  flag_below: 4         # More lenient in staging
```

## Key Settings Explained

| Setting | Default | What It Controls |
|---------|---------|-----------------|
| `log_level` | info | Verbosity of agent output |
| `qa.tier` | full | QA depth: none, light, full |
| `qa.auto_activate` | true | Auto-run QA after /review |
| `scoring.conservative` | true | Strict scoring (7=ready, 10=never) |
| `scoring.flag_below` | 5 | Alert threshold per dimension |
| `agents.supervisor_readonly` | true | Enforce read-only for age-sup-* |
| `agents.require_pm_approval` | true | Require PM approval at handoffs |
