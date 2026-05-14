---
description: "Análisis macro cross-paquete. Detecta patrones repetidos (candidatos a promover a genérico), comparativas y gaps. Read-only, genera reporte en docs/architect/aggregations/. Ejecuta age-spe-arc-aggregator."
---

# /arc-aggregate — Análisis macro cross-paquete

Mira el ecosistema de paquetes en su conjunto y responde preguntas que NO se pueden responder mirando un solo paquete: "¿qué patrones de agentes se repiten entre paquetes?", "¿qué tiene cada uno y qué falta?", "¿hay candidatos para promover a genérico?".

**Tipo de operación**: read-only. Genera reportes en `docs/architect/aggregations/`. No modifica paquetes ni propone cambios automáticos (eso es trabajo del propagator, con PM en el medio).

## Sintaxis

```
/arc-aggregate                                  → diálogo interactivo: elige foco
/arc-aggregate <foco>                           → con foco explícito
/arc-aggregate <foco> --to=<path>               → guarda reporte en ruta concreta
/arc-aggregate <foco> --packages=<lista>        → limita a un subset de paquetes (default: todos)
```

## Focos disponibles

### `patrones`

Detecta agentes/skills/comandos que se repiten entre paquetes (mismo nombre, mismo propósito, lógica similar). **Candidatos a promover a genérico.**

Ejemplo de output:

```markdown
### Patrón detectado: "research" en 3 paquetes
- newsletter-system: age-spe-news-topic-researcher
- marketing-system: age-spe-mkt-campaign-researcher
- (futuro) hr-system: age-spe-hr-candidate-researcher

Sugerencia: extraer una skill genérica `ski-mom-test-interviewer` (ya existe en knowledge/) y reescribir los 3 agentes para usarla. Reduce duplicación.
```

### `comparativa`

Tabla con qué tiene cada paquete y qué le falta respecto a la convención canónica o a otros paquetes pares.

Ejemplo:

```markdown
| Paquete | #Agentes | #Comandos | Tiene QA layer | Tiene wiki | Salud |
|---------|----------|-----------|----------------|------------|-------|
| newsletter-system | 6 | 0 (stubs) | ✅ | ❌ | ⚪ Recién creado |
| pmx-product       | 18 | 16 | ✅ | ✅ | 🟢 Vivo |
```

Gaps detectados:
- `newsletter-system` no tiene comandos propios (sigue solo con stubs)
- `newsletter-system` no tiene curador wiki (¿debería?)

### `gaps`

Qué falta en cada paquete respecto a `config/conventions.yaml`:

```markdown
### Paquete: newsletter-system
- ⚠️ No tiene `system-overview.md` (requerido por convención)
- ⚠️ `version` sigue en 0.1.0 (esperable si está recién creado)
- ✅ Resto OK
```

### `cobertura`

Mapa de qué dominios cubre el ecosistema:

```markdown
| Dominio | Paquete | Estado |
|---------|---------|--------|
| product-management | pmx-product (externo, no migrado) | 🟢 Operativo |
| editorial-content | newsletter-system | ⚪ Stubs |
| marketing | (ninguno) | 🔲 Vacante |
| hr | (ninguno) | 🔲 Vacante |
```

### `dependencias`

Si algún paquete depende de otro (a través de skills compartidas, comandos cross), lo reporta. Útil para detectar acoplamientos no deseados.

### `salud-global`

Snapshot del estado: cuántos paquetes vivos, cuántos latentes, propagaciones recientes, auditorías pendientes.

## Cómo trabaja el aggregator

1. Aplica `rul-scope-boundaries`: solo lee `exports/README.md`, `exports/*/agent.yaml`, `exports/*/system-overview.md`. **Nunca entra a leer agentes/skills internos del paquete.**
2. Aplica `rul-lazy-loading`: si el foco no requiere leer un archivo, no lo lee.
3. Analiza con el foco solicitado
4. Genera reporte markdown en `docs/architect/aggregations/<YYYY-MM-DD>-<foco>.md`
5. Si detecta candidatos para promover a genérico, **propone** al PM (no ejecuta). El PM decide y, si acepta, invoca `/arc-propagate` con el alcance correcto

## Reglas

- **READ-ONLY total**. Cero modificaciones a paquetes.
- **Lecturas mínimas**. Si el foco es `cobertura`, basta con `exports/README.md` + `agent.yaml` de cada paquete. NO leer system-overview detallado.
- **Propuestas, no acciones**. El aggregator NUNCA aplica cambios. Si detecta algo que mejoraría con propagación, lo sugiere y el PM decide.
- **Acumulación auditable**. Los reportes se guardan en `docs/architect/aggregations/` con fecha. Historial revisable.

## Cuándo invocar

- **Periódicamente** (sugerencia: mensual o tras alcanzar nueva milestone)
- **Antes de decisiones grandes** (ej. "¿extraigo este patrón a genérico?", "¿qué falta para que marketing-system esté listo?")
- **Para audits estratégicos** (estado global del ecosistema, no solo paquete a paquete)

## Limitaciones

- **El aggregator no es un PM.** No prioriza, no decide. Reporta y propone.
- **Heurístico**: detecta patrones por nombre + descripción de alto nivel. No analiza lógica interna profunda. Patrones sutiles requieren revisión manual.
- **Lento si hay muchos paquetes**: para >20 paquetes, plantear lazy loading agresivo o limitar foco a subset (`--packages=...`).
- **No analiza proyectos clientes**, solo paquetes. (Para análisis de uso real en clientes, hace falta otra herramienta.)
