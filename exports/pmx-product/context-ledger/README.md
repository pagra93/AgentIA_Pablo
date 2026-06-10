# Context Ledger — PM x10

Log append-only de pasos significativos en este paquete. Heredado de la convención del arquitecto.

Cada entrada es un archivo independiente con el formato:

```
<YYYY-MM-DD>-<HHMMSS>-<agente>.md
```

Ejemplo: `2026-05-18-115500-age-spe-arc-generator.md`

## Qué se registra aquí

- Eventos significativos del paquete (creación, migración, propagaciones recibidas)
- Decisiones tomadas durante un comando importante
- Bloqueos identificados
- Drifts intencionales documentados (con marcador `INTENTIONAL_DRIFT:` o `PACKAGE_SPECIFIC:`)

## Qué NO se registra

- Operaciones triviales
- Stories individuales (esas viven en `docs/producto/features/`)
- Lecciones aprendidas (esas viven en `docs/producto/lessons.md` o `tasks/lessons.md` legacy)

## Reglas

1. **Append-only**: nunca se edita ni borra una entrada. Si una se reveló incorrecta, se añade una NUEVA que la corrige.
2. **Una entrada por evento significativo**, no por cada operación.
3. **Resúmenes**, no transcripciones.
4. **No info sensible** (sin credenciales, tokens, contenido confidencial).
5. **Español con ortografía correcta** (`rul-spanish-orthography`).

## Histórico inicial

Este paquete (`pmx-product`) tiene historial Git previo a la migración al arquitecto (commit base `9bed57e` de 2026-05-14). Las entradas del context-ledger empiezan a partir de su incorporación como paquete first-class (2026-05-18).

Ver: `2026-05-18-*-arc-generator-migration.md` (entrada inicial de la migración).
