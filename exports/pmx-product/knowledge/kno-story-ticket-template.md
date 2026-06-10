---
name: kno-story-ticket-template
description: "Formato universal de story ticket. Usado por design-analyst, story-writer y story-builder. Integra JTBD Reforzado, behavior change, 6D scoring, diseno, notas tecnicas y planes de pruebas."
license: MIT
user-invocable: false
metadata:
  author: pm-agent-system
  version: "1.0.0"
  category: template
  loaded-by: [age-spe-design-analyst, age-spe-story-writer, age-spe-story-builder]
---

# Story Ticket Template (Universal)

## Cuando Usar

Todos los agentes que producen user stories DEBEN usar este template. El template tiene secciones obligatorias y condicionales. Las condicionales dependen del ORIGEN de la story (DISENO, RESEARCH, IDEA).

Los 3 agentes productores de stories:
- **design-analyst**: Origen DISENO — llena Diseno y Notas tecnicas completamente
- **story-writer**: Origen RESEARCH — llena Historia, Definicion, Criterios completamente
- **story-builder**: Origen IDEA — llena todo pero con marcadores [DERIVADO] / [HIPOTESIS]

---

## Template

```markdown
## HU-[ID]: [Titulo Descriptivo]

**Como** [job performer especifico — NUNCA "usuario"],
**Quiero** [capability],
**Para** [outcome].

| Campo | Valor |
|-------|-------|
| **Epic** | [nombre] |
| **Feature** | [nombre] |
| **JTBD Traza** | [referencia al JTBD — o [DERIVADO] si inferido] |
| **Stakeholder** | [persona de contacto — o [PENDIENTE]] |
| **Importante** | [notas clave, constraints, riesgos] |
| **Validacion** | [como validar que funciona] |
| **Metricas** | [metricas de exito: Minimo / Target / Over-top] |
| **Estimacion** | [S/M/L con dias — maximo 3 dias] |
| **Origen** | [DISENO / RESEARCH / IDEA] |

---

## Definicion

### Contexto
[POR QUE existe esta story. Problema que resuelve. Link a PRD si existe.]

### Objetivo
[QUE logra la story. Resultado medible.]

### Behavior Change
- **START**: [nueva conducta + frecuencia]
- **STOP**: [conducta eliminada]
- **DIFFERENT**: [conducta que cambia — de X a Y]

**Rangos de Cambio**:
| Nivel | Descripcion | Metrica |
|-------|-------------|---------|
| Minimo | [lo peor que aceptamos] | [metrica] |
| Target | [lo que disenamos para lograr] | [metrica] |
| Over-top | [lo mejor posible] | [metrica] |

---

## Diseno

### AS IS / TO BE
[Comparacion: estado actual vs estado disenado]

### Anatomia
[Desglose de componentes UI]
- [Componente 1]: [estados, variantes, comportamiento responsive]
- [Componente 2]: ...

### Navegacion
[Wireflow / flowchart entre pantallas]
- [Screen A] → [accion] → [Screen B]
- ...

### Interaccion
[Interacciones, mensajes al usuario, transiciones de estado]
- [Interaccion 1]: [trigger, respuesta, feedback]
- Estado vacio: [que ve el usuario]
- Estado cargando: [que ve el usuario]
- Estado error: [que ve el usuario]
- Estado exito: [que ve el usuario]

### Accesibilidad
[Keyboard navigation, screen reader, contraste]

### Enlaces diseno
- **Desktop**: [link a frame Pencil/Figma]
- **Mobile**: [link o N/A]

---

## Criterios de aceptacion

**Feature**: [nombre de la feature]

**Scenario**: [nombre del happy path]
**Given** [precondicion]
**When** [accion del usuario]
**Then** [resultado observable]

**Scenario**: [nombre de path alternativo]
**Given** [precondicion]
**When** [accion]
**Then** [resultado]

**Scenario Outline**: [nombre parametrizado]
**Given** [precondicion con <param>]
**When** [accion con <param>]
**Then** [resultado con <param>]

**Examples**:
| param1 | param2 | resultado_esperado |
|--------|--------|--------------------|
| [val]  | [val]  | [resultado]        |
| [val]  | [val]  | [resultado]        |

---

## Notas tecnicas

### Modelo de Datos
| Tabla | Campos Clave | Relaciones | Indices |
|-------|-------------|------------|---------|
| [tabla] | [campos] | [FK a...] | [indices] |

### API Endpoints
| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| [method] | [path] | [auth] | [body] | [response] |

### Logica de Negocio
- [Regla 1]: [descripcion]
- [Regla 2]: [descripcion]

### Integraciones
| Servicio | Para que | Coste Estimado | Rate Limits |
|----------|---------|---------------|-------------|
| [servicio] | [proposito] | [coste] | [limites] |

### Edge Cases y Errores
| Caso | Que Pasa | Como Manejarlo |
|------|----------|---------------|
| [caso] | [impacto] | [manejo] |

---

## Dependencias del Proyecto

### Usa (assets existentes del registry)
| Asset | Tipo | Del Feature | Nota |
|-------|------|-------------|------|
| [nombre] | [tipo] | [feature origen] | [como se usa] |

### Crea (assets nuevos para el registry)
| Asset | Tipo | Detalles |
|-------|------|----------|
| [nombre] | [tipo] | [campos/props/exports clave] |

**Tipos permitidos**: `db` / `api` / `component` / `service` / `type` / `integration` / `hook` / `page` / `job` / `util` / `lib` / `middleware`

**Reglas de llenado**:
- **Una fila = un asset**. No agrupes funciones aunque vivan en el mismo archivo. Si una story crea 5 fetchers en `api/users.ts`, son 5 filas separadas.
- **Ortografía correcta**: aplica `rul-spanish-orthography` cuando el proyecto esté en español (acentos, ñ, ¿, ¡).
- **Solo hechos técnicos**: nada de "decisión pendiente" o "a elegir en /plan" — esas decisiones van en `architecture.md` o ADR.

---

## Verificacion Estructural

### Verdades (que debe ser CIERTO cuando la story esta hecha)
- [ ] [afirmacion verificable — ej: "El usuario puede ver mensajes existentes"]
- [ ] [afirmacion verificable — ej: "Los mensajes persisten tras refresh"]

### Artefactos (que debe EXISTIR y ser sustancial)
| Archivo | Que provee | Min lineas | Exporta | Contiene |
|---------|-----------|------------|---------|----------|
| [path esperado] | [descripcion] | [numero] | [exports] | [patron grep] |

### Conexiones (que debe estar CABLEADO)
| Desde | Hacia | Via | Patron grep |
|-------|-------|-----|-------------|
| [componente] | [endpoint/tabla] | [mecanismo: fetch, import, query] | [regex verificable] |

---

## MRs de paso a sprint
[Se completa durante desarrollo]

---

## Plan de pruebas DEV

**Rol**: [rol con el que se hacen las pruebas]

### Tests Automatizados
- [ ] [test derivado de acceptance criteria — tipo: unit/integration/e2e]
- [ ] [test derivado de acceptance criteria]
- [ ] ...

### Verificacion Manual
- [ ] [paso de verificacion manual]
- [ ] ...

---

## Plan de pruebas QA

**Rol**: [rol con el que se hacen las pruebas]

### Testing Funcional
- [ ] [caso de test de los acceptance criteria]
- [ ] ...

### Regression
- [ ] [areas a testear por regresion]
- [ ] ...

### Exploratorio
- [ ] [areas para testing exploratorio]
- [ ] ...

---

## Scoring 6D

| Dimension | Score | Justificacion |
|-----------|-------|--------------|
| JTBD Context | X/10 | [justificacion] |
| User Specificity | X/10 | [justificacion] |
| Behavior Change | X/10 | [justificacion] |
| Zone of Control | X/10 | [justificacion] |
| Time Constraints | X/10 | [justificacion] |
| Survivable Experiment | X/10 | [justificacion] |
| **Promedio** | **X/10** | |
```

