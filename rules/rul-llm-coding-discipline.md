---
name: rul-llm-coding-discipline
description: When writing or modifying code (any language). Four principles to combat LLM coding antipatterns: silent assumptions, overcomplication, orthogonal edits, and weak success criteria. Preloaded by engineering and review agents.
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: quality
  source: "Andrej Karpathy notes (2025-12) + community Four Principles"
  loaded-by: [age-spe-tech-architect, age-spe-code-reviewer, age-spe-test-engineer]
---

# LLM Coding Discipline

When writing or modifying code, follow these 4 principles. Each one targets a specific failure mode observed in LLM-driven coding.

---

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

LLMs default to picking an interpretation silently and running with it. This produces work that's confidently wrong.

### Rules
- **Enuncia asunciones explícitamente** antes de empezar a codear. Ej: "Asumo que necesitas persistencia entre reinicios. Si solo es cache en memoria, dímelo."
- **Si hay ambigüedad real**: pregunta antes de elegir. No "elijas en silencio".
- **Si hay 2+ enfoques razonables**: presenta el tradeoff brevemente, recomienda uno y pide confirmación.
- **Si te confundes**: para. Nombra qué no entiendes. Pide aclaración.
- **Push back cuando sea necesario**: si Pablo pide algo que parece sub-óptimo o contradictorio, dilo educadamente. No asentir por defecto.

### Ejemplos

❌ **Bad** (asunción silenciosa):
> Implementé el cache con Redis y un TTL de 60s.

✅ **Good** (asunción explícita):
> Veo 2 opciones: Redis (rápido, requiere infra) vs in-memory Map (simple, se pierde en restart). Asumo que el reinicio del proceso es raro y la pérdida de cache es aceptable → propongo Map. ¿Confirmas o necesitas Redis?

❌ **Bad** (sycophancy):
> Pablo: "Vamos a usar GraphQL para esto."  
> LLM: "Perfecto, lo implemento."  
> _(cuando es un endpoint simple de healthcheck)_

✅ **Good** (push-back honesto):
> Pablo: "Vamos a usar GraphQL para esto."  
> LLM: "Para un healthcheck es overkill — añade ~200 líneas de schema y resolvers. ¿Hay un motivo (consistencia con otros endpoints, integración con cliente GraphQL existente) o prefieres un GET /health simple?"

---

## 2. Simplicity First

**Mínimo código que resuelva el problema. Nada especulativo.**

LLMs sobre-construyen: añaden flexibilidad que nadie pidió, abstracciones para código de un solo uso, error handling para escenarios imposibles.

### Rules
- **No features más allá de lo pedido.** Si el ticket dice "crear endpoint A", no añadas B "por si acaso".
- **No abstracciones para código de un solo uso.** Si una función se llama 1 vez, inlíneala. La abstracción se hace cuando hay 3 usos reales.
- **No "flexibilidad" o "configurabilidad" que no se pidió.** Hardcodea valores hasta que aparezca un segundo caso.
- **No error handling para escenarios imposibles.** Confía en garantías del framework y código interno. Solo valida en bordes (input de usuario, APIs externas).
- **Si 200 líneas pueden ser 50: reescribe.** No optimices después; pre-empta el bloat.

### Test del senior engineer

Pregúntate: _"¿Un senior engineer revisando este PR diría 'esto está sobre-construido'?"_ Si la respuesta es sí (o "tal vez"), simplifica antes de mostrarlo.

### Ejemplos

❌ **Bad** (sobre-construcción):
```ts
class UserNameFormatter {
  constructor(private config: FormatterConfig) {}
  format(user: User): string { ... }
}
const formatter = new UserNameFormatter({ separator: " ", caps: false });
const display = formatter.format(user);
```

✅ **Good** (simple):
```ts
const display = `${user.firstName} ${user.lastName}`;
```

❌ **Bad** (flexibilidad especulativa):
```ts
function getConfig(env: 'dev' | 'staging' | 'prod' | 'test' | 'preview' = 'prod') {
  // 80 líneas de switch
}
```

✅ **Good** (caso real):
```ts
function getConfig() {
  return process.env.NODE_ENV === 'production' ? PROD : DEV;
}
```

---

## 3. Surgical Changes

**Toca solo lo que el request pide. Limpia solo tu propio desorden.**

LLMs suelen "mejorar" código adyacente, refactorizar lo que no está roto, cambiar comentarios y formato — todo orthogonal al task.

### Rules
- **Cada línea modificada debe trazar al request.** Si no traza, no la toques.
- **No "mejores" código adyacente, comentarios o formato.** Aunque tú lo escribirías distinto.
- **No refactorices lo que no está roto.** Si crees que hay deuda técnica, **menciónala en el reporte final**, no la arregles en este commit.
- **Match el estilo existente** aunque tú prefieras otro. (Excepción: si el estilo viola un linter configurado del proyecto.)
- **Limpia solo huérfanos que TUS cambios crearon** (imports/variables/funciones que dejaste sin usar). NO borres dead code preexistente — menciónalo.
- **No cambies/borres comentarios o código que no entiendes.** Si parece "raro", probablemente hay un motivo. Pregunta o déjalo.

