---
name: kno-elicitation-methods
description: "Catálogo de técnicas de cuestionamiento para profundizar en problemas, validar premisas, detectar gaps y forzar evidencia. Socrático, pre-mortem, red-team, 5-whys, inversión, devil's advocate, asunción inversa."
license: MIT
user-invocable: false
metadata:
  author: agent-architect
  version: "1.0.0"
  category: methodology
  priority: medium
  inspired-by: "luisdomarco/AiAgentArchitect (elicitation-methods layer)"
---

# Elicitation Methods — Técnicas de cuestionamiento

## Propósito

Cuando el PM o un agente necesita **profundizar en una decisión** (no aceptar la primera respuesta como definitiva), elegir entre alternativas, validar una premisa, o exponer gaps que se han pasado por alto, estas técnicas estructuran el cuestionamiento.

Complementan a `kno-strategic-thinking` (frameworks de pensamiento estratégico). La diferencia: aquí están las **técnicas concretas y aplicables ad-hoc**, mientras que `kno-strategic-thinking` cubre los frameworks más amplios.

## Catálogo

### 1. Socratic Method (Método Socrático)

**Cuándo**: cuando una afirmación se da por obvia pero no se ha desafiado nunca.

**Cómo**: hacer una cadena de preguntas que llevan al hablante a examinar sus propias premisas.

- "¿Qué significa exactamente X?"
- "¿Cómo lo sabes?"
- "¿Qué ejemplo concreto tienes?"
- "¿Y si fuera al revés? ¿Qué cambiaría?"
- "¿Hay alguna situación donde esto NO sería cierto?"

**Resultado típico**: el hablante (o el grupo) descubre que la premisa tiene matices o excepciones que no había considerado.

**Ejemplo**: PM dice "los usuarios prefieren X". Socrático: "¿Qué usuarios? ¿Cuántos? ¿Cómo lo midimos? ¿Hay segmentos que prefieran Y?"

### 2. Pre-Mortem

**Cuándo**: antes de comprometerse con un plan de mediano-largo plazo.

**Cómo**: imaginarse 6-12 meses adelante, asumir que el plan FRACASÓ catastróficamente, y trabajar hacia atrás para identificar las causas más probables.

- "Es enero. Lanzamos el sistema en julio. Fue un desastre. ¿Qué pasó?"
- Enumerar 5-10 causas plausibles, ordenadas por probabilidad.
- Para las top 3: definir mitigaciones AHORA, no después.

**Resultado típico**: se descubren puntos ciegos del plan que no salieron en el análisis "optimista".

**Ejemplo**: en el diseño del arquitecto. Pre-mortem: "Es 2027 y el arquitecto fracasó. ¿Por qué? Posibles: las propagaciones generaron incompatibilidades, los paquetes divergieron de la convención sin que nadie lo notara, el dashboard multi-pestaña tuvo bugs imposibles de depurar, nadie usó el architect-console..."

### 3. Red-Team

**Cuándo**: para validar una propuesta crítica antes de comprometerse.

**Cómo**: nombrar un agente (o tomar tú mismo el rol) que ataque la propuesta como si fuera enemigo. Buscar la peor crítica posible.

- "Si yo fuera un competidor / hater / paranoico, ¿cómo destruiría esta propuesta?"
- "¿Qué interpretación malintencionada podría hacerse?"
- "¿Dónde rompe esto bajo presión?"

**Resultado típico**: aparece el ángulo defensivo que el equipo había ignorado por sesgo de cohesión.

**Ejemplo**: para el modelo "instalador con prefijos" del arquitecto. Red-team: "Esto requiere recordar prefijos. Los usuarios olvidarán cuál es de qué paquete. Las colisiones de naming volverán cuando alguien (no Pablo) cree paquetes sin seguir convenciones. El install.sh global es un punto de fallo único."

### 4. Five Whys (5 Porqués)

**Cuándo**: ante un síntoma, encontrar la causa raíz (no quedarse en la superficie).

**Cómo**: preguntar "¿Por qué?" cinco veces seguidas a cada respuesta.

```
Síntoma: "El propagator falló al desplegar en MiCliente"
¿Por qué? → "El config.json estaba corrupto"
¿Por qué? → "Otro deploy anterior dejó JSON inválido"
¿Por qué? → "deploy.sh no validó el JSON antes de escribir"
¿Por qué? → "No hay validación de schema en deploy.sh"
¿Por qué? → "Nunca se definió un schema canónico para config.json"
→ Causa raíz: falta schema; síntoma es solo manifestación
```

