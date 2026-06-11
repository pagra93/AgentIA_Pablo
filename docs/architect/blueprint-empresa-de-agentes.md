# Blueprint — Empresa de Agentes (startup interna con cerebro central)

> Estado: **diseño / papel** (2026-06-10). No implementado. Define la arquitectura objetivo y el roadmap.
> Aprobar las "decisiones abiertas" (§10) antes de arrancar la Fase 1.

---

## 1. Visión y modelo

Convertir el ecosistema en una **empresa de agentes tipo startup**: departamentos internos, cada uno con sus
especialistas, coordinados por un orquestador, todos alimentándose de un **cerebro central** conectado a todo
lo que la empresa genera (transcripciones de reuniones, reuniones de proyecto, facturas a clientes, tareas,
activos de marketing, contratos…). Todo visible y operable desde el dashboard.

**Principios heredados (no se negocian):**
- Lo genérico vive en un sitio; la propagación es explícita, auditable y reversible (principio del arquitecto).
- El humano controla el estado (kanban) y aprueba lo que **compone** (gates).
- `rul-fail-loud`, `rul-scope-boundaries`, `rul-model-vs-code`, `kno-security-review` aplican en toda la empresa.
- Markdown + git como sustrato (auditable), no DB binarias ni servicios opacos.

**Modelo elegido:** empresa **interna** (una sola organización) en v1, pero **diseñada para poder servir a
clientes externos en el futuro** (decisión §10.5) — el cerebro se estructura partition-ready desde ya.

**Despliegue dedicado y modular (decisión §10.1):** "La Empresa" es un workspace **dedicado y separado** del
meta-sistema. La instalación es **modular**: el PM decide qué instalar — todos los departamentos, algunos, o
incluso **un solo agente**. Cada departamento (package) y cada agente es desplegable de forma independiente.

**Qué NO es:** no migramos a Claude Cowork; no copiamos `knowledge-work-plugins` tal cual — **minamos su
contenido de dominio** y lo adaptamos al modelo curado del arquitecto.

---

## 2. Topología del workspace

A diferencia del modelo cliente (donde se despliega un subconjunto de packages), **"La Empresa" es UN
workspace** donde conviven:

```
Empresa (workspace)
├── brain/                      ← cerebro central (gBrain) — §3
├── dashboard/                  ← dashboard único (de pmx), un área por departamento
├── departamentos (packages desplegados):
│   ├── producto    (pmx)       ← ya existe
│   ├── marketing   (mkt)       ← nuevo
│   ├── finanzas    (fin)       ← nuevo
│   ├── legal       (leg)       ← nuevo
│   ├── ventas      (sal)       ← nuevo
│   ├── rrhh        (hr)        ← nuevo
│   └── cultura     (cul)       ← nuevo
├── orquestador (Hermes)        ← router cross-departamento — §5
└── org-chart view              ← galaxia de nodos — §6
```

- **Departamento = package** (mecanismo ya existente: `/arc-new-package` los genera, `deploy.sh` los instala
  como áreas en `pm/config.json > areas`, cada uno con su `docs/<dominio>/` aislado).
- **Proyectos** (p.ej. *Cuerva Smart Industry*, *Smart Building*) son **entidades dentro de la empresa** que
  cruzan departamentos: producto construye, finanzas factura, marketing comunica. El cerebro guarda su info
  (reuniones, facturas, tareas) y los departamentos la consultan.
- **Un solo dashboard** (el de pmx, canónico) con un área/tab por departamento + las vistas nuevas (org-chart).

---

## 3. El Cerebro (gBrain) — la pieza nueva más importante

Capa de conocimiento central que **todos** los departamentos leen. Eleva el `wiki-curator` actual (hoy
"wiki de proyecto") a **cerebro de empresa**. Cuatro capas:

| Capa | Ubicación | Qué hay | Cómo entra |
|---|---|---|---|
| **Raw** | `brain/raw/` | Fuentes crudas: transcripciones, actas, facturas, exports de tareas, briefs, contratos | El humano/agentes las dejan; sin procesar |
| **Curado** | `brain/wiki/` | Entidades/conceptos/wikilinks: personas, proyectos, clientes, decisiones, SOPs | `wiki-curator` (`/wiki ingestar`) procesa raw → curado |
| **Destilado** | `brain/knowledge/` | Lecciones, patrones, "qué se ve bien", SOPs por departamento | `ski-compression` + optimizer destilan periódicamente |
| **Grafo/índice** | `brain/brain-map.json` (+ `.html`) | Grafo navegable: entidades ↔ proyectos ↔ decisiones ↔ departamentos | Reusa el patrón `ski-architecture-map` + mermaid |

