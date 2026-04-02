---
description: "Analiza disenos de Pencil, extrae funcionalidad completa (6 capas), genera user stories verticales + PRDs por feature. Primer paso antes de /plan (fast) o /analyze (full)."
---

# /design-to-prd — De Disenos a Stories Verticales + PRDs

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

### Paso 7: Presenta resumen
Lista de features detectadas con cantidad de stories, y recomienda siguiente paso (Fast Track o Full Pipeline).

## Donde Guarda Todo

```
docs/working-docs/
├── user-authentication/
│   ├── stories.md               # Story tickets verticales (OUTPUT PRINCIPAL)
│   ├── design-reference.md      # 6 capas analisis raw (referencia opcional)
│   └── prd.md                   # PRD Quality Guard compliant
├── product-catalog/
│   ├── stories.md
│   ├── design-reference.md
│   └── prd.md
└── checkout-flow/
    ├── stories.md
    ├── design-reference.md
    └── prd.md
```

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
docs/working-docs/user-authentication/
├── stories.md                   # De /design-to-prd (o enriquecido por /define)
├── design-reference.md          # De /design-to-prd
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
