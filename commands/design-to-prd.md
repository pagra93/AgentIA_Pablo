---
description: "Analiza disenos de Pencil, extrae funcionalidad completa (6 capas), genera user stories verticales + PRDs por feature. Primer paso antes de /plan (fast) o /analyze (full)."
---

# /design-to-prd — De Disenos a Stories Verticales + PRDs

## Pre-flight: leer `prompt_override` de la HU

Antes de invocar cualquier agente sobre una HU o EPIC concreta:

1. Localiza el frontmatter YAML de esa HU en `docs/<área>/features/<feature>/stories.md`.
2. Lee el campo `prompt_override`. Si existe y no está vacío, **inclúyelo como contexto adicional explícito** en el mensaje al sub-agente: «Contexto adicional del usuario para esta tarea: <prompt_override>».
3. El sub-agente ya conoce la regla universal (ver `rul-prompt-override` precargado) y la respetará.
4. Si no hay `prompt_override`, procede normal.

Esto vale tanto si el usuario lanza el comando manualmente (clipboard) como si el PM lo lanza autónomamente.

---


Analiza cada pantalla de los disenos, detecta features, y genera **story tickets completos** (no task lists) con PRDs listos para el pipeline.

## Como Usarlo

```
/design-to-prd                    # Analiza el .pen abierto en Pencil
/design-to-prd [path/to/file.pen] # Analiza un archivo especifico
```

## Que Hace

### Paso 1: Lee los disenos
Abre Pencil, captura screenshots, lee componentes y layout de cada pantalla.

### Paso 2: Agrupa en features
5 pantallas de auth → Feature: "User Authentication"
3 pantallas de catalogo → Feature: "Product Catalog"
Etc.

### Paso 2.5: Lee el Project Registry
Si existe `docs/general/project-registry.md`, leelo ANTES de analizar las 6 capas. Esto te dice que DB, APIs, componentes y servicios ya existen (o estan planificados) en el proyecto:
- Si una tabla ya existe (`planned` o `active`), referenciala en "Usa" en vez de rederivarla en Notas tecnicas
- Si un endpoint ya existe, referencialo en vez de redefinirlo
- Si un componente compartido ya existe, usalo en la Anatomia del Diseno
- Solo declara en "Crea" los assets genuinamente nuevos

### Paso 3: Analiza 6 capas por pantalla (paso interno)
Extrae TODO lo que implica cada pantalla — es material de trabajo interno:
- **UI**: Componentes, estados, interacciones, responsive, accesibilidad
- **DB**: Tablas, relaciones, indices, volumen estimado
- **API**: Endpoints, request/response, auth, paginacion
- **Logica**: Validaciones, calculos, flujos condicionales, permisos
- **Integraciones**: Servicios externos, webhooks, costes
- **Edge Cases**: Fallos de red, concurrencia, datos invalidos, errores

### Paso 4: Identifica stories verticales
Traza flujos de usuario (no pantallas). Cada "accion completa" = 1 story candidata. Aplica heuristicas de slicing vertical para que cada story sea independiente, deployable, <=3 dias, y end-to-end.

### Paso 5: Genera story tickets
Produce tickets completos en formato `kno-story-ticket-template` con:
- Historia de Usuario (Como/Quiero/Para + metadata)
- Definicion (contexto + behavior change)
- **Diseno** (anatomia, navegacion, interaccion, accesibilidad — COMPLETO desde las 6 capas)
- Criterios de aceptacion (Given-When-Then + Scenario Outlines)
- **Notas tecnicas** (DB, API, logica, integraciones, edge cases — COMPLETO desde las 6 capas)
- Plan de pruebas DEV y QA
- Scoring 6D

### Paso 6: Genera PRD por feature
PRD en formato Quality Guard (problema, metricas, AS-IS/TO-BE, actores — no solucion tecnica).

### Paso 6.5: Actualiza el Project Registry
Despues de guardar stories.md, actualiza `docs/general/project-registry.md`:
- Para cada asset en la seccion "Crea" de cada story, anade una fila con status `planned`
- NO anadas assets que ya existen en el registry (evita duplicados)
- Actualiza el Quick Reference summary y el conteo total

**CRITICAL — Reglas al escribir al registry**:
1. **Una fila = un asset**. Nunca agrupes. Si una story crea 5 funciones en un archivo, son 5 filas. Si crea 8 endpoints, son 8 filas.
2. **Ortografía**: aplica `rul-spanish-orthography` si el proyecto esta en español — acentos, ñ, ¿, ¡ en todas las descripciones.
3. **Inventario puro**: descripciones factuales, no decisiones pendientes ni comentarios editoriales (ej: NO "> Decision se toma en /plan"). Esas van en architecture.md o ADR.
4. **Categorias base obligatorias**: las 6 categorias base (DB, API, Components, Services, Types, Integrations) NUNCA se eliminan. Deja vacias si no aplican.
5. **Categorias opcionales**: si el stack lo requiere (React/Next.js → Hooks/Pages, backend con workers → Jobs), anade la categoria opcional respetando el orden del template.

### Paso 7: Presenta resumen
Lista de features detectadas con cantidad de stories, y recomienda siguiente paso (Fast Track o Full Pipeline).

## Donde Guarda Todo (V3.2: 2 archivos por feature)

```
docs/producto/features/
├── user-authentication/
│   ├── stories.md   # Story tickets verticales (con bloque YAML por story + "Notas tecnicas" completas)
│   └── prd.md       # PRD Quality Guard compliant (problema, AS-IS/TO-BE, actores — sin solucion tecnica)
├── product-catalog/
│   ├── stories.md
│   └── prd.md
└── checkout-flow/
    ├── stories.md
    └── prd.md
```