**Reutiliza lo que ya hay**: el motor del `wiki-curator` (ingesta, entidades, wikilinks, log/índice), el patrón
de memoria en capas (raw→curado→destilado replica working/archive de `memory.yaml`), y el renderer mermaid del
`architecture-map` para el grafo de conocimiento.

**Acceso gobernado (clave):** cada agente declara en su `agent.yaml` un campo nuevo **`brain_scope`** = qué
zonas del cerebro puede leer (p.ej. `[proyectos, decisiones]` para producto; `[facturas, clientes]` para
finanzas; legal y finanzas con scopes sensibles). Regla explícita: **no fugar contexto sensible entre
departamentos** (un agente de marketing no lee nóminas de RRHH ni borradores legales salvo permiso). El cerebro
tiene permisos, no es un saco común.

**Ingesta — MANUAL en v1 (decisión §10.3):** el PM/agentes dejan fuentes en `brain/raw/` y ejecutan
`/wiki ingestar`. Control total sobre qué entra y cuándo; cero infraestructura; funciona ya. La ingesta
automática (hooks/conectores que traen transcripciones, facturas, tareas) queda para después, sobre lo que
demuestre valor.

**Partition-ready por cliente (decisión §10.5):** aunque v1 es interno y **todos los agentes leen todo el
cerebro** (decisión §10.4 — sin enforcement de `brain_scope` todavía), la estructura del cerebro reserva un
**eje de tenant desde el día uno** para no rehacerlo si se sirven clientes externos:

```
brain/
└── <tenant>/                 ← v1: solo "internal". Futuro: un dir por cliente externo (aislado)
    ├── raw/  wiki/  knowledge/  brain-map.json
```

En v1 hay un único tenant (`internal`) y `brain_scope` se introduce como campo en `agent.yaml` pero su valor
efectivo es "todo lo internal". Añadir un cliente externo = nuevo `brain/<cliente>/` + `brain_scope` gana el
eje de tenant. Así el "todos leen todo" de hoy y el "quizá clientes externos" del futuro conviven sin rework.

---

## 4. Catálogo de departamentos

Cada departamento es un package generado con `/arc-new-package` (mini-discovery), con su prefix, agentes
especialistas, sub-agentes de alcance estrecho, comandos `<prefix>-*`, área de dashboard, y `brain_scope`.
El **contenido de dominio se mina de `knowledge-work-plugins`** (skills/commands de Anthropic) y se adapta a
`SOUL/DUTIES/kno-*`. Tabla objetivo (a refinar en cada mini-discovery):

| Depto | Prefix | Agentes especialistas (ejemplo) | Brain que lee | Gate humano | Minar de plugins |
|---|---|---|---|---|---|
| Producto | pmx | (19 ya existentes) | proyectos, decisiones | scope/arquitectura/done (`/auto`) | product-management |
| Marketing | mkt | content, campañas, SEO, brand-voice, reporting | proyectos, clientes, marketing | aprobar campaña/publicación | marketing |
| Finanzas | fin | asientos, conciliación, cierre-mes, varianza | facturas, clientes, proyectos | aprobar asientos/cierre | finance |
| Legal | leg | revisión-contratos, NDA-triage, riesgo | contratos, clientes | aprobar dictamen/firma | legal |
| Ventas | sal | research-cuentas, prep-llamada, pipeline, outreach | clientes, proyectos | aprobar outreach/oferta | sales |
| RRHH | hr | onboarding, políticas, evaluación, vacantes | personas, políticas | aprobar acción sobre persona | productivity/(custom) |
| Cultura | cul | valores, comunicación interna, rituales, clima | personas, decisiones | aprobar comunicación interna | (custom) |

**Alcance estrecho > genérico** (lección de los recursos): no un "agente de marketing" vago, sino
"agente de email de ciclo de vida con sus campañas, reglas de voz, gates y ejemplos". Cuanto más estrecho el
sub-agente, mejor la salida.

### Marketing — departamento PILOTO (prefix `mkt`) — investigado

Fuente minada: plugin `marketing` de `anthropics/knowledge-work-plugins` (tool-agnostic, conectores MCP).
Trae **8 skills**: `content-creation`, `draft-content`, `campaign-plan`, `email-sequence`, `seo-audit`,
`brand-review`, `competitive-brief`, `performance-report`. Conectores por categoría: diseño (Canva/Figma),
marketing automation (HubSpot), email (Klaviyo), SEO (Ahrefs/Similarweb), analytics (Amplitude), KB (Notion), chat (Slack).

**Composición del departamento (minar las 8 + AÑADIR 2 propias + PLEGAR newsletter):**

