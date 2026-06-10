---
name: kno-strategic-thinking
description: "Frameworks de pensamiento estrategico para desafiar premisas, debatir decisiones y forzar claridad. Usado por age-sup-strategic-challenger."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: strategy
  loaded-by: [age-sup-strategic-challenger]
  inspired-by: "gstack (Garry Tan) — /office-hours, /plan-ceo-review"
---

# Strategic Thinking Frameworks

## 1. Clasificacion de Decisiones (Bezos)

**One-way doors vs Two-way doors.**

- **One-way door**: Irreversible o muy costosa de revertir. Requiere analisis profundo, multiples perspectivas, paciencia. Ejemplo: elegir stack tecnologico, arquitectura de datos, pricing model.
- **Two-way door**: Reversible facilmente. Decidir rapido, iterar. Ejemplo: texto de un boton, orden de campos, color de fondo.

**Regla**: El 70% de las decisiones son two-way doors disfrazadas de one-way doors. Si puedes revertir en menos de 1 dia de trabajo, es two-way door. Decide rapido.

**Pregunta al PM**: "¿Que pasa si te equivocas? ¿Cuanto cuesta revertir? Si la respuesta es 'poco', esta es una two-way door — deja de analizarla y decide."

## 2. Reflejo de Inversion (Munger)

**En lugar de preguntar "¿como hago que esto funcione?", preguntar "¿que haria que esto FRACASARA?"**

Las respuestas son los riesgos reales. Mas valioso que brainstorming positivo porque:
- Es mas facil identificar fracaso que exito
- Revela supuestos ocultos
- Genera plan de mitigacion concreto

**Aplicacion**:
1. Preguntar: "Si quisieras que este proyecto fracasara, ¿que harias?"
2. Listar las respuestas (5-8 items)
3. Para cada una: "¿Que tan probable es que esto pase sin que lo provoquemos?"
4. Las respuestas probables son los riesgos que necesitan mitigacion

**Ejemplo**:
- "¿Como hacemos que el onboarding fracasara?" → "Pedir 15 campos en el registro" → "¿Cuantos campos tiene nuestro registro actual?" → 12 → Risk confirmed.

## 3. Foco como Sustraccion (Jobs)

**Decidir que NO hacer es mas importante que decidir que hacer.**

La innovacion no es anadir features — es quitar todo lo que no es esencial hasta que lo esencial brille.

**Aplicacion**:
- "Si solo pudieras entregar UNA cosa de este plan, ¿cual seria?"
- "¿Que puedes QUITAR sin que el usuario note la diferencia?"
- "¿Que feature estas incluyendo por costumbre, no por evidencia?"

**Regla**: Si no puedes explicar por que un feature existe en UNA frase que mencione al usuario, probablemente sobra.

## 4. Escaneo Paranoico (Grove)

**Puntos de inflexion estrategicos: cuando el contexto cambia tanto que invalida tu estrategia.**

**Senales de un punto de inflexion**:
- Un competidor hace algo que antes era imposible
- Una tecnologia reduce costos 10x
- El comportamiento del usuario cambia fundamentalmente
- Una regulacion cambia las reglas del juego

**Pregunta al PM**: "¿Que cambio en el ultimo ano que invalida algo que asumias como cierto?"

## 5. Velocidad de Decision (Bezos)

**El 70% de la informacion es suficiente para decidir.** Esperar al 90% es demasiado lento.

**La mayoria de decisiones deberian tomarse con ~70% de la informacion que te gustaria tener.** Si esperas al 90%, probablemente estas siendo lento.

**Pregunta**: "¿Que informacion adicional cambiaria tu decision? Si la respuesta es 'nada', ya tienes suficiente — decide."

## 6. Secuencia People-First (Horowitz)

**Personas > Productos > Profits.** En ese orden.

**Aplicacion para PM**:
- "¿Quien va a usar esto? ¿Hablaste con ellos?"
- "¿Quien va a construir esto? ¿Tienen la capacidad?"
- "¿Quien va a mantener esto? ¿Estaran motivados?"

---

## Tecnicas de Debate (Anti-Sycophancy)

### Que NO hacer
- Decir "eso es interesante" — no significa nada
- Validar sin evidencia — "¡gran idea!" sin saber si es cierto
- Aceptar la primera respuesta — la respuesta comoda no es la respuesta real
- Preguntar "¿te parece bien?" — genera confirmacion falsa
- Suavizar criticas con halagos vacios — "esto es muy bueno PERO..." devalua el feedback

### Que SI hacer
- **Tomar posicion**: "Creo que esto es debil porque [razon concreta]. ¿Que evidencia tienes de lo contrario?"
- **Reformular vagamente → especificamente**: PM dice "los usuarios lo necesitan" → "¿Cuales usuarios? ¿Cuantos? ¿Cuando te lo dijeron?"
- **Anclar en comportamiento real**: "¿Cuando fue la ultima vez que alguien intento resolver esto? ¿Que paso?"
- **Exigir numeros**: "¿Cuantos? ¿Con que frecuencia? ¿Cuanto cuesta no resolverlo?"
- **Celebrar claridad genuina**: Cuando el PM da una respuesta solida con evidencia, decirlo: "Eso es concreto y verificable. Bien."

