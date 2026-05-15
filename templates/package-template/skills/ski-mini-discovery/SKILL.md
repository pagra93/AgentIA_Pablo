---
name: ski-mini-discovery
description: "Mini-entrevista estructurada de 5 preguntas para capturar suficiente información antes de crear un paquete/feature nuevo. Una pregunta por turno, validaciones explícitas, checkpoint final antes de actuar. Inspirada en ski-process-interviewer de luisdomarco (BPM/BPA reverse engineering, Lite edition)."
license: MIT
allowed-tools: Read Write
user-invocable: false
metadata:
  author: agent-architect
  version: "1.0.0"
  category: elicitation
  loaded-by: [age-spe-arc-generator]  # Y cualquier agente futuro que necesite mini-entrevistas
  inspired-by: "luisdomarco/AiAgentArchitect (ski-process-interviewer)"
---

# Mini-Discovery Skill

Protocolo estructurado de entrevista breve (5 preguntas) para capturar información mínima antes de generar un artefacto complejo (paquete nuevo, feature mayor, sistema). Evita el "blank-page paralysis" y garantiza que el output nazca con contenido útil, no vacío.

## Cuándo usar

- Antes de crear un paquete desplegable nuevo (`age-spe-arc-generator` lo invoca)
- Antes de crear una feature/proyecto complejo donde la información mínima del PM no está pre-capturada
- Antes de cualquier generación que tenga riesgo de "esqueleto vacío que el PM no sabe llenar"

## Input

- Contexto del invocador (qué tipo de artefacto se va a crear)
- (Opcional) Argumentos pre-rellenados que saltan preguntas correspondientes

## Output

Estructura de datos con 5 campos + extras inferidos:

```yaml
discovery_result:
  name: "<nombre kebab-case>"
  domain: "<dominio + propósito en una frase>"
  prefix: "<2-4 letras, propuesto y confirmado>"
  domain_folder: "<carpeta en docs/ del proyecto cliente>"
  stages: "<flujo principal: stage1 → stage2 → ...>"
  expected_agents:
    - name: "<agente-1>"
      responsibility: "<una línea>"
    - name: "<agente-2>"
      responsibility: "<una línea>"
  outputs: "<artefactos canónicos producidos>"
```

## Procedure

### Principios operativos

1. **Una pregunta por turno**. Nunca presentar las 5 a la vez (el PM se satura).
2. **Validar respuesta antes de pasar a la siguiente**. Si es ambigua, pedir aclaración (aplicar técnicas de `kno-elicitation-methods` cuando aplique).
3. **Sub-preguntas implícitas** cuando algo se puede deducir y confirmar (prefix, domain_folder).
4. **Checkpoint final**: resumir las 5 respuestas + extras inferidos antes de devolver al invocador.

### Pregunta 1 — Nombre

```
PREGUNTA 1 / 5

¿Cuál será el nombre?

Convención: kebab-case, descriptivo.
Ejemplos: `newsletter-system`, `marketing-system`, `hr-system`.
```

**Validaciones**:
- Kebab-case válido (`^[a-z][a-z0-9-]+$`)
- No reservado en el contexto (ej: `template`, `arc` para paquetes del arquitecto)
- Único en el destino (ej: si va a `exports/<nombre>/`, verificar que no existe)

Si el nombre colisiona o es inválido: proponer alternativas concretas (timestamped, variantes) y volver a preguntar.

### Pregunta 2 — Dominio y propósito

```
PREGUNTA 2 / 5

¿Cuál es el dominio y propósito en una frase?

Define qué hace a alto nivel. Va a CLAUDE.md, SOUL.md, agent.yaml.

Ejemplos:
- "Pipeline editorial para crear newsletters semanales"
- "Sistema de campañas de marketing multicanal"
- "Reclutamiento y onboarding de candidatos técnicos"
```

**Validación**: longitud razonable (>10 caracteres, <200). Si es ambigua, aplicar Socratic (per `kno-elicitation-methods`):
- "¿Qué resultado concreto produce?"
- "¿Quién consume el output?"

### Sub-pregunta implícita: prefix

```
Propongo prefix: `<prefix>` (deducido de "<dominio>").
Los agentes serán `age-spe-<prefix>-*` y los comandos `/<prefix>-*`.

Confirmar:
(A) Sí · (B) Otro prefix: ___ · (C) Saltar
```

**Reglas de deducción del prefix**:
- 2-4 letras, solo minúsculas
- Tomar abreviatura del nombre o dominio: `newsletter-system` → `news`, `marketing-system` → `mkt`, `hr-system` → `hr`
- Comprobar que no colisiona con prefijos existentes (leer `exports/*/agent.yaml` campo `metadata.prefix`)
- No usar reservados (`arc`)