| Agente/skill (prefix mkt) | Origen | Brain que lee | Gate humano |
|---|---|---|---|
| contenido (`content-creation`/`draft-content`) | minado | proyectos, clientes, marketing | aprobar pieza |
| campañas (`campaign-plan`) | minado | proyectos, clientes | aprobar plan de campaña |
| email/**newsletter** (`email-sequence` + pipeline newsletter actual) | minado + **plegado** | clientes, marketing | aprobar envío |
| SEO (`seo-audit`) | minado | marketing | — |
| marca/voz (`brand-review`) | minado | marca | aprobar desviación de voz |
| competitivo (`competitive-brief`) | minado | mercado | — |
| analítica/reporting (`performance-report`) | minado | analytics | — |
| **redes sociales** (`social-media`) | **NUEVO** (el plugin no lo trae) | marketing, marca | aprobar publicación |
| **calendario editorial** (`publication-calendar`) | **NUEVO** | proyectos, marketing | aprobar calendario |

**Newsletter se pliega dentro de marketing**: el `newsletter-system` actual deja de ser package suelto y pasa
a ser el motor de email/contenido del departamento (sus agentes editoriales viven bajo `mkt`). Los conectores
(Canva, HubSpot, Klaviyo, Ahrefs…) se añaden vía MCP cuando existan; sin ellos, los agentes trabajan con el
material que se les da (modo standalone), igual que el plugin original.

**Fork, no copy-paste**: una vez un departamento está bien, se forkea para acelerar el siguiente (~75% hecho),
personalizando contexto/ejemplos/voz/herramientas/gates. Esto ya lo soporta el modelo de propagación.

---

## 5. El Orquestador ("Hermes") — router cross-departamento

Entrada única para tareas que cruzan departamentos: *"lanzar campaña Q3"*, *"cerrar el mes"*, *"revisar
contrato del proveedor X"*, *"onboarding de nuevo cliente"*.

**Qué hace** (judgment puro — `rul-model-vs-code`, NO ejecuta el trabajo, solo enruta y coordina):
1. Consulta el **cerebro** (contexto: ¿qué proyecto? ¿qué cliente? ¿decisiones previas?) y el **org-chart**
   (quién sabe hacer qué).
2. **Descompone** la tarea y decide qué departamento(s)/agentes intervienen y en qué orden/dependencias.
3. **Coordina**: lanza los comandos de cada departamento, pasa resultados de uno a otro.
4. **Gates humanos** en las decisiones que componen (como `/auto`): el PM aprueba el plan de routing y los
   entregables sensibles. Nunca acciones irreversibles sin aprobación.

**Es `/auto` elevado a nivel empresa**: `/auto` orquesta el pipeline *dentro* de producto; Hermes orquesta
*entre* departamentos. Reutiliza el patrón de gates, fail-loud, y respeto al kanban.

**Construcción**: comando `/hermes <tarea>` (o `/empresa`) + un agente meta `age-spe-arc-hermes` (o a nivel
empresa). Se construye **al final** (Fase 4): necesita ≥2 departamentos reales y el cerebro a los que enrutar.

---

## 6. Vista Org-Chart — la "galaxia de nodos"

Vista nueva en el dashboard (área "Empresa" o en architect-console): grafo navegable de la organización.

- **Nodos**: departamentos → agentes → sub-agentes.
- **Por nodo**: qué **brain** lee (`brain_scope`), qué **herramientas** usa (`tools`), dónde hay **gate de
  aprobación** (`approval_chain`), a quién reporta (`parent`).
- **Interacción**: clicar un departamento abre su equipo + SOPs (del cerebro) + permisos.
- **Motor**: reusa `ski-architecture-map/render-map.py` (mermaid: grafo + jerarquía). Se alimenta de los
  `agent.yaml` (metadata ya 80% lista) + 3 campos nuevos: **`brain_scope`**, **`approval_chain`**, **`parent`**.
- Es la versión "organigrama" del mapa de arquitectura que ya montamos — mismo patrón, distinta fuente.

---

## 7. Gobernanza, permisos y aislamiento

- **Por-agente**: `agent.yaml` (model, tools, skills, + `brain_scope`, `approval_chain`, `parent`).
- **Por-departamento**: cada package aislado (`docs/<dominio>/`, su área); `rul-scope-boundaries`.
- **Gates de aprobación**: heredan el patrón de `/auto`; cada departamento define los suyos (§4).
- **Acceso al cerebro**: `brain_scope` controla qué lee cada agente. **Aislamiento de datos sensibles**
  (finanzas, legal, RRHH/nóminas) es regla explícita — no fuga entre departamentos.
- **Seguridad**: `kno-security-review` (ya integrado en code-reviewer) aplica al código; para datos, el
  `brain_scope` + gates son el control.
- **Auditabilidad**: todo en markdown+git; `context-ledger` y `changelog` registran operaciones; el
  `/arc-audit` audita conformidad de los departamentos.

---

## 8. Qué se reusa vs qué es nuevo (honesto)

**Ya existe (~75%) — se reusa:**
- Departamentos = packages; `/arc-new-package` (generador production-ready); `deploy.sh` + áreas de dashboard.
- Aislamiento por proyecto (pods); prefijos/namespacing; propagación auditable.
- `agent.yaml` con model/tools/skills; kanban PM-control; `/auto` + gates; `kno-security-review`.
- `wiki-curator` (motor del cerebro); memoria en capas; `ski-architecture-map` + mermaid (motor del org-chart y del grafo de conocimiento); `ski-compression` (destilado).

**Nuevo — hay que construir:**
1. **Cerebro unificado** (gBrain): capas raw/curado/destilado/grafo + ingesta cross-departamento (eleva wiki-curator).
2. **`brain_scope` / `approval_chain` / `parent`** en `agent.yaml` + en el auditor/conventions.
3. **6 departamentos** (marketing, finanzas, legal, ventas, rrhh, cultura): generar + minar contenido + implementar agentes de verdad.
4. **Org-chart view** en el dashboard.
5. **Orquestador Hermes** (router cross-departamento).

---

## 9. Roadmap por fases

| Fase | Entregable | Esfuerzo aprox. | Por qué este orden |
|---|---|---|---|
| **0** | Este blueprint | — | Plano antes de construir |
| **1** | Cerebro (gBrain) + `brain_scope` | Medio-Alto | Espina dorsal: sin él los departamentos son genéricos |
| **2** | 1 departamento piloto (marketing o finanzas) implementado de verdad | Alto | Valida el modelo completo end-to-end |
| **3** | Org-chart view en el dashboard | Bajo-Medio | Rápido, alto valor visual, reusa mermaid |
| **4** | Orquestador Hermes | Medio | Necesita ≥2 departamentos + cerebro |
| **5** | Resto de departamentos (forkeando el piloto) | Medio cada uno | 75% hecho por fork; personalizar |

Cada fase es un mini-proyecto con su propio `/plan`/`/build`/`/review` (o `/auto`). **Son meses, no días** —
la calidad de cada departamento es trabajo real (iteración, ejemplos, QA, gusto), no "conectar herramientas".

---

## 10. Decisiones (CERRADAS 2026-06-10) y riesgos

**Decisiones tomadas por el PM:**
1. **Dónde vive** → **Workspace dedicado y modular**, separado del meta-sistema. Se instala lo que se quiera (todos los departamentos, algunos, o un solo agente). ✅
2. **Departamento piloto** → **Marketing** (newsletter se pliega dentro; + redes sociales + calendario editorial). Investigado en §4. ✅
3. **Ingesta del cerebro** → **Manual en v1** (`/wiki` sobre `brain/raw/`). Automática, después. ✅
4. **Datos sensibles** → **Por ahora todos los agentes leen todo** (sin enforcement de `brain_scope` en v1). ✅
5. **Clientes externos** → **Quizá en el futuro** → el cerebro se diseña **partition-ready por tenant desde ya** (§3), aunque v1 tenga un solo tenant `internal`. ✅

**Riesgos:**
- **Sobre-escala**: 6 departamentos × N agentes = mucha superficie. Mitigar con alcance estrecho + fork, y
  construir de a uno (no todos a la vez).
- **Cerebro como vertedero**: si entra todo sin curar, se vuelve ruido. La capa curado/destilado lo contiene.
  El `wiki-curator` debe ser disciplinado. (`brain_scope` aún no filtra en v1, pero la curación sí.)
- **Mantenimiento**: un solo PM mantiene todo. La propagación ayuda, pero cada departamento bueno requiere
  iteración real. No esperar "empresa-en-una-semana" (eso es el hype de los recursos).
- **Calidad > herramientas**: agentes vagos con muchas herramientas solo producen output vago más rápido.
- **Tensión #4 vs #5 (resuelta)**: "todos leen todo" hoy + "quizá clientes externos" mañana conviven porque la
  estructura del cerebro ya reserva el eje de tenant; solo se activa el filtrado cuando haga falta.

**Riesgos:**
- **Sobre-escala**: 6 departamentos × N agentes = mucha superficie. Mitigar con alcance estrecho + fork, y
  construir de a uno (no todos a la vez).
- **Cerebro como vertedero**: si entra todo sin curar, se vuelve ruido. La capa curado/destilado + `brain_scope`
  lo contienen. El `wiki-curator` debe ser disciplinado.
- **Mantenimiento**: un solo PM mantiene todo. La propagación ayuda, pero cada departamento bueno requiere
  iteración real. No esperar "empresa-en-una-semana" (eso es el hype de los recursos).
- **Calidad > herramientas**: agentes vagos con muchas herramientas solo producen output vago más rápido.