### Tecnicas de Pushback Productivo
1. **"¿Y si no?"**: Fuerza al PM a considerar la alternativa de no hacer nada
2. **"¿Para quien exactamente?"**: Fuerza especificidad sobre el usuario
3. **"¿Como lo sabes?"**: Fuerza evidencia sobre suposiciones
4. **"¿Que evidencia te convenceria de lo contrario?"**: Revela si la posicion es ideologica o basada en datos
5. **"¿Que es lo mas barato que puedes hacer para validar esto?"**: Fuerza hacia MVP mental

---

## 6 Forcing Questions (Modo Ideacion)

Adaptadas de gstack's office-hours. Se hacen UNA A UNA. Se empuja cada respuesta.

### 1. Demanda Real
"¿Quien te ha PEDIDO esto? No quien lo 'necesitaria' — quien te lo ha pedido."
- **Push si vago**: "¿Cuantas personas te lo pidieron? ¿Cuando? ¿Con que palabras exactas?"
- **Push si hipotetico**: "Eso suena a lo que CREES que quieren. ¿Alguien lo ha dicho explicitamente?"
- **Buena respuesta**: Nombre concreto, fecha, contexto, cita directa.

### 2. Status Quo
"¿Como lo resuelven HOY sin tu solucion? Si nadie lo resuelve, ¿por que no?"
- **Push**: "¿Por que el status quo es insuficiente? ¿Que intentaron antes?"
- **Red flag**: Si nadie lo resuelve y a nadie le importa, la demanda puede ser inventada.

### 3. Especificidad del Cliente
"Describeme UNA persona real que usaria esto. Nombre, contexto, frecuencia, dolor concreto."
- **Push**: "Mas especifico. ¿Que edad? ¿Que hace en su dia? ¿Cuantas veces por semana enfrenta este problema?"
- **Red flag**: Si no puede nombrar UNA persona, no tiene evidencia de demanda.

### 4. Wedge
"¿Cual es la version MAS PEQUEÑA que puedes lanzar y aun asi validar la hipotesis?"
- **Push**: "Mas pequeno. ¿Que puedes quitar y aun entregar valor?"
- **Objetivo**: Encontrar el MVP mental que valide antes de construir grande.

### 5. Observacion
"¿Has VISTO a alguien intentar resolver esto? ¿Que paso exactamente?"
- **Push**: "Cuentame la escena. ¿Donde estabas? ¿Que hicieron? ¿Cuanto tardaron?"
- **Red flag**: Si nunca ha observado el problema en accion, su comprension es teorica.

### 6. Future-Fit
"Si esto funciona, ¿que construyes despues? Si fracasa, ¿que aprendes?"
- **Push**: "¿Y si funciona a medias? ¿Que metrica te dice si funciono?"
- **Objetivo**: Verificar que hay vision mas alla de esta feature individual.

---

## 4 Modos de Scope (Modo Revision)

Adaptados de gstack's ceo-review. El PM elige despues del premise challenge.

### Modo 1: EXPANSION
Sonar grande. Empujar el scope HACIA ARRIBA intencionalmente.
- "¿Cual es la version platonica ideal de esto?"
- "Si no tuvieras restricciones, ¿como seria?"
- Cada expansion como opt-in individual (no paquete)

### Modo 2: EXPANSION SELECTIVA
Mantener scope base. Bullet-proof. Surfacear expansiones como cherry-picks.
- "El plan base es solido. Aqui hay 3 cosas que podrias anadir si quieres."
- Cada expansion con esfuerzo estimado y riesgo.

### Modo 3: HOLD
Maxima rigidez. Cero scope creep. Cazar landmines.
- "Vamos a revisar cada item y preguntar: ¿es estrictamente necesario?"
- Cualquier adicion requiere quitar algo.

### Modo 4: REDUCCION
Cortar hasta el minimo absoluto que entrega valor.
- "¿Que es lo unico que realmente importa aqui?"
- "Si tuvieras 1 dia en vez de 1 semana, ¿que entregas?"
- Ruthless: si no es core, se va.

---

## 5 Lentes Estrategicos (Modo Revision)

Aplicar secuencialmente despues de elegir modo de scope.

### Lente 1: Premise Challenge
"¿Es este REALMENTE el problema? ¿Que evidencia tienes?"
- Buscar la premisa no examinada debajo de la premisa obvia
- "¿Y si el problema real es otro?"

### Lente 2: Scope Analysis
"¿One-way door o two-way door? ¿Podemos revertir?"
- Aplicar clasificacion Bezos
- Si two-way: "Entonces no gastes mas tiempo analizando — construye y mide"

### Lente 3: Inversion
"Si quisieras que esto FRACASARA, ¿que harias?"
- Listar 5-8 formas de fracasar
- Evaluar probabilidad de cada una
- Las probables necesitan mitigacion explicita

### Lente 4: Alternativas (OBLIGATORIO)
"Dame 2 formas completamente diferentes de resolver esto."
- NO es opcional
- Las alternativas revelan si la solucion elegida es la mejor o solo la primera que se ocurrio
- Comparar esfuerzo, riesgo, y potencial de cada una

### Lente 5: Agujeros
"¿Que pasa cuando [edge case]?"
- Nombres de 47 caracteres, resultados vacios, red caida, usuario daltónico, primer uso vs uso 1000
- "¿Y si [assumption clave] es falsa?"
- "¿Que pasa si 10x mas usuarios de los esperados usan esto?"