**V3.2 change**: el design-analyst ya NO crea `design-reference.md`. Toda la riqueza técnica de las 6 capas (DB, API, Lógica, Integraciones, Edge Cases) va integrada en la sección "Notas técnicas" de cada story específica. Stories.md es la fuente única para implementación.

**V3.3 change (PRD evolutivo)**: el `prd.md` se escribe con **marcadores `<!-- AUTO:section -->`** delimitando las 7 secciones canónicas (problema, métricas, as_is_to_be, actores, scope, diseno_tecnico, stories). Esto permite que `/analyze`, `/define`, `/plan` enriquezcan secciones específicas posteriormente sin sobrescribir lo demás. Ver `agents/age-spe-design-analyst/SOUL.md` Paso 6 para el formato exacto.

## Frontmatter YAML obligatorio (V3.2)

Cada `## HU-XXX:` debe llevar un bloque YAML completo inmediatamente debajo:

```yaml
id: HU-042
parent_epic: EPIC-010
feature: notif-push
status: backlog_sin_priorizar
origin: design
agent_suggested: tech-architect
criticality: medium
created_at: 2026-05-13T10:00:00Z
```

Ver `agents/age-spe-design-analyst/DUTIES.md` sección "Story Frontmatter (REQUIRED)" para detalles completos.

## Step 0: Detectar épicas pre-existentes (V3.2)

ANTES de crear cualquier feature folder, el design-analyst lee `pm/tasks.json`. Si encuentra una épica con `feature: <slug>` que coincida con el feature que está creando (por ejemplo, una idea procesada del inbox):

- **VINCULA** las HUs nuevas a esa épica (`parent_epic: EPIC-XXX` existente)
- Preserva el `title` de la épica original
- Reporta: "EPIC-XXX ya existía, vinculadas N stories nuevas"

Si NO hay match → crea EPIC nueva (comportamiento legacy).

**Patrón de uso target**:
```markdown
## Idea: avisos push de pedidos       ← inbox.md
feature: notif-push
30% del soporte es 'dónde está mi pedido'
```
→ `/pm inbox` crea `EPIC-013` con `feature: notif-push, origin: inbox`
→ Diseñas en Pencil
→ `/design-to-prd` detecta `EPIC-013` y vincula las HUs nuevas a ella (no duplica)

## Que Hacer Despues

### Fast Track (recomendado si el diseno es detallado y dominio conocido)

```
/design-to-prd                   # Genera stories + PRDs desde disenos
/plan                            # Arquitectura y sprint plan (directo)
/build                           # Implementar (dev coge UNA story, tiene TODO)
/review                          # Verificar + documentar
```

Las stories ya tienen todo lo necesario. Las secciones JTBD estan marcadas [DERIVADO].

### Full Pipeline (recomendado si hay incertidumbre o dominio nuevo)

```
/design-to-prd                   # Genera stories + PRDs desde disenos
/analyze                         # Quality Guard evalua + researcher investiga gaps
/define                          # Enriquece secciones [DERIVADO] con evidencia de research
/plan                            # Arquitectura y sprint plan
/build                           # Implementar
/review                          # Verificar + documentar
```

`/define` detecta las stories existentes y las **enriquece** (no duplica):
- **Upgrade**: Historia de Usuario y Definicion pasan de [DERIVADO] a evidencia de JTBD real
- **Preserva**: Diseno y Notas tecnicas del design-analyst se mantienen intactos
- **Merge**: Criterios de aceptacion y Planes de pruebas se complementan
- **Recalcula**: Scoring 6D sube (D1/D2 mejoran con research)

Todo se unifica en el MISMO `stories.md` — sin archivos duplicados.

### Los documentos se van anadiendo a la carpeta de la feature:

```
docs/producto/features/user-authentication/
├── stories.md                   # De /design-to-prd (o enriquecido por /define)
├── prd.md                       # De /design-to-prd
├── research.md                  # De /analyze (si Full Pipeline)
├── jtbds.md                     # De /define (si Full Pipeline)
└── architecture.md              # De /plan
```

## Importante

- El design-analyst analiza las 6 capas SIEMPRE — no se salta DB ni edge cases
- El output son **stories verticales** (tickets completos), no task lists horizontales
- Cada story pasa 4 criterios: independiente, deployable, <=3 dias, end-to-end
- El PRD NO prescribe solucion tecnica (los detalles tech estan en las stories)
- Funciona con Pencil (MCP tools) o con screenshots/mockups que le pases
- Las secciones JTBD se marcan [DERIVADO] — para enriquecerlas usar /analyze + /define

---

## Auto-sync con PM (último paso, automático)

Tras completar todos los pasos anteriores, ejecuta **age-spe-pm-producto** en dos modos secuenciales:

### 1. modo `sync`
- Lee filesystem (stories.md, qa.md, sprint.md, etc.)
- Actualiza `pm/tasks.json` con los cambios producidos por este command
- Actualiza `pm/id-counters.json`
- Reporta drift solo si lo detecta (sino, output silent)

### 2. modo `dossier all`
- Detecta qué feature folders se modificaron en los últimos 60 segundos
- Regenera `_dossier.md` y appendea evento a `_events.jsonl` en cada una
- Preserva sección `<!-- USER:notes -->` del dossier
- Output silent excepto reporte breve de qué dossiers se actualizaron

**Por qué**: el dashboard refleja el nuevo estado (kanban + tabla + dossiers contextuales) sin que tengas que ejecutar `/pm sync` ni `/pm dossier` manual. Si el sync detecta drift, se reporta al final.
