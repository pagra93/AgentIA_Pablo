---
description: "Analiza disenos de Pencil, extrae funcionalidad completa (UI+API+DB+logica+integraciones+edge cases), genera PRDs por feature. Primer paso antes de /analyze."
---

# /design-to-prd — De Disenos a PRDs Completos

Analiza cada pantalla de los disenos, detecta features, y genera documentacion completa con PRDs listos para el pipeline.

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

### Paso 3: Analiza 6 capas por pantalla
No solo el diseno visual — extrae TODO lo que implica:
- **UI**: Componentes, estados, interacciones, responsive, accesibilidad
- **DB**: Tablas, relaciones, indices, volumen estimado
- **API**: Endpoints, request/response, auth, paginacion
- **Logica**: Validaciones, calculos, flujos condicionales, permisos
- **Integraciones**: Servicios externos, webhooks, costes
- **Edge Cases**: Fallos de red, concurrencia, datos invalidos, errores

### Paso 4: Genera documentos por feature
Crea una carpeta por feature con:
- `design-analysis.md` — Analisis completo + task list
- `prd.md` — PRD en formato Quality Guard (problema, no solucion)

### Paso 5: Presenta resumen
Lista de features detectadas con cantidad de tareas y prioridad sugerida.

## Donde Guarda Todo

```
docs/working-docs/
├── user-authentication/
│   ├── design-analysis.md     # 6 capas + task list
│   └── prd.md                 # PRD Quality Guard compliant
├── product-catalog/
│   ├── design-analysis.md
│   └── prd.md
└── checkout-flow/
    ├── design-analysis.md
    └── prd.md
```

## Que Hacer Despues

Una vez tienes los PRDs generados, el pipeline normal:

```
/design-to-prd                   # Genera PRDs desde disenos

# Para cada feature:
/analyze                          # Quality Guard evalua + researcher investiga
/define                           # JTBDs + stories + quality coach + splitter
/plan                             # Arquitectura + sprint plan
/build                            # Implementar
/review                           # Verificar + documentar

# Los documentos se van anadiendo a la carpeta de la feature:
docs/working-docs/user-authentication/
├── design-analysis.md            # De /design-to-prd
├── prd.md                        # De /design-to-prd
├── research.md                   # De /analyze
├── jtbds.md                      # De /define
├── stories.md                    # De /define
└── architecture.md               # De /plan
```

## Importante

- El design-analyst analiza las 6 capas SIEMPRE — no se salta DB ni edge cases
- El PRD NO prescribe solucion tecnica (los detalles tech estan en design-analysis.md)
- Las task lists incluyen tipo, prioridad, estimacion, y dependencias
- Funciona con Pencil (MCP tools) o con screenshots/mockups que le pases
