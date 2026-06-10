# Índice de la wiki

Catálogo de todas las páginas. Mantenido automáticamente por `age-spe-wiki-curator` en cada `/wiki ingestar`.

> Última actualización: _(se rellena al ingestar)_

## Por tipo

### Sources
<!-- AUTO:sources -->
_(vacío — ingesta tu primera source con `/wiki ingestar`)_
<!-- /AUTO:sources -->

### Entities
<!-- AUTO:entities -->
_(vacío)_
<!-- /AUTO:entities -->

### Concepts
<!-- AUTO:concepts -->
_(vacío)_
<!-- /AUTO:concepts -->

### Topics
<!-- AUTO:topics -->
_(vacío)_
<!-- /AUTO:topics -->

## Por área (clasificación cruzada por tags)

Esta wiki es transversal. Las páginas pueden tener tags que las asocien a áreas:

- `tags: [producto]` — relacionadas con Producto
- `tags: [marketing]` — relacionadas con Marketing
- `tags: [rrhh]` — relacionadas con RRHH
- `tags: [operaciones]` — relacionadas con Operaciones
- _(sin tag de área)_ — transversales (estrategia, decisiones globales)

Ver `tags.md` para el listado completo de tags con conteos.

## Cómo se mantiene este archivo

Cada vez que ejecutas `/wiki ingestar <path>`, el curator:
1. Crea/actualiza la página correspondiente
2. Inserta una línea en la sección apropiada de este índice
3. Mantiene los marcadores `<!-- AUTO:... -->` intactos

**No edites manualmente entre los marcadores.** Si quieres añadir notas, hazlo fuera de los bloques.
