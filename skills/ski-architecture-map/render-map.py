#!/usr/bin/env python3
"""render-map.py — Valida y proyecta el mapa de arquitectura (architecture-map.json).

Parte determinista del ski-architecture-map (model-vs-code: JSON->HTML es determinista -> script).
El *contenido* del mapa lo escribe un agente (judgment); este script solo valida estructura y
genera la proyeccion HTML. Sin dependencias externas (stdlib).

Vive dentro de la carpeta de la skill para viajar con la propagacion (ruta relativa identica
en el arquitecto y en cada paquete/proyecto).

Uso:
  python3 skills/ski-architecture-map/render-map.py validate <map.json>
  python3 skills/ski-architecture-map/render-map.py render   <map.json> <out.html>

Idempotente: render dos veces produce el mismo HTML.
"""
import json
import sys

NODE_KINDS = {"page", "component", "hook", "api", "service", "table", "integration"}
EDGE_TYPES = {"uses", "depends_on", "fk", "calls", "renders"}
SCHEMA_VERSIONS = {"1.0.0"}


# ---------------------------------------------------------------- validate
def validate(map_path):
    """Devuelve lista de errores (vacia = valido)."""
    errors = []
    try:
        with open(map_path, encoding="utf-8") as f:
            m = json.load(f)
    except FileNotFoundError:
        return [f"no existe: {map_path}"]
    except json.JSONDecodeError as e:
        return [f"JSON invalido: {e}"]

    sv = m.get("schema_version")
    if sv not in SCHEMA_VERSIONS:
        errors.append(f"schema_version no soportada: {sv!r} (esperada una de {sorted(SCHEMA_VERSIONS)})")

    nodes = m.get("nodes", [])
    edges = m.get("edges", [])
    if not isinstance(nodes, list) or not isinstance(edges, list):
        return errors + ["'nodes' y 'edges' deben ser listas"]

    ids = set()
    for i, n in enumerate(nodes):
        nid = n.get("id")
        if not nid:
            errors.append(f"nodes[{i}]: falta 'id'")
            continue
        if nid in ids:
            errors.append(f"nodes[{i}]: id duplicado {nid!r}")
        ids.add(nid)
        if n.get("kind") not in NODE_KINDS:
            errors.append(f"node {nid!r}: kind invalido {n.get('kind')!r}")
        if not n.get("name"):
            errors.append(f"node {nid!r}: falta 'name'")
        if not n.get("provenance"):
            errors.append(f"node {nid!r}: falta 'provenance'")

    for i, e in enumerate(edges):
        frm, to, typ = e.get("from"), e.get("to"), e.get("type")
        if frm not in ids:
            errors.append(f"edges[{i}]: 'from' colgante {frm!r} (no existe en nodes)")
        if to not in ids:
            errors.append(f"edges[{i}]: 'to' colgante {to!r} (no existe en nodes)")
        if typ not in EDGE_TYPES:
            errors.append(f"edges[{i}]: type invalido {typ!r}")

    return errors


# ---------------------------------------------------------------- render helpers
def _safe(node_id):
    """Mermaid node id seguro (alfanumerico + _)."""
    return "".join(c if c.isalnum() else "_" for c in str(node_id))


def _esc(text):
    """Escapa texto para etiquetas mermaid."""
    return str(text).replace('"', "'").replace("\n", " ")


def _graph(nodes, edges):
    """Grafo de dependencias -> mermaid 'graph TD'."""
    if not nodes:
        return "graph TD\n  empty[\"(mapa vacio)\"]"
    lines = ["graph TD"]
    for n in nodes:
        label = f"{_esc(n.get('name'))}\\n({n.get('kind')})"
        suffix = "  %% deprecated" if n.get("status") == "deprecated" else ""
        lines.append(f'  {_safe(n["id"])}["{label}"]{suffix}')
    for e in edges:
        lines.append(f'  {_safe(e["from"])} -->|{_esc(e.get("type"))}| {_safe(e["to"])}')
    return "\n".join(lines)


def _er(nodes, edges):
    """Tablas + fk -> mermaid 'erDiagram'."""
    tables = [n for n in nodes if n.get("kind") == "table"]
    if not tables:
        return None
    lines = ["erDiagram"]
    for t in tables:
        fields = (t.get("meta") or {}).get("fields", [])
        lines.append(f"  {_safe(t['id'])} {{")
        for fld in fields:
            lines.append(f"    string {_safe(fld)}")
        if not fields:
            lines.append("    string id")
        lines.append("  }")
    table_ids = {t["id"] for t in tables}
    for e in edges:
        if e.get("type") == "fk" and e.get("from") in table_ids and e.get("to") in table_ids:
            lines.append(f'  {_safe(e["from"])} ||--o{{ {_safe(e["to"])} : fk')
    return "\n".join(lines)


def _sequences(data_flows, nodes):
    """data_flows -> lista de (titulo, mermaid sequenceDiagram)."""
    out = []
    for flow in data_flows or []:
        steps = flow.get("steps", [])
        lines = ["sequenceDiagram"]
        prev = "Actor"
        for idx, step in enumerate(steps):
            lines.append(f"  {prev}->>Paso{idx+1}: {_esc(step)}")
            prev = f"Paso{idx+1}"
        out.append((flow.get("name") or flow.get("id") or "Flujo", "\n".join(lines)))
    return out


HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Mapa de Arquitectura — {project}</title>
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<style>
  :root {{
    --bg: oklch(15% 0.01 50); --surface: oklch(18% 0.015 50); --surface-2: oklch(22% 0.02 50);
    --accent: oklch(67% 0.15 50); --text: oklch(96% 0.005 50); --text-2: oklch(74% 0.01 50);
    --border: color-mix(in oklch, var(--text) 10%, transparent);
    --sans: 'DM Sans', system-ui, sans-serif; --mono: 'DM Mono', ui-monospace, monospace;
  }}
  * {{ box-sizing: border-box; }}
  body {{ margin: 0; background: var(--bg); color: var(--text); font-family: var(--sans);
         line-height: 1.5; padding: 2rem; max-width: 1100px; margin: 0 auto; }}
  h1 {{ font-size: 1.6rem; }} h2 {{ font-size: 1.2rem; margin-top: 2.5rem; border-bottom: 1px solid var(--border); padding-bottom: .4rem; }}
  .meta {{ color: var(--text-2); font-size: .9rem; font-family: var(--mono); }}
  .stack {{ display: flex; gap: 1rem; flex-wrap: wrap; margin: 1rem 0; }}
  .stack span {{ background: var(--surface-2); padding: .3rem .7rem; border-radius: 6px; font-size: .85rem; font-family: var(--mono); }}
  .panel {{ background: var(--surface); border: 1px solid var(--border); border-radius: 10px; padding: 1rem; margin: 1rem 0; overflow-x: auto; }}
  .empty {{ color: var(--text-2); font-style: italic; }}
  details {{ margin: .5rem 0; }} summary {{ cursor: pointer; color: var(--accent); }}
  pre {{ font-family: var(--mono); font-size: .8rem; color: var(--text-2); white-space: pre-wrap; }}
</style>
</head>
<body>
<h1>Mapa de Arquitectura — {project}</h1>
<p class="meta">Generado: {generated_at} · {n_nodes} nodos · {n_edges} relaciones · schema {schema_version}</p>
<div class="stack">{stack}</div>

<h2>Grafo de dependencias</h2>
<div class="panel"><pre class="mermaid">{graph}</pre></div>

<h2>Modelo de datos</h2>
<div class="panel">{er}</div>

<h2>Flujos de datos</h2>
{flows}

<details><summary>JSON canónico (fuente)</summary><pre>{json_inline}</pre></details>

<script>mermaid.initialize({{ startOnLoad: true, theme: 'dark' }});</script>
</body>
</html>
"""


def render(map_path, out_path):
    with open(map_path, encoding="utf-8") as f:
        m = json.load(f)
    nodes, edges = m.get("nodes", []), m.get("edges", [])
    stack = "".join(f"<span>{_esc(k)}: {_esc(v)}</span>" for k, v in (m.get("tech_stack") or {}).items())

    er = _er(nodes, edges)
    er_html = f'<pre class="mermaid">{er}</pre>' if er else '<p class="empty">Sin tablas registradas.</p>'

    seqs = _sequences(m.get("data_flows", []), nodes)
    if seqs:
        flows_html = "".join(
            f'<div class="panel"><strong>{_esc(title)}</strong><pre class="mermaid">{diagram}</pre></div>'
            for title, diagram in seqs)
    else:
        flows_html = '<p class="empty">Sin flujos registrados.</p>'

    html = HTML_TEMPLATE.format(
        project=_esc(m.get("project") or "(sin nombre)"),
        generated_at=_esc(m.get("generated_at") or "—"),
        schema_version=_esc(m.get("schema_version") or "?"),
        n_nodes=len(nodes), n_edges=len(edges),
        stack=stack or '<span class="empty">stack sin declarar</span>',
        graph=_graph(nodes, edges),
        er=er_html,
        flows=flows_html,
        json_inline=_esc(json.dumps(m, indent=2, ensure_ascii=False)),
    )
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(html)
    return out_path


# ---------------------------------------------------------------- cli
def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    cmd = argv[1]
    if cmd == "validate":
        if len(argv) != 3:
            print("uso: render-map.py validate <map.json>", file=sys.stderr)
            return 2
        errs = validate(argv[2])
        if errs:
            print(f"INVALIDO ({len(errs)} errores):", file=sys.stderr)
            for e in errs:
                print(f"  - {e}", file=sys.stderr)
            return 1
        print("VALIDO")
        return 0
    if cmd == "render":
        if len(argv) != 4:
            print("uso: render-map.py render <map.json> <out.html>", file=sys.stderr)
            return 2
        errs = validate(argv[2])
        if errs:
            print("No renderizo: el mapa es invalido. Corre 'validate' primero.", file=sys.stderr)
            return 1
        out = render(argv[2], argv[3])
        print(f"render OK -> {out}")
        return 0
    print(f"comando desconocido: {cmd}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