**Resultado típico**: la solución apunta a la causa raíz, no al síntoma. Se evita arreglar lo mismo varias veces.

### 5. Inversion (Inversión / "Munger Inversion")

**Cuándo**: cuando estás estancado intentando responder "¿cómo lograr X?" — invierte el problema.

**Cómo**: en lugar de "¿cómo logro X?", pregunta "¿qué garantizaría que NO logro X?".

- Si quieres "que el arquitecto sea adoptado": ¿qué garantizaría que NO sea adoptado? → ser confuso, demasiado complejo de arrancar, romper PM x10 existente, no tener guía. Inversion da el checklist de qué evitar.

**Resultado típico**: el camino "qué evitar" suele ser más concreto que el camino "qué hacer".

**Origen**: Charlie Munger, vice-chairman de Berkshire Hathaway.

### 6. Devil's Advocate (Abogado del Diablo)

**Cuándo**: ante consenso aparente que se siente "demasiado fácil".

**Cómo**: alguien toma deliberadamente la posición contraria, aunque no la crea. Busca el mejor argumento contra la propuesta.

- Diferente a red-team (que ataca como enemigo): devil's advocate **argumenta razonablemente** desde la posición opuesta.

**Resultado típico**: si la propuesta sobrevive el devil's advocate genuino, hay más confianza. Si no sobrevive, descubrimos un problema temprano.

**Riesgo**: si todo el mundo sabe que es un rol, puede caer en teatro. Hacer rotaciones genuinas.

### 7. Reverse Assumption (Asunción Inversa)

**Cuándo**: cuando una asunción no cuestionada está limitando la creatividad.

**Cómo**: identificar la asunción "obvia" del problema. Invertirla. Diseñar como si la inversión fuera cierta.

- Asunción: "los usuarios quieren más opciones." → Inversa: "los usuarios quieren menos opciones." → ¿Qué diseño emerge?
- Asunción: "el arquitecto tiene que generar paquetes desde cero." → Inversa: "el arquitecto solo edita paquetes existentes." → ¿Qué cambia?

**Resultado típico**: revela diseños alternativos que no habrían surgido aceptando la asunción.

## Cómo elegir la técnica

| Situación | Técnica recomendada |
|-----------|---------------------|
| Una afirmación se da por obvia | Socratic |
| Antes de comprometerse con un plan | Pre-Mortem |
| Validar propuesta crítica | Red-Team |
| Causa raíz de un fallo | Five Whys |
| Estancado intentando lograr X | Inversion |
| Consenso aparente demasiado fácil | Devil's Advocate |
| Asunción no cuestionada limita opciones | Reverse Assumption |

No son excluyentes. Puedes usar varias en una misma discusión. Pre-Mortem + Red-Team es buen combo para decisiones grandes.

## Cuándo NO usar estas técnicas

- Decisiones reversibles y de bajo coste: solo decide y ajusta después. No gastes ronda Socrática en cada email.
- Cuando el grupo ya está cansado y necesita avanzar (cuestionar tiene un coste cognitivo).
- Cuando la información necesaria es **fáctica** y se puede mirar, no debatir.

## Cómo invocarlas en sesiones del arquitecto

El `age-sup-arc-cynic` y `age-sup-arc-boundary-walker` usan estas técnicas por defecto:

- Cynic prefiere Socratic, Red-Team, Devil's Advocate.
- Boundary-Walker prefiere Pre-Mortem, Inversion, Reverse Assumption (orientados a bordes).

El comando `/arc-adversarial` invoca ambos.

El PM puede invocarlas manualmente desde cualquier momento citando explícitamente: "aplica Pre-Mortem a esta decisión" / "Five Whys sobre este fallo".

## Origen

Compilación de prácticas conocidas en ingeniería de decisiones, BPM, estrategia y filosofía. No hay un autor único. Referencias:

- Socratic: Platón / tradición filosófica
- Pre-Mortem: Gary Klein (psicólogo cognitivo)
- Inversion: Charlie Munger
- Five Whys: Taiichi Ohno (Toyota Production System)
- Red-Team / Devil's Advocate: práctica común en intelligence, military planning, design critique
- Reverse Assumption: práctica común en innovation/design thinking
