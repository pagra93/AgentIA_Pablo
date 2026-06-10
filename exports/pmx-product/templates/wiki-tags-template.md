# Tags

Índice de etiquetas con conteos. Mantenido por `age-spe-wiki-curator`.

> Recalculado en cada `/wiki ingestar` y `/wiki etiqueta`.

## Tags activos

<!-- AUTO:tags -->
_(sin tags todavía)_
<!-- /AUTO:tags -->

## Convenciones de tags

- **Áreas**: `producto`, `marketing`, `rrhh`, `operaciones` (clasifican a qué área pertenece la página)
- **Tipos de decisión**: `decisión`, `principio`, `política`
- **Status**: `activo`, `obsoleto`, `propuesto`
- **Naturaleza**: `idea`, `pregunta-abierta`, `hipótesis`, `aprendizaje`
- **Temas técnicos**: libre — los más usados se consolidan con el tiempo

## Cómo añadir un tag

```
/wiki etiqueta docs/general/wiki/concepts/decision-stripe.md decisión activo producto
```

O directamente editando el frontmatter de la página:

```yaml
tags: [decisión, activo, producto]
```

Y luego ejecutando `/wiki revisar` para regenerar el índice.
