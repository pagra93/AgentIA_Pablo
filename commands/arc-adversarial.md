---
description: "Revisión adversarial del diseño del arquitecto o de un paquete. Cynic desafía premisas; Boundary-Walker explora bordes y casos extremos. Read-only, propositivo. Ejecuta age-sup-arc-cynic + age-sup-arc-boundary-walker."
---

# /arc-adversarial — Revisión adversarial

Invoca a los dos supervisores adversariales en secuencia para desafiar una decisión, propuesta o estado del arquitecto/paquete. Inspirado en `adversarial-review` de luisdomarco, adaptado al formato PM x10.

**Tipo de operación**: read-only. Genera dos reportes (uno por agente). No modifica nada.

## Sintaxis

```
/arc-adversarial                             → diálogo interactivo: ¿qué desafiar?
/arc-adversarial <objeto>                    → objeto explícito (texto libre)
/arc-adversarial --propuesta="<descripción>" → desafiar una propuesta concreta
/arc-adversarial --paquete=<paquete>         → desafiar el diseño actual de un paquete
/arc-adversarial --architect                 → desafiar el propio meta-sistema
```

## Qué hace

Invoca a dos supervisores secuencialmente:

### 1. `age-sup-arc-cynic` (primero)

Desafía cínicamente la propuesta o el diseño. Usa técnicas de `kno-elicitation-methods`:

- **Socratic**: cuestiona premisas dadas por obvias
- **Devil's Advocate**: argumenta razonablemente la posición opuesta
- **Five Whys**: si hay un fallo o decisión, pregunta hasta llegar a causa raíz

Output: reporte con preguntas incómodas, asunciones no verificadas, posibles fallas de razonamiento.

### 2. `age-sup-arc-boundary-walker` (segundo)

Explora bordes y casos extremos. Usa técnicas de `kno-elicitation-methods`:

- **Pre-Mortem**: imagina el sistema fracasando en 6-12 meses, identifica causas plausibles
- **Inversion** (Munger): "¿qué garantizaría que esto NO funcione?"
- **Reverse Assumption**: invierte la asunción central y mira qué se descubre

Output: reporte con casos extremos no considerados, modos de fallo plausibles, asunciones que limitan creatividad.

## Output combinado

Ambos reportes se consolidan en `docs/architect/adversarial/<YYYY-MM-DD>-<objeto-slug>.md`:

```markdown
# Adversarial Review — <objeto> — 2026-05-14

## Cynic (premisas desafiadas)

### Socratic
- ¿Qué significa exactamente "...''?
- ¿Cómo sabes que...?
- ...

### Devil's Advocate
- Argumento opuesto razonable: ...
- ...

## Boundary-Walker (bordes y casos extremos)

### Pre-Mortem
- Es 2027 y este diseño fracasó. Causas plausibles:
  1. ...
  2. ...

### Inversion
- ¿Qué garantizaría que NO funcione?
  - ...

## Síntesis: temas críticos para el PM
1. ...
2. ...

## Notas
(Ambos reportes son **propuestas**, no veredictos. El PM decide qué incorporar.)
```

## Cuándo invocar

- **Antes de decisiones grandes**: añadir un paquete nuevo, migrar PM x10, cambiar el modelo del dashboard, etc.
- **Cuando un diseño parece "demasiado fácil"** y conviene estresarlo antes de comprometerse
- **Después de un fallo significativo**: para entender por qué pasó y qué no se vio venir
- **Antes de propagaciones críticas**: si vas a tocar muchos paquetes, primero hay que estar seguro

## Reglas

- **Adversarial, no destructivo**. El propósito es estresar el diseño, no desmotivar. Los reportes son constructivos: identifican riesgos para mitigarlos.
- **No reemplazan al PM**. Sus salidas son input. El PM decide qué incorporar y qué descartar.
- **No bloquean**. Aunque cynic/boundary-walker descubran problemas críticos, no bloquean al PM. Pueden marcar "ALTA PRIORIDAD" en su reporte.
- **No se invocan en bucle**. Una ronda adversarial es suficiente para la mayoría de decisiones. Si el PM siente que necesita otra, está usando el comando como muleta — mejor decidir y avanzar.

## Cuándo NO usar

- Decisiones reversibles y de bajo coste: no gastes ronda adversarial en cada commit
- Cuando el equipo (tú + Claude) ya tiene fatiga cognitiva: avanzar es a veces mejor que cuestionar más
- Cuando la información necesaria es fáctica, no estratégica: para datos, mirar `/arc-audit` o `/arc-aggregate`

## Limitaciones

- **Sesgo del propio modelo**: cynic/boundary-walker comparten el modelo (Claude). Pueden tener puntos ciegos compartidos. Para temas críticos, complementar con revisión humana.
- **No analizan código**, solo propuestas/diseños. Para revisión de código, usar `/code-review` del paquete correspondiente.
- **Generan ruido si se invocan en exceso**. Mejor 1 ronda contundente que 5 rondas suaves.
