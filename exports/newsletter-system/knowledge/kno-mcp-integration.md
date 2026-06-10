---
name: kno-mcp-integration
description: "Cómo añadir y usar servidores MCP (Model Context Protocol) en un sistema Claude Code. Lista de MCPs conocidos. No es un agente — es infraestructura documentada."
license: MIT
user-invocable: false
metadata:
  author: agent-architect
  version: "1.0.0"
  category: infrastructure
  priority: medium
  inspired-by: "luisdomarco/AiAgentArchitect (mcp layer)"
---

# MCP Integration — Servidores MCP en Claude Code

## Qué es MCP

**Model Context Protocol** es un protocolo estandarizado de Anthropic que permite a Claude conectarse a servicios externos (filesystems, APIs, herramientas, bases de datos) de forma uniforme. Cada servicio se expone como un **servidor MCP** que ofrece tools, resources y prompts.

Para Claude Code, los servidores MCP se configuran en `.claude/settings.local.json` (o `.claude/settings.json`) bajo la clave `mcpServers`.

## Cómo añadir un servidor MCP

### Estructura básica

```json
{
  "mcpServers": {
    "nombre-del-servidor": {
      "command": "binario-o-script",
      "args": ["arg1", "arg2", ...],
      "env": {
        "VAR1": "valor1"
      }
    }
  }
}
```

- `nombre-del-servidor`: identificador único (sugerencia: descriptivo, kebab-case)
- `command`: ejecutable a invocar (puede ser `npx`, `python3`, `node`, binario absoluto, etc.)
- `args`: argumentos para el comando
- `env`: variables de entorno opcionales

### Scope: local vs global

- **Local al proyecto**: `<proyecto>/.claude/settings.local.json` → el MCP solo aparece cuando abres ese proyecto en Claude Code.
- **Global**: `~/.claude/settings.json` → el MCP aparece en todas las sesiones de Claude Code.

Regla operativa: si el MCP es específico de un dominio (ej. Pencil para diseños de producto), va local al proyecto. Si es transversal (ej. filesystem genérico), va global.

### Verificar que carga

Tras añadir el MCP, en Claude Code:

1. Cerrar y reabrir la sesión (los MCPs se cargan al iniciar)
2. Los tools del MCP aparecen como `mcp__<servidor>__<tool>` en la lista de tools disponibles
3. Si no aparecen, revisar logs (Claude Code muestra errores al iniciar si un MCP falla)

## MCPs conocidos y usados en este ecosistema

### Pencil

Editor de archivos `.pen` (diseños de producto). Ya está integrado en PM x10 (`age-spe-design-analyst` y otros lo usan).

**Cuándo usar**: análisis de diseños, generación de stories desde diseños, edición programática.

**Tools principales**: `get_editor_state`, `open_document`, `batch_get`, `batch_design`, `snapshot_layout`, `get_screenshot`, etc.

### Filesystem (oficial Anthropic)

Acceso a archivos fuera del cwd actual.

**Cuándo usar**: rara vez en este ecosistema, porque Claude Code ya tiene `Read`/`Write` para el cwd. Útil si necesitas operar sobre múltiples proyectos clientes desde una sola sesión del arquitecto (alternativa: usar `bash` con paths absolutos).

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/pablo/Trabajos"]
    }
  }
}
```

### Brave Search (oficial Anthropic)

Búsqueda web vía Brave Search API.

**Cuándo usar**: investigación durante research-phase de un paquete (alternativa al `WebSearch` nativo de Claude). Requiere API key.

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "<tu-key>"
      }
    }
  }
}
```

### Github (oficial Anthropic)

Acceso programático a GitHub (issues, PRs, repos, releases).

**Cuándo usar**: si el arquitecto o un paquete necesita crear issues automáticamente, etiquetar PRs, o consultar releases de repos.

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<tu-token>"
      }
    }
  }
}
```

## Cuándo NO usar MCP

- Si el tool ya existe nativamente en Claude Code (`Read`, `Write`, `Bash`, `WebSearch`, `WebFetch`): preferir lo nativo.
- Para operaciones triviales: añadir un MCP por conveniencia trivial introduce dependencia innecesaria.
- Si el servicio expone un CLI estable: muchas veces `bash <comando-cli>` es suficiente y más portable que un MCP custom.

## Permissions y MCPs

Los tools de MCPs (con prefix `mcp__`) requieren permission allowlist en `.claude/settings.local.json` igual que cualquier tool. Ejemplo:

```json
{
  "permissions": {
    "allow": [
      "mcp__pencil__get_editor_state",
      "mcp__pencil__batch_get"
    ]
  }
}
```

Por defecto, Claude Code pide confirmación la primera vez que un tool nuevo se usa. Añadir al allowlist evita la pregunta repetida.

## Cómo descubrir nuevos MCPs

- Repo oficial de Anthropic: https://github.com/modelcontextprotocol/servers
- Documentación oficial: https://modelcontextprotocol.io/
- Comunidad: hay MCPs no oficiales para servicios populares (Slack, Notion, Linear, etc.) — verificar la fuente antes de usar.

## Para los paquetes desplegables

Cuando el `generator` del arquitecto crea un paquete nuevo, **no añade MCPs automáticamente**. El PM decide qué MCPs necesita ese paquete según su dominio:

- Newsletter podría querer un MCP de "newsletter-platform" (Mailchimp, Substack, etc.) — no existe oficial; sería custom.
- Marketing podría querer Google Analytics MCP — existen no oficiales.
- PM x10 ya usa Pencil para diseños.

El `deploy.sh` de cada paquete puede sugerir MCPs recomendados en el `CLAUDE.md` del proyecto cliente, pero la decisión de añadirlos es del PM.

## Verificación de salud

Si un MCP empieza a fallar (errores al cargar, tools no disponibles), pasos típicos:

1. Comprobar versión del paquete npm con `npx <paquete> --version`
2. Reinstalar: `npx clear-npx-cache && npx -y <paquete>`
3. Revisar variables de entorno (`env` en config)
4. Probar el comando manualmente fuera de Claude Code
5. Revisar logs de Claude Code (`~/.claude/logs/` si están habilitados)

## Cómo invocar tools MCP desde un agente

Si un agente del arquitecto (o de un paquete) declara MCPs como tools requeridos, los lista en su `agent.yaml`:

```yaml
tools:
  - Read
  - Write
  - mcp__pencil__get_editor_state
  - mcp__pencil__snapshot_layout
```

Solo se invocan si están disponibles. Si el MCP no está cargado (no configurado en settings), las llamadas fallarán con error explícito.

## Notas para el arquitecto

El arquitecto **NO usa MCPs externos** por diseño — solo opera sobre archivos locales (sus agentes, los paquetes en `exports/`, los proyectos clientes vía paths). Esto mantiene al arquitecto **portátil** y **sin dependencias de red**.

Si en el futuro un agente del arquitecto necesita un MCP (ej. el aggregator quisiera generar reportes en Notion), se evaluará caso por caso. Por defecto: arquitecto = solo filesystem.
