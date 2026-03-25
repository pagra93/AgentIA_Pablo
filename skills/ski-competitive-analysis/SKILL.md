---
name: ski-competitive-analysis
description: "Structured competitive analysis workflow. Trigger: 'competitive analysis', 'competitor research', 'market comparison'."
license: MIT
allowed-tools: Read Write WebFetch WebSearch
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: product-management
---

# Competitive Analysis

## Analysis Axes (per competitor)

1. **Product & Features**: Core features, differentiators, notable gaps
2. **Pricing & Model**: Structure, price points, target segment
3. **Positioning & Messaging**: ICP, self-description, value proposition
4. **Strengths & Weaknesses**: What works, what doesn't, customer complaints
5. **Our Opportunity**: Gaps we can fill, differentiators, switching triggers

## Output Format

```markdown
## Competitive Analysis — [Market Area]

### Summary Matrix
| Aspect | Competitor A | Competitor B | Our Opportunity |
|--------|-------------|-------------|-----------------|
| Core offering | ... | ... | ... |
| Pricing | ... | ... | ... |
| Target | ... | ... | ... |
| Key strength | ... | ... | ... |
| Key weakness | ... | ... | ... |

### Detailed Analysis
[Per competitor using 5 axes]

### Strategic Insights
[Key insights with evidence]

### Recommended Differentiators
[What to focus on based on gaps]
```