---

## Reglas de Llenado por Origen

Cada seccion se llena diferente segun el ORIGEN de la story:

| Seccion | DISENO | RESEARCH | IDEA |
|---------|--------|----------|------|
| Historia de Usuario | Completa | Completa | Completa, job performer [DERIVADO] |
| Definicion | Behavior Change [DERIVADO] | Completa (evidencia de research) | [HIPOTESIS — validar con datos] |
| **Diseno** | **COMPLETA** (fuente primaria) | [PENDIENTE DE DISENO] | [DERIVADO del contexto] |
| Criterios de aceptacion | Completa (de Capas 4+6) | Completa (de JTBD criteria) | Completa [DERIVADO] |
| **Notas tecnicas** | **COMPLETA** (de Capas 2-6) | [DERIVADO — validar en /plan] | [DERIVADO — validar en /plan] |
| **Dependencias del Proyecto** | **COMPLETA** (de Capas 2-5 + registry) | [DERIVADO — validar en /plan] | [DERIVADO — validar en /plan] |
| **Verificacion Estructural** | **COMPLETA** (Verdades de Capas 4+6, Artefactos de Capas 1-3, Conexiones de Capa 5) | Verdades completas, Artefactos/Conexiones [DERIVADO] | Todo [DERIVADO — validar en /plan] |
| Plan pruebas DEV | Completa | Completa | [DERIVADO] |
| Plan pruebas QA | Completa | Completa | [DERIVADO] |
| Scoring 6D | Completa (scores D1-D2 menores sin research) | Completa (scores mas altos) | Completa (scores menores) |

