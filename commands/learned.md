---
description: "Log a lesson learned at any moment — bug resolved, tricky problem, discovery, mistake to avoid. Saves to tasks/lessons.md and memory/MEMORY.md."
---

# /learned — Guardar un Aprendizaje

Guarda un aprendizaje en cualquier momento — no tienes que esperar a /review. Usa esto cuando:

- Acabas de resolver un bug dificil y quieres recordar COMO
- Descubriste algo inesperado sobre el proyecto
- Cometiste un error y quieres evitarlo en el futuro
- Encontraste un workaround util
- Algo tardo mucho mas de lo esperado y quieres saber por que

## Como Usarlo

```
/learned                              # Te pregunta que aprendiste
/learned "El bug de timezone se resuelve con UTC siempre"   # Directo
```

## Proceso

### Paso 1: Capturar el Aprendizaje

Si no se proporciona texto, preguntar:

"Que aprendiste? Describe:
1. Que paso (el problema o situacion)
2. Por que paso (la causa raiz)
3. Como lo resolviste (la solucion)
4. Que hacer diferente la proxima vez (la leccion)"

### Paso 2: Clasificar

Clasificar automaticamente en una de estas categorias:

| Categoria | Cuando |
|-----------|--------|
| **bug-resolution** | Resolviste un bug y quieres recordar como |
| **edge-case** | Descubriste un caso borde que nadie previo |
| **performance** | Algo era lento y descubriste por que |
| **architecture** | Decision de arquitectura que funciono (o no) |
| **tooling** | Algo sobre herramientas, librerias, configs |
| **process** | Algo sobre como trabajar mejor |
| **mistake** | Error que no quieres repetir |

### Paso 3: Guardar en tasks/lessons.md

Append con formato:

```markdown
### [Fecha] — [Categoria] — [Titulo corto]
**Problema**: [que paso]
**Causa**: [por que]
**Solucion**: [como se resolvio]
**Leccion**: [que hacer diferente la proxima vez]
**Archivos relevantes**: [paths si aplica]
**Tiempo perdido**: [estimacion — para saber el coste de no saber esto]
```

### Paso 4: Anti-Bloat Check

Antes de guardar, verificar:

1. **Ya existe algo similar?** — Buscar en tasks/lessons.md entradas sobre el mismo tema. Si existe, ACTUALIZAR esa entrada en vez de crear una nueva.
2. **Vale la pena guardarlo?** — Solo guardar si:
   - Tardo >15 minutos en resolver
   - La causa no era obvia
   - Podria pasar de nuevo
   - Revela un gap en tests o proceso
3. **Si es trivial** (typo, config obvia, error de sintaxis): NO guardar. Decir "Esto es trivial, no merece entrada en lessons."

### Paso 5: Actualizar memory/MEMORY.md

Solo si el aprendizaje es un patron que podria repetirse. No para cosas puntuales.

### Paso 6: Confirmar

"Aprendizaje guardado en tasks/lessons.md.
[Si aplica: + memory/MEMORY.md actualizado]
La proxima vez que un agente trabaje, lo vera."

O si es trivial:
"Esto es trivial — no genera entrada en lessons. El fix ya esta en el codigo."

## Anti-Bloat Rules

1. **No duplicar** — si ya existe entrada similar, actualizar
2. **No trivialidades** — typos, errores de sintaxis, configs obvias no se guardan
3. **Umbral de 15 minutos** — si lo resolviste en menos, probablemente no merece entrada
4. **Un aprendizaje = una entrada** — no 5 entradas para el mismo problema
5. **memory/MEMORY.md solo para patrones** — no para cosas puntuales que no se repetiran

## Por Que Importa

- Un bug que te costo 2 horas la primera vez deberia costarte 5 minutos la segunda
- tasks/lessons.md es lo primero que los agentes leen al iniciar sesion
- El optimizer usa estas lecciones para proponer mejoras sistemicas
- Cuando vuelvas en semanas, TODO esta documentado

## Tambien se Puede Usar Para

- "Descubri que la API de pagos tiene rate limit de 100/min — no esta documentado"
- "Los tests E2E fallan si no hay datos seed — hay que correr seed primero"
- "El deploy a Coolify necesita variable X que no esta en el README"
- "Nunca usar git rebase en esta rama porque tiene submodulos"
