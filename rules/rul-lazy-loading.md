---
name: rul-lazy-loading
description: "Cargar solo lo necesario en cada momento. system-overview.md primero (cuando exista), el resto bajo demanda. Reduce contexto, acelera respuesta y evita 'leer todo por si acaso'."
license: MIT
user-invocable: false
metadata:
  author: agent-architect
  version: "1.0.0"
  category: standards
  loaded-by: all_arc_agents
  inspired-by: "luisdomarco/AiAgentArchitect (rul-lazy-loading)"
---

# Lazy Loading — Cargar solo lo necesario

## Principio

El contexto de Claude es **finito y caro**. Cargar 50 archivos "por si acaso" antes de saber qué se necesita:

- Consume tokens innecesariamente
- Reduce el espacio disponible para razonar
- Ralentiza la respuesta
- Aumenta riesgo de cache miss

La regla es: **leer primero el índice (cuando exista), después solo los archivos relevantes al paso actual**.

## Cuándo aplica

Aplica a TODOS los agentes del arquitecto que iteren sobre paquetes o sobre archivos masivos:

- `age-spe-arc-cataloger`: regenera `exports/README.md` leyendo solo `agent.yaml` y `system-overview.md` de cada paquete. NO entra a leer agentes/skills internos.
- `age-spe-arc-aggregator`: análisis macro que cita solo lo necesario; si quiere detalle, lo pide bajo demanda.
- `age-sup-arc-auditor`: audita conformidad leyendo solo los archivos relevantes a la convención.
- `age-spe-arc-propagator`: solo lee los archivos listados en `core-manifest.yaml`.
- `age-spe-arc-generator`: lee `templates/package-template/` y solo escribe en `exports/<nombre>/` nuevo.

## Heurística operativa

### Al iterar sobre `exports/*/`

Para cada paquete:

1. **Primer paso**: leer `system-overview.md` si existe. Es el índice ligero del paquete (qué entidades tiene, qué hace cada una).
2. **Si no existe `system-overview.md`**: leer `agent.yaml` (lista de agentes/skills) como índice mínimo.
3. **Solo si la tarea actual lo requiere**: leer archivos concretos (un agente específico, una skill específica). Y solo los archivos relevantes a esa tarea concreta — no toda la carpeta.

### Al leer archivos pesados dentro del arquitecto

- `pm-agent-system-guia-de-uso.html` (cuando se referencie): leer secciones concretas con `grep -n` y `Read offset/limit`, no el archivo entero.
- `docs/architect/aggregations/<archivo>.md`: leer solo el más reciente o el que se cita explícitamente.
- `changelog/propagations.md`: leer últimas N entradas (tail), no todo.

### Al ejecutar comandos del arquitecto

- `/arc-audit`: empieza con el catálogo (`exports/README.md`). Por cada paquete, lee `agent.yaml` y `system-overview.md`. Solo profundiza en un paquete si detecta drift.
- `/arc-aggregate`: empieza igual. Para análisis de patrones, lee los `agent.yaml` de todos los paquetes y consolida. NO lee el contenido de cada agente.
- `/arc-propagate`: lee `core-manifest.yaml` y los archivos a propagar. NO lee nada más del paquete destino.

## Anti-patterns a evitar

1. **"Voy a leer toda la carpeta del paquete para tener contexto"** → mal. Lee primero el índice; profundiza solo en lo relevante.

2. **"Cargo todas las skills del arquitecto al arrancar"** → mal. Las skills se cargan por demanda según el agente que las invoca (mismo modelo PM x10).

3. **"Para responder esta pregunta del PM, miro todo el changelog"** → mal. Lee solo las últimas entradas relevantes al scope de la pregunta.

4. **"Antes de propagar, comparo cada archivo del manifest con su versión en cada paquete"** → mal si son 10 paquetes y 30 archivos = 300 lecturas. Confía en el `core-manifest.yaml` como contrato y propaga; reporta resumen agregado.

## Compatibilidad con `rul-scope-boundaries`

Lazy loading y scope boundaries son **complementarias**:

- **Scope boundaries**: dice **qué se puede** leer (boundary).
- **Lazy loading**: dice **cuánto** leer de lo que se puede (eficiencia).

Aunque tengas permiso para leer un archivo, no lo leas si no es necesario para la tarea actual.

## Excepción: precarga explícita

Algunos archivos SÍ se cargan al inicio de toda sesión del arquitecto:

- `CLAUDE.md` (siempre, primero)
- `memory/MEMORY.md` (índice de memoria persistente)
- Las skills/rules/knowledge **preloaded** en el `agent.yaml` del agente activo (lo declara cada agente con `skills: [...]`)

Esto NO viola lazy loading — es la "core context" mínima necesaria. Lo que evitamos es cargar archivos no declarados "por si acaso".

## Verificación

El auditor puede reportar:

- Lecturas redundantes durante una sesión (`age-sup-arc-auditor`).
- Agentes del arquitecto cuyo DUTIES.md sugiere leer todo `exports/` (señal de mal diseño).
- Sesiones donde el contexto excedió 70% por carga excesiva (recomienda revisar el diseño del agente que lo causó).