---

## Marcadores de Confianza

Todos los agentes usan estos marcadores para indicar el nivel de confianza:

| Marcador | Significado | Accion recomendada |
|----------|------------|-------------------|
| `[DERIVADO]` | Inferido del contexto del diseno o la idea, no de investigacion | Aceptable para Fast Track; enriquecer con /analyze para Full Pipeline |
| `[HIPOTESIS — validar con datos]` | Asumido sin evidencia | Validar con research antes de sprint si es critico |
| `[GAP — requiere investigacion]` | Informacion desconocida | Cerrar con /analyze antes de sprint |
| `[PENDIENTE DE DISENO]` | Seccion necesita trabajo de diseno | Crear diseno en Pencil y usar /design-to-prd |
| `[PENDIENTE]` | Requiere input del PM | PM debe completar antes de sprint |

---

## Mapeo 6-Capas → Secciones del Template

Cuando el origen es DISENO, el design-analyst mapea cada capa a su seccion:

| Capa del Analisis | Seccion en Story Ticket |
|-------------------|------------------------|
| **Capa 1: UI/Componentes** | Diseno → Anatomia, Navegacion, Interaccion, Accesibilidad |
| **Capa 2: Datos/DB** | Notas tecnicas → Modelo de Datos + **Dependencias del Proyecto** (Usa/Crea tablas) |
| **Capa 3: API/Endpoints** | Notas tecnicas → API Endpoints + **Dependencias del Proyecto** (Usa/Crea endpoints) |
| **Capa 4: Logica de Negocio** | **Split**: reglas testables → Criterios de aceptacion (Scenarios); reglas de negocio → Notas tecnicas → Logica |
| **Capa 5: Integraciones** | Notas tecnicas → Integraciones + **Dependencias del Proyecto** (Usa/Crea servicios, integraciones) |
| **Capa 6: Edge Cases** | **Split**: testables → Criterios de aceptacion (Scenario Outlines negativos); sistemicos → Notas tecnicas → Edge Cases |

**Regla clave del split**: Si un edge case o regla de logica se puede expresar como Given-When-Then, va a Criterios de aceptacion. Si es una preocupacion sistemica (performance, concurrencia, infraestructura), va a Notas tecnicas.

---

## Reglas Generales

1. **NUNCA "As a user"** — Siempre job performer especifico con contexto
2. **Minimo 2 Scenarios** en Criterios de aceptacion (happy path + al menos un alternativo/negativo)
3. **Estimacion maxima 3 dias** — Si es mayor, debe pasar por story-splitter
4. **Scoring promedio >= 7** para estar lista (Definition of Ready)
5. **Cualquier dimension < 3** = flag critico automatico
6. **MRs de paso a sprint** siempre vacia al crear — se completa durante desarrollo
7. **Plan de pruebas** siempre indica el ROL con el que se prueban
8. **Un ticket por story** — No mezclar multiples stories en un solo ticket