### Sub-pregunta implícita: domain_folder

```
Propongo domain folder: `<folder>` (carpeta en docs/ del proyecto cliente).
Confirmar (A) Sí · (B) Otro: ___
```

**Reglas**: kebab-case, derivado del dominio. Ejemplo: dominio `editorial-content` → `newsletter` (o `editorial`); el PM elige.

### Pregunta 3 — Etapas del flujo

```
PREGUNTA 3 / 5

¿Cuáles son las etapas principales del flujo?

Define la cadena de trabajo. Va al system-overview.md y guía la generación de stubs.

Ejemplos:
- "research → outline → draft → edit → publish"
- "ideation → brief → diseño → produccion → analytics"
- "intake → screening → entrevista → oferta → onboarding"
```

**Validaciones**:
- Al menos 2 etapas (si solo 1, advertir: "¿realmente un solo paso? ¿iterativo o lineal?")
- Si más de 8 etapas, advertir (puede ser demasiado granular para un solo paquete)

### Pregunta 4 — Agentes previstos

```
PREGUNTA 4 / 5

¿Qué agentes principales prevés? Lista informal: nombre + responsabilidad de una línea.

Convención: cada uno será un stub `age-spe-<prefix>-<nombre>/` con DUTIES.md
marcando `TODO: implementar`.

Ejemplos:
- topic-researcher: investiga tema del número
- content-curator: selecciona fuentes
- outline-architect: estructura el draft
```

**Validaciones**:
- Al menos 1 agente
- Si más de 10, advertir (¿realmente necesarios? muchos sistemas funcionan con 3-6)
- Cada nombre kebab-case válido (sin el prefix, se añade automáticamente)
- Sin duplicados

### Pregunta 5 — Outputs

```
PREGUNTA 5 / 5

¿Qué outputs/artefactos principales produce?

Define los productos canónicos.

Ejemplos:
- "número de newsletter en .md y .html, métricas de envío"
- "campañas (.md), assets (jpg/mp4), informe de performance"
- "ofertas firmadas, expedientes, métricas de tiempo a contratación"
```

**Validación**: longitud razonable; si es genérico ("informes", "documentos"), pedir concretitud.

### Checkpoint final

Antes de devolver el resultado al invocador, resumir todo y pedir OK:

```
RESUMEN DEL DISCOVERY

Nombre:           <nombre>
Prefix:           <prefix>
Dominio:          <dominio>
Domain folder:    <folder>
Etapas:           <stages>
Agentes (N):
  - <agente-1>: <responsabilidad>
  - <agente-2>: <responsabilidad>
  ...
Outputs:          <outputs>

¿Confirmar? (A) Sí, proceder · (B) Ajustar pregunta N · (C) Cancelar
```

Si A: devolver `discovery_result` al invocador.
Si B: volver a la pregunta indicada.
Si C: abortar, sin efectos colaterales.

## Reglas operativas

- **Una pregunta por turno**: nunca presentar varias a la vez.
- **No avanzar con respuesta ambigua**: aplicar Socratic (Five Whys, etc.) hasta clarificar.
- **Sub-preguntas se confirman antes de seguir**: prefix y domain_folder no son asunciones silenciosas.
- **Checkpoint obligatorio**: nunca devolver el resultado sin validar el resumen con el PM.
- **Idempotencia**: si el PM dice (C) cancelar, no quedan rastros (la skill no escribe nada).
- **Aplicar `rul-spanish-orthography`** en todas las preguntas.

## Skills complementarias

| Skill | Cuándo |
|-------|--------|
| `kno-elicitation-methods` | Si una respuesta es ambigua, aplicar Socratic / Five Whys |
| `rul-naming-conventions` | Para validar nombres y prefijos |
| `rul-spanish-orthography` | Para las preguntas y validaciones |

## Inspiración y diferencias con `ski-process-interviewer` de luisdomarco

luisdomarco tiene `ski-process-interviewer` (en su Lite edition) que implementa una entrevista BPM/BPA mucho más profunda (interview principles, response quality validations, alert signals to detect hidden complexity). Es más rigurosa pero también más larga.

**`ski-mini-discovery`** es una versión **acotada y predecible**: 5 preguntas concretas, validaciones simples, checkpoint final. Diseñada para casos donde el PM ya tiene clara la idea y solo necesitamos capturar suficiente información para no nacer con esqueleto vacío.

Si en el futuro un paquete necesita entrevistas más profundas (research de producto, descubrimiento BPM), se puede crear `ski-deep-discovery` aparte. No la mezclamos aquí.