### Caveat: Boy Scout Rule

La regla clásica "deja el código mejor que como lo encontraste" tiene tensión con esta disciplina. Resolución del sistema:

- **En commit principal**: cambios quirúrgicos. Solo lo que pide el ticket.
- **En commit aparte (opcional)**: si ves deuda técnica relevante, propón en el reporte final un commit aparte de refactor con scope claro. Pablo decide si aprueba.

Esto preserva atomicidad de commits y no contamina el diff del feature.

### Test

Pregúntate: _"Si Pablo ve este diff, ¿cada línea cambiada se justifica con el request original?"_ Si hay líneas que no, revierte.

### Ejemplos

❌ **Bad** (cambios orthogonales):
```diff
- function getUser(id) {
+ async function getUser(id: string): Promise<User> {
+   // refactored to use TypeScript and async/await
+   if (!id) throw new Error('id required');
    const result = await db.users.findOne({ id });
-   return result;
+   return result ?? null;
  }
```
Request era: "añadir log al obtener usuario". El resto es bloat orthogonal.

✅ **Good** (quirúrgico):
```diff
  function getUser(id) {
+   logger.info('fetching user', { id });
    const result = await db.users.findOne({ id });
    return result;
  }
```

---

## 4. Goal-Driven Execution

**Define criterio de éxito antes de codear. Loop hasta verificar.**

Tareas imperativas vagas ("haz que funcione", "arregla el bug") no son verificables. Transformarlas a criterios testables permite al LLM iterar de forma autónoma con confianza.

### Rules
- **Antes de codear**: define cómo se verá "hecho". Si no puedes, pregunta.
- **Transforma imperativo → verificable** siempre que sea posible.
- **Para tareas multi-paso**: enuncia plan numerado con verificación por paso.
- **Tests-first** para lógica pura (cálculos, transformaciones, state). Implementation-first para UI/integración.

### Transformaciones

| ❌ Imperativo vago | ✅ Goal-driven |
|---|---|
| "Añade validación" | "Escribe tests para inputs inválidos (vacío, >100 chars, formato wrong), hazlos pasar" |
| "Arregla el bug" | "Escribe un test que reproduce el bug, hazlo pasar sin romper los demás" |
| "Refactoriza X" | "Asegura que los tests pasan ANTES y DESPUÉS del refactor" |
| "Mejora performance" | "Mide latencia actual (P50/P95). Define objetivo. Mide después." |
| "Que funcione" | "Define output esperado para 3 inputs concretos. Verifícalos." |

### Plan numerado para multi-step

```
1. [Acción] → verifica: [cómo sabes que funcionó]
2. [Acción] → verifica: [cómo sabes que funcionó]
3. [Acción] → verifica: [cómo sabes que funcionó]
```

Ejemplo:
```
1. Crear migración para tabla `events` → verifica: `pnpm db:push` sin error
2. Implementar EventRepo.create() → verifica: test unitario pasa
3. Conectar al endpoint POST /events → verifica: integration test devuelve 201 con body válido
```

---

## Scope

### Aplica a
- `/build` y sub-agents que implementan stories
- `age-spe-tech-architect` (cuando genera código de ejemplo en ADRs)
- `age-spe-test-engineer` (cuando escribe tests)
- `age-spe-code-reviewer` (la USA como criterio de auditoría)
- Claude Code directamente cuando edita código en el proyecto

### NO aplica a
- `/hotfix` — ahí justamente se interviene en código que falla. La cirugía exacta es el bug fix, pero a veces hay que tocar lo adyacente para corregir la causa raíz.
- Agentes de análisis/PM (`age-spe-quality-guard`, `age-spe-researcher`, `age-spe-pm-producto`) — no escriben código.
- Documentación pura (markdown sin código).

---

## Antipatrones detectables (para code-reviewer)

`age-spe-code-reviewer` puede usar esta lista como check durante la auditoría:

| Antipatrón | Principio violado | Severidad |
|---|---|---|
| Cambios orthogonales al diff | Surgical Changes | High |
| Abstracción para código de un solo uso | Simplicity First | Medium |
| Validación de imposibles (null check tras non-null assertion) | Simplicity First | Medium |
| Asunción silenciosa que fija decisión arquitectural | Think Before Coding | High |
| "Flexibility" sin segundo caso de uso | Simplicity First | Medium |
| Refactor de código no roto en mismo commit | Surgical Changes | High |
| Borrado de comentarios sin justificación | Surgical Changes | Medium |
| Implementación sin criterio de éxito definido | Goal-Driven Execution | High |
| Sycophancy (asentir cuando debería pushback) | Think Before Coding | Medium |

---

## Origen

Estos principios se derivan de las observaciones de Andrej Karpathy sobre LLM coding (diciembre 2025) y la sistematización posterior de la comunidad en "Four Principles". Adaptados al sistema PM x10 con el caveat del Boy Scout Rule.

Ver `docs/general/wiki/sources/` si la fuente fue ingestada al wiki del proyecto.
