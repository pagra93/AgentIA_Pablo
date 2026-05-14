# Plan V2: Dashboard Visual del Sistema PM x10

## Context

V1 entregó el agente PM de Producto + `/pm` como índice textual. Ahora se construye el **dashboard visual** que el usuario quería desde el principio: una herramienta tipo Notion + Jira para ver y editar todo el contenido del proyecto.

Decisiones confirmadas con el usuario (sesión 2026-05-01):
- **Kanban**: 8 columnas literales (los 8 estados de V1)
- **Arranque**: el bridge Python sirve el HTML. Un solo comando arranca todo. Sin bridge, no hay UI.
- **Editor**: textarea + preview togglable. Sin WYSIWYG.
- **Estrategia**: fases incrementales V2.1 → V2.5

## Arquitectura general

```
proyecto/
├── dashboard/                  ← copiado por /new-project desde ~/.claude/dashboard-template/
│   ├── bridge.py               ← servidor HTTP local. Sirve HTML + endpoints /api/*
│   ├── index.html              ← UI principal
│   ├── styles.css              ← dark theme, consistente con guía existente
│   ├── app.js                  ← lógica vanilla JS
│   └── lib/
│       └── (deps si hay)
├── inbox.md
├── tasks.json
├── tasks/events.jsonl
├── config.json
├── docs/
├── tasks/
├── qa/
└── memory/
```

**Distribución:** el código vive en `dashboard-template/` del repo del sistema. `install.sh` lo copia a `~/.claude/dashboard-template/`. `/new-project` lo copia al directorio del proyecto.

**Arranque:** `python3 dashboard/bridge.py [--port 7700]` o `pm-dashboard` (wrapper opcional V2.5).

## Fases

### V2.1 — Árbol de docs + viewer (read-only) ← **EMPEZAMOS AQUÍ**

**Entrega:** dashboard navegable con sidebar de áreas + árbol de archivos + viewer de markdown renderizado. Sin edición.

**Componentes:**

1. **`bridge.py`**:
   - HTTP server estándar Python (`http.server` + `BaseHTTPRequestHandler`)
   - Sirve `index.html`, `styles.css`, `app.js` como estáticos
   - Endpoints:
     - `GET /api/health` → `{"ok": true, "version": "2.1"}`
     - `GET /api/tree` → estructura de archivos del proyecto agrupada por área
     - `GET /api/file?path=X` → contenido raw del .md (validar que path esté dentro del proyecto, no `..`)
   - Args: `--port 7700` (default), `--root .` (default cwd)
   - Si puerto ocupado, intenta el siguiente
   - Imprime "Dashboard arrancado en http://localhost:7700"

2. **`index.html`**:
   - Layout: sidebar fija (280px) + main scrollable
   - Header arriba: nombre proyecto + indicador conexión bridge (verde/rojo)
   - Sidebar:
     - Toggle Documentación / Proyecto (V2.1 solo Documentación funcional)
     - Lista de áreas: Producto (activa) + Marketing/Campañas/Redes Sociales/Docs (greyed con badge "no activado")
     - Producto expandido por defecto: muestra árbol de archivos
   - Main:
     - Welcome state si no hay archivo seleccionado
     - Viewer markdown renderizado al hacer click en un archivo
     - Breadcrumb arriba con ruta del archivo

3. **`styles.css`**:
   - Variables consistentes con `pm-agent-system-guia-de-uso.html`:
     - `--bg: #0b0b14`, `--bg2: #15151f`, `--text: #e8e8f0`, `--text2: #a8a8b8`
     - `--cyan: #5fc7e6`, `--blue: #5b9bd5`, `--purple: #c47bd6`, etc.
     - `--mono: 'DM Mono', monospace`, `--sans: 'DM Sans', sans-serif`
   - Sidebar dark, archivos con icono según extensión
   - Main con max-width legible (~880px) para markdown

4. **`app.js`**:
   - Vanilla JS, sin frameworks
   - Estado mínimo: `{ selectedPath, tree, fileContent }`
   - Funciones: `fetchTree()`, `fetchFile(path)`, `renderTree(tree)`, `renderMarkdown(text)`
   - Renderer markdown: `marked.min.js` desde CDN (~30KB) o snarkdown inline (~1KB) — decidir al programar
   - Health check al arrancar; si bridge no responde, mostrar pantalla de error

5. **`commands/new-project.md` (modificar):**
   - Añadir paso "copiar `~/.claude/dashboard-template/` a `dashboard/` del proyecto"
   - Añadir al resumen final: "ejecuta `python3 dashboard/bridge.py` para abrir el dashboard"

6. **`install.sh` (modificar):**
   - Copiar `dashboard-template/` del repo a `~/.claude/dashboard-template/` (sin compilar, copia directa de directorio)

**Mapping de áreas → archivos (V2.1):**

```
📁 Producto (activa)
  📄 inbox.md
  📁 tasks/
    📄 todo.md
    📄 lessons.md
    📄 events.jsonl
    📄 build-state.md (si existe)
  📁 docs/
    📄 PROJECT_KNOWLEDGE.md
    📄 project-registry.md
    📁 working-docs/
      📁 [feature]/
        📄 stories.md, jtbds.md, prd.md, ...
  📁 qa/
    📄 qa-report.md
  📁 memory/
    📄 MEMORY.md
  📄 tasks.json
  📄 config.json

📁 Marketing (sin activar)
📁 Campañas (sin activar)
📁 Redes Sociales (sin activar)
📁 Docs (sin activar)
```

**Estimación V2.1:** ~1 día de trabajo.

### V2.2 — Edición de .md

**Entrega:** poder editar y guardar .md desde el dashboard.

**Componentes:**

