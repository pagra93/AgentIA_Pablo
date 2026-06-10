---
name: rul-antipatterns
description: "Catalog of 7 story antipatterns and 5 PRD contamination antipatterns with deductive scoring. Preloaded by quality-guard and quality-coach."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "2.0.0"
  category: quality
  source: "AI Mercadona User Story Framework"
  loaded-by: [age-spe-quality-guard, age-sup-quality-coach]
---

# Antipatterns Catalog

## Part A: 5 PRD Contamination Antipatterns (Quality Guard D3)

Used by Quality Guard Dimension 3 (Separacion QUE/COMO). D3 starts at 10 and DEDUCTS per antipattern found.

### Antipattern 1: Jobs-to-be-Done in the PRD (CRITICAL: -3)

JTBDs are product's responsibility, not business's. If the PRD contains job statements, struggle definitions, or outcome prescriptions, it's contaminated.

**Malo**: "Los preparadores necesitan visualizar la ruta de picking optimizada en tiempo real para minimizar desplazamiento."

**Bueno**: "El preparador tarda 45 min en 80 items en 8000 m2. Anda ~2.3 km por ruta (GPS). Benchmark comparable: ~1.2 km. Diferencia: 1.1 km x 10 min/km = 11 min/ruta x 8 rutas/dia = 88 min/dia/persona."

**Why it's bad**: The business is doing product's job. Product loses freedom to explore creative solutions.

### Antipattern 2: Technical Prescriptions (CRITICAL: -3)

"Use REST API", "integrate with SAP", "use blockchain", "use AI"

**Malo**: "Se requiere integracion via REST API con SAP para sincronizar inventario en tiempo real."

**Bueno**: "Hoy hay retraso de 4 horas entre preparacion y reflejo en sistema de inventario. Causa sobreventa: 8-12 devoluciones/dia. Se necesita actualizacion dentro de 15 min del evento."

**Why it's bad**: Prescribes the architecture without understanding the problem. The real need is "15-minute update", not "REST API with SAP."

### Antipattern 3: UI/UX Prescriptions (HIGH: -2)

"10-inch touchscreen", "button for...", "dashboard with...", "drag-and-drop"

**Malo**: "Se requiere pantalla tactil de 10 pulgadas en cada posicion de picking."

**Bueno**: "Preparadores cometen error en 2.3% de picks (confunden articulos similares). Con foto de referencia, error baja de 2.3% a 0.6%. Necesitan acceso a informacion visual clara en condiciones de poca luz, con guantes."

**Why it's bad**: Prescribes the interface without understanding the user context. The need is "clear visual info with gloves in low light", not "10-inch touchscreen."

### Antipattern 4: Solution Language (HIGH: -2)

"The solution should...", "we need software that...", "the app must..."

**Malo**: "La solucion debe permitir a los operadores registrar devoluciones en campo."

**Bueno**: "Cuando una devolucion ocurre en campo, el registro toma 6 horas. En 40% de casos, driver re-entrega a almacen equivocado. Se necesita informacion en punto de devolucion inmediatamente."

**Why it's bad**: The subject is "solution/app" instead of "people/process." Reframe around the problem.

### Antipattern 5: Hypothesis Disguised as Requirement (MEDIUM: -1)

Solution metrics without problem baseline. "Reduce clicks by 50%" is hypothesis, not problem.

**Malo**: "Reducir numero de clics en 50%."

**Bueno**: "40% de usuarios abandonan carrito en paso de pago. 65% abandona despues de ver opciones de envio. Flujo actual: 7 pantallas, 45 campos. Benchmark competidor: 3 pantallas, 20 campos."

**Why it's bad**: "50% less clicks" is a solution hypothesis, not a problem. The problem is "40% cart abandonment at payment step."

### Detection Tool: Alternative Tool Test

If you replace the digital tool with paper/manual and the description STILL WORKS, it's a legitimate problem description. If it dissolves, it was solution prescription.

**Passes**: "Equipo de recepcion necesita verificar que lo que llega coincide con la orden, y registrar discrepancias." → Works on paper? YES. Pure problem.

**Fails**: "En tiempo real, cada cambio en posicion de preparador debe actualizarse en un mapa." → Works on paper? NO. "Real-time" and "map" are solution details.

### D3 Scoring Table

| Antipattern | Severity | Deduction |
|-------------|----------|-----------|
| JTBDs in PRD | Critical | -3 |
| Technical Prescriptions | Critical | -3 |
| UI/UX Prescriptions | High | -2 |
| Solution Language | High | -2 |
| Hypothesis as Requirement | Medium | -1 |

D3 = 10 - (sum of all deductions). Minimum 0.

---

## Part B: 7 Story Antipatterns (Quality Coach)

Used by Quality Coach when reviewing user stories. Each antipattern impacts dimensional scoring.

### 1. Generic User (-2 User Specificity)
- Bad: "As a user, I want to see my dashboard"
- Good: "When the warehouse shift manager starts their morning shift, they need to see overnight exceptions"
- Why: No specific job performer = no specific problem = generic solution

### 2. No Behavior Change (-3 Behavior Change)
- Bad: "Implement caching layer for API responses"
- Good: "Operators will resolve complaints in <2 min instead of 8 min"
- Why: If no human does anything differently, it's a technical task, not a user story

### 3. Fake Story / Tech Task Disguised (-3 JTBD Context)
- Bad: "As a developer, I want to refactor authentication"
- Good: Break into the user-facing outcome the refactor enables
- Why: Developers are not users. Refactoring is maintenance, not a story.

### 4. Solution as Need (-2 JTBD Context)
- Bad: "We need a real-time dashboard with WebSocket updates"
- Good: "Supervisors need visibility within 15 minutes of events"
- Why: Prescribes HOW instead of describing WHAT

### 5. Out of Zone of Control (-3 Zone of Control)
- Bad: "Reduce delivery times by 30%"
- Good: "Reduce time between order-picked and driver-dispatched from 45 to 15 min"
- Why: Team can't control delivery traffic, driver availability, etc.

### 6. Everything Urgent (-2 Time Constraints)
- Bad: "URGENT: All 15 stories in this sprint"
- Good: Prioritize by documented deadline consequences
- Why: If everything is urgent, nothing is. Real urgency has documented consequences.

### 7. Horizontal Split (-3 Survivable Experiment)
- Bad: "Story 1: DB schema → Story 2: API → Story 3: Frontend"
- Good: "Story 1: User can see list → Story 2: User can filter → Story 3: User can sort"
- Why: No story delivers user value independently
