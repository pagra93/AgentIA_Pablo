# Good PRD Example: Warehouse Inventory Discrepancy

## 1. Problem Statement
When delivery trucks arrive at the Lleida warehouse with items that don't match the purchase order, the receiving team spends an average of 12 minutes per pallet investigating discrepancies. With 1800 pallets/month, this consumes 360 hours/month of skilled labor.

### Who suffers?
4 receiving operators (shift 6-14h) and 1 inventory analyst (shift 8-16h).

### How do they suffer?
"I have to check three systems and the paper manifest, and half the time the analyst isn't even here yet" — Carlos, receiving operator, Lleida Gemba walk Feb 10, 2026.

### What's the impact?
- 360 hours/month in investigation time
- 18% of pallets have discrepancies (324/month)
- Logistics operator receives report 2 hours after driver has left

## 2. Metrics

### Baseline
| Metric | Current | Source | Measured |
|--------|---------|--------|----------|
| Time per pallet | 12 min | Gemba walk, 20 observations | Feb 2026 |
| Discrepancy rate | 18% | System logs, 3 months | Dec-Feb 2026 |

### Target
| Metric | Target | Timeline | Impact |
|--------|--------|----------|--------|
| Time per pallet | <5 min | Q3 2026 | Save 210 hours/month |
| Investigation time | <3 min | Q3 2026 | Save 27 hours/month |

## 3. Process

### AS-IS
1. Truck arrives → Operator checks paper manifest against PO on System A
2. Operator counts items physically → Records on paper
3. If discrepancy → Operator calls analyst (often not available until 8am)
4. Analyst checks System B → Cross-references with System C
5. Analyst emails logistics → Report arrives ~2 hours later

### TO-BE
1. Truck arrives → Operator verifies items against PO at receiving dock
2. Discrepancy detected → Information available immediately
3. Resolution at the dock within 5 minutes
4. Logistics notified within 15 minutes

### Actors
| Actor | Role | Tools | Pain |
|-------|------|-------|------|
| Receiving operator | Counts/verifies | Paper + System A | Waits for analyst |
| Inventory analyst | Investigates | System B + C | 8am start, backlog |
| Logistics operator | Manages carrier | Email | Report 2h late |
