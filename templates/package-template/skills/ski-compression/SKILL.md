---
name: ski-compression
description: "Comprimir documentos largos en distillates token-efficient sin perder lo esencial. Útil cuando docs/ crece y los agentes empiezan a tragar mucho contexto."
license: MIT
allowed-tools: Read Write
user-invocable: false
metadata:
  author: agent-architect
  version: "1.0.0"
  category: efficiency
  inspired-by: "luisdomarco/AiAgentArchitect (compression layer)"
---

# Compression — Distillates de documentos largos

## Propósito

Cuando un documento crece y se vuelve costoso de cargar repetidamente en contexto (>5k tokens, leído por múltiples agentes), se puede comprimir en un **distillate**: versión condensada que conserva lo esencial.

Ejemplos de candidatos a compresión:

- `pm-agent-system-guia-de-uso.html` (>50k tokens) → distillate de "qué tiene PM x10, cómo se usa cada comando"
- `docs/architect/aggregations/<año-completo>.md` cuando acumulen muchas entradas → distillate anual
- Changelogs muy largos (`changelog/propagations.md` >1000 líneas) → distillate trimestral

NO comprimas si:

- El documento se lee raramente (compresión sin beneficio)
- El detalle es necesario (ej. instrucciones de instalación paso a paso)
- El documento ya es corto (<2k tokens)

## Qué es un distillate

Un distillate es un archivo `.md` paralelo al original, ubicado en `<misma-ruta>/<nombre>.distilled.md`. Conserva:

- **Estructura jerárquica** del original (mismas secciones, mismos H2/H3)
- **Datos críticos** literales (números, nombres, paths, comandos)
- **Decisiones tomadas** y **convenciones** vigentes
- **Una línea de resumen** por cada sección significativa del original

Elimina:

- Ejemplos redundantes (deja 1 por concepto, no 5)
- Justificaciones largas (deja "por X razón" en lugar de 3 párrafos)
- Repeticiones (si algo se dijo en 3 sitios, queda en 1)
- Contenido obsoleto marcado como deprecated
- Detalles de implementación que no son necesarios para el lector típico

## Convención de nomenclatura

| Original | Distillate |
|----------|------------|
| `pm-agent-system-guia-de-uso.html` | `pm-agent-system-guia-de-uso.distilled.md` |
| `docs/architect/aggregations/2026-q1.md` | `docs/architect/aggregations/2026-q1.distilled.md` |
| `changelog/propagations.md` | `changelog/propagations.distilled.md` |

El distillate **vive al lado del original**, con sufijo `.distilled.md` antes de la extensión.

## Cómo se invoca

Cualquier agente del arquitecto o del PM puede invocar esta skill cuando detecta que un documento se está volviendo pesado:

```
Skill: ski-compression
Input:
  source: <path-al-original>
  target: <path-al-distillate> (opcional, default: <source>.distilled.md)
  hint: "foco en: <secciones-prioritarias>" (opcional, para guiar qué conservar)
```

El agente que invoca la skill:

1. Lee el original completo
2. Identifica secciones
3. Para cada sección: extrae lo crítico, descarta lo redundante
4. Compone el distillate con la misma estructura jerárquica
5. Añade frontmatter: `compressed_from: <source>`, `compressed_at: <timestamp>`, `compression_ratio: <ratio>`
6. Escribe en `target`

## Ratio objetivo

- **Documentación humana** (guías, manuales): 0.2-0.4 (distillate ocupa 20-40% del original)
- **Changelogs / logs**: 0.1-0.2
- **Reportes de auditoría / aggregations**: 0.3-0.5

Si el ratio queda >0.6, probablemente el original ya está bien condensado y la compresión no aporta.

Si el ratio queda <0.1, probablemente se está perdiendo información valiosa.

## Cuándo regenerar un distillate

Cuando el original cambia significativamente (>20% de líneas modificadas), el distillate queda obsoleto y hay que regenerarlo.

Detección: comparar `compressed_at` del distillate con `git log -1 --format=%ct <original>`. Si el original es más nuevo, regenerar.

El `age-sup-arc-optimizer` puede detectar distillates obsoletos y proponer regeneración.

## Distillates como referencia

Cuando un agente necesita información de un documento largo, debe preferir leer el **distillate** primero. Solo si el distillate no tiene la respuesta, leer el original.

Esto es consistente con `rul-lazy-loading`.

## Ejemplo de uso

Escenario: `pm-agent-system-guia-de-uso.html` tiene >50k tokens. El `age-spe-arc-generator`, al crear stubs de agentes para un paquete nuevo, quiere consultar "cómo se invoca un agente en PM x10" para no reinventar la rueda.

Sin compresión: el generator carga 50k tokens (la guía entera) para extraer 200 tokens de información útil.

Con compresión:

1. Una vez (manual o batch): generar `pm-agent-system-guia-de-uso.distilled.md` (~12k tokens)
2. El generator lee el distillate
3. Encuentra la sección "Invocación de agentes" condensada
4. Extrae los 200 tokens útiles

Ahorro: 38k tokens por sesión donde el generator necesita esa info.

## Reglas operativas

1. **Nunca comprimir código ni configs**: archivos `.py`, `.yaml`, `.json`, `.toml` se leen completos. Compresión solo aplica a markdown/HTML de documentación.

2. **No comprimir templates `.tmpl`**: los placeholders deben mantenerse exactos. Comprimir un template rompe la sustitución.

3. **Distillates en git**: se versionan junto al original. Cuando regeneras, el diff muestra qué cambió de un período a otro.

4. **Idioma del distillate = idioma del original**: si el original es español, el distillate es español (regla `rul-spanish-orthography`).

5. **No comprimir documentos sensibles**: si el original contiene datos protegidos, ANY compresión los conserva. NO usar esta skill como filtrado de seguridad — eso es otra responsabilidad.