1. `bridge.py`:
   - Endpoint `POST /api/file` con body `{path, content}` → escribe archivo (validar path)
   - Mantener una lista de archivos "read-only" según patrón (qa-report.md, project-registry.md, tasks.json) con warning explícito
2. `app.js`:
   - Botón "Editar" → cambia viewer por textarea
   - Botón "Preview" en modo edición → preview lateral o toggle
   - Botón "Guardar" → POST a /api/file
   - Botón "Cancelar" → descarta cambios
   - Indicador "modificado" en breadcrumb
3. Detección de cambios externos (polling cada 7s al GET /api/file con `If-Modified-Since`)

**Estimación V2.2:** ~1 día.

### V2.3 — Vista Proyecto: kanban (lectura)

**Entrega:** segunda pestaña con kanban de 8 columnas leyendo `tasks.json`. Sin drag-drop todavía.

**Componentes:**

1. `bridge.py`:
   - Endpoint `GET /api/tasks` → contenido de tasks.json
2. `app.js` + `index.html` + `styles.css`:
   - Toggle "Documentación / Proyecto" activado
   - Vista Proyecto: header con filtros (área, criticality, agente), 8 columnas verticales con scroll horizontal
   - Cada tarjeta: ID, título, agente sugerido (badge), criticality (color), última actividad
   - Click en tarjeta abre panel lateral con detalles + link al .md
3. Polling cada 7s para refrescar tasks.json

**Estimación V2.3:** ~1.5 días.

### V2.4 — Drag & drop en kanban

**Entrega:** poder arrastrar tarjetas entre columnas. Eso modifica tasks.json.

**Componentes:**

1. `bridge.py`:
   - Endpoint `POST /api/tasks/move` con body `{id, new_status}` → actualiza tasks.json
   - Validar transiciones contra `config.json/transitions`
2. `app.js`:
   - SortableJS (CDN, ~16KB) para drag-drop
   - Optimistic UI: mueve la tarjeta al instante, rollback si la API falla
3. Feedback visual: animación de transición exitosa o error

**Estimación V2.4:** ~1 día.

### V2.5 — Agente dashboard-builder + áreas adicionales

**Entrega:** agente que modifica el HTML/CSS/JS del dashboard cuando le pides cambios en lenguaje natural. Áreas adicionales activables.

**Componentes:**

1. `agents/age-spe-dashboard-builder/`:
   - SOUL: identidad de "modificador del dashboard"
   - DUTIES: solo edita `dashboard/*.html`, `dashboard/*.css`, `dashboard/*.js`. NUNCA tasks.json, NUNCA inbox.md, NUNCA archivos de proyecto. Lee la estructura actual antes de cambiar.
   - Reglas duras: nunca rompe endpoints existentes, nunca elimina sidebar, nunca cambia el layout fundamental
2. `commands/dashboard.md`: slash command `/dashboard <descripción del cambio>`
3. Activación de áreas: editor de `config.json` desde el sidebar (botón "Activar área")
4. Wrapper `pm-dashboard` para arrancar bridge sin escribir comando largo

**Estimación V2.5:** ~2 días.

## Decisiones técnicas

- **No frameworks JS.** Vanilla, sin React/Vue/Svelte. El usuario debe poder leer el código sin abstracciones.
- **Markdown renderer:** marked.js desde CDN (https://cdn.jsdelivr.net/npm/marked/marked.min.js). Si CDN no disponible, fallback a renderer minimal inline.
- **Drag-drop:** SortableJS (V2.4 en adelante).
- **Sin localStorage para datos.** El estado vive en filesystem. localStorage solo para preferencias UI (área expandida, último archivo abierto).
- **Sin auth.** Servidor solo escucha en localhost. Si en futuro hay multi-user, se añade.
- **Path traversal protection:** todas las rutas en endpoints validadas con `os.path.realpath` y comparación con root del proyecto.
- **Polling cada 7s.** Suficiente para single-user.
- **Puerto:** 7700 default. Si ocupado, intenta 7701, 7702, ... hasta 7710.

## Lo que NO se construye

| No incluido | Cuándo |
|---|---|
| Multi-user (auth, roles) | Nunca, fuera de scope |
| Notificaciones push | Fuera de scope |
| Versionado de archivos en dashboard | git ya lo hace |
| Editor WYSIWYG completo | Fuera de scope |
| Mobile-friendly | Fuera de scope V2 |
| Dashboard servido remotamente | Fuera de scope |
| Sincronización con Notion/Jira reales | Fuera de scope |

## Verificación V2.1

1. **Bridge arranca:** `python3 dashboard/bridge.py` imprime URL y queda escuchando
2. **Health check:** `curl http://localhost:7700/api/health` devuelve `{"ok":true,...}`
3. **Tree:** `curl http://localhost:7700/api/tree` devuelve JSON con estructura
4. **File:** `curl 'http://localhost:7700/api/file?path=README.md'` devuelve contenido
5. **UI:** abrir `http://localhost:7700/` muestra dashboard con sidebar + árbol
6. **Click en archivo:** se renderiza markdown en el panel principal
7. **Áreas inactivas:** Marketing, Campañas, etc. visibles pero greyed con badge claro
8. **Path traversal:** `curl 'http://localhost:7700/api/file?path=../../etc/passwd'` rechazado con 403
9. **Bridge muerto:** matar el bridge, recargar página: error claro "bridge no disponible, ejecuta python3 ..."

## Hitos visibles para el usuario

- **Tras V2.1:** "Puedo navegar todos mis docs en una UI bonita"
- **Tras V2.2:** "Puedo editar mis stories desde el navegador"
- **Tras V2.3:** "Veo mi kanban completo de un vistazo"
- **Tras V2.4:** "Muevo tareas arrastrando como en Trello"
- **Tras V2.5:** "Le pido al agente cambios al dashboard y los hace"
