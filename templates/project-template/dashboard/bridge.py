#!/usr/bin/env python3
"""
Multi-tab Project Dashboard — Bridge

Servidor HTTP local que sirve el dashboard del proyecto cliente.
Renderiza pestañas dinámicamente según los paquetes desplegados (uno por pestaña).

Cada paquete desplegado aporta:
- Una entrada en `pm/config.json` → `deployed_packages`
- Un archivo `dashboard/sections/<paquete>-section.yaml`
- Una carpeta `docs/<dominio>/` con artefactos

El bridge lee config + sections + scaneando docs/ y compone la respuesta /api/tabs.
El frontend (index.html + app.js) renderiza pestañas.

Uso:
    python3 bridge.py [--port 7700] [--root .]

Endpoints:
    GET /                 → index.html
    GET /styles.css       → CSS
    GET /app.js           → JS
    GET /api/health       → { ok, version, project_name }
    GET /api/tabs         → estructura de pestañas (una por paquete desplegado)
    GET /api/file?path=X  → contenido raw de un archivo (validado contra root)

Sin dependencias externas. Solo stdlib + parser YAML minimalista incluido.
"""

import argparse
import datetime
import json
import os
import re
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs


VERSION = "0.1.0"
DEFAULT_PORT = 7700
PORT_RANGE = 10  # intenta puertos hasta DEFAULT_PORT + PORT_RANGE


def _now_iso():
    tz = getattr(datetime, "UTC", datetime.timezone.utc)
    return datetime.datetime.now(tz).replace(microsecond=0).strftime("%Y-%m-%dT%H:%M:%SZ")


# ============================================
# YAML parser minimalista (suficiente para dashboard-section.yaml)
# ============================================
# Soporta:
# - key: value
# - key: "string with spaces"
# - key:
#     subkey: value
#     subkey2:
#       - item1
#       - item2
# - listas con items dict (cada item con sus campos)
# - comentarios con # (línea o trailing)
# No soporta: anchors, references, multi-line scalars complejos.
# Si necesitas más, instalar pyyaml: pip install pyyaml.

def _yaml_minimal_load(text):
    """Parser YAML simple. Devuelve dict o lista."""
    try:
        import yaml  # noqa
        return yaml.safe_load(text)
    except ImportError:
        pass

    # Fallback: parser propio simple
    lines = text.split("\n")
    return _parse_yaml_block(lines, 0, 0)[0]


def _parse_yaml_block(lines, idx, indent):
    """Parsea un bloque indentado. Devuelve (objeto_parseado, siguiente_idx)."""
    result = None  # se decide si dict o lista por la primera línea no vacía/comentario
    while idx < len(lines):
        raw = lines[idx]
        stripped = raw.split("#", 1)[0].rstrip()  # quita comentarios y trailing whitespace
        if not stripped.strip():
            idx += 1
            continue
        # Calcular indent
        line_indent = len(raw) - len(raw.lstrip())
        if line_indent < indent:
            break  # fin del bloque
        if line_indent > indent:
            # Sub-bloque ya consumido por la llamada recursiva anterior; ignorar
            idx += 1
            continue
        content = stripped.strip()

        # ¿Es item de lista (empieza con -)?
        if content.startswith("- "):
            if result is None:
                result = []
            item_content = content[2:].strip()
            # ¿El item es un dict inline (key: value) o un valor simple?
            if ":" in item_content and not item_content.startswith('"'):
                # Dict que continúa en líneas indentadas
                # Procesamos la primera key del dict, luego seguimos parseando sub-keys
                key, _, value = item_content.partition(":")
                key = key.strip()
                value = value.strip()
                item_dict = {}
                if value:
                    item_dict[key] = _parse_yaml_value(value)
                else:
                    # value vacío → sub-bloque en siguientes líneas más indentadas
                    sub_obj, idx_after = _parse_yaml_block(lines, idx + 1, indent + 2)
                    item_dict[key] = sub_obj
                    result.append(item_dict)
                    idx = idx_after
                    continue
                # Procesar resto de keys del item (líneas con indent > indent+2)
                next_idx = idx + 1
                while next_idx < len(lines):
                    next_raw = lines[next_idx]
                    next_stripped = next_raw.split("#", 1)[0].rstrip()
                    if not next_stripped.strip():
                        next_idx += 1
                        continue
                    next_line_indent = len(next_raw) - len(next_raw.lstrip())
                    if next_line_indent <= indent:
                        break
                    # Sub-key del item (indentada más que el -)
                    sub_content = next_stripped.strip()
                    if sub_content.startswith("- "):
                        # Es otro item de la lista padre, no de este item
                        break
                    if ":" in sub_content:
                        sub_key, _, sub_val = sub_content.partition(":")
                        sub_key = sub_key.strip()
                        sub_val = sub_val.strip()
                        if sub_val:
                            item_dict[sub_key] = _parse_yaml_value(sub_val)
                            next_idx += 1
                        else:
                            sub_obj, next_idx = _parse_yaml_block(lines, next_idx + 1, next_line_indent + 2)
                            item_dict[sub_key] = sub_obj
                    else:
                        next_idx += 1
                result.append(item_dict)
                idx = next_idx
            else:
                result.append(_parse_yaml_value(item_content))
                idx += 1
        elif ":" in content:
            if result is None:
                result = {}
            key, _, value = content.partition(":")
            key = key.strip()
            value = value.strip()
            if value:
                result[key] = _parse_yaml_value(value)
                idx += 1
            else:
                sub_obj, idx = _parse_yaml_block(lines, idx + 1, indent + 2)
                result[key] = sub_obj
        else:
            idx += 1

    return result if result is not None else {}, idx


def _parse_yaml_value(val):
    """Parsea un valor escalar: string, int, bool, null."""
    val = val.strip()
    if val.startswith('"') and val.endswith('"'):
        return val[1:-1]
    if val.startswith("'") and val.endswith("'"):
        return val[1:-1]
    if val.lower() in ("true", "yes"):
        return True
    if val.lower() in ("false", "no"):
        return False
    if val.lower() in ("null", "~", ""):
        return None
    try:
        if "." in val:
            return float(val)
        return int(val)
    except ValueError:
        return val


# ============================================
# Lectores
# ============================================

def load_project_config(root):
    """Lee pm/config.json del proyecto."""
    path = os.path.join(root, "pm", "config.json")
    if not os.path.exists(path):
        return {"project_name": os.path.basename(root), "deployed_packages": []}
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def load_dashboard_sections(root):
    """Lee todos los *-section.yaml en dashboard/sections/."""
    sections_dir = os.path.join(root, "dashboard", "sections")
    if not os.path.isdir(sections_dir):
        return []

    sections = []
    for fname in sorted(os.listdir(sections_dir)):
        if not fname.endswith("-section.yaml") and not fname.endswith(".yaml"):
            continue
        path = os.path.join(sections_dir, fname)
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = _yaml_minimal_load(f.read())
            if data and isinstance(data, dict):
                data["_source_file"] = fname
                sections.append(data)
        except Exception as exc:
            sections.append({
                "tab_id": fname.replace("-section.yaml", "").replace(".yaml", ""),
                "tab_label": f"⚠️ Error: {fname}",
                "_source_file": fname,
                "_error": str(exc),
                "sections": [],
            })
    return sections


def read_file_safe(root, rel_path):
    """Lee un archivo validando que está dentro de root (sin escapes ..)."""
    abs_root = os.path.abspath(root)
    abs_path = os.path.abspath(os.path.join(root, rel_path))
    if not abs_path.startswith(abs_root + os.sep) and abs_path != abs_root:
        raise ValueError(f"Path escapes root: {rel_path}")
    if not os.path.isfile(abs_path):
        return None
    with open(abs_path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()


def list_dir_safe(root, rel_path):
    """Lista contenido de un directorio (recursivo, máx 2 niveles)."""
    abs_root = os.path.abspath(root)
    abs_path = os.path.abspath(os.path.join(root, rel_path))
    if not abs_path.startswith(abs_root + os.sep) and abs_path != abs_root:
        raise ValueError(f"Path escapes root: {rel_path}")
    if not os.path.isdir(abs_path):
        return None

    items = []
    for entry in sorted(os.listdir(abs_path)):
        if entry.startswith("."):
            continue
        full = os.path.join(abs_path, entry)
        rel = os.path.relpath(full, abs_root)
        items.append({
            "name": entry,
            "path": rel,
            "is_dir": os.path.isdir(full),
        })
    return items


def build_tabs_response(root):
    """Compone la respuesta /api/tabs: una pestaña por paquete desplegado."""
    config = load_project_config(root)
    sections_definitions = load_dashboard_sections(root)
    deployed = config.get("deployed_packages", [])

    tabs = []
    for sec_def in sections_definitions:
        tab_id = sec_def.get("tab_id", "?")
        tab_label = sec_def.get("tab_label", tab_id)
        tab_icon = sec_def.get("tab_icon", "")
        tab_order = sec_def.get("tab_order", 100)
        scan_dirs = sec_def.get("scan_dirs", [])
        sections = sec_def.get("sections", []) or []

        # Para cada section, intentar leer la fuente
        rendered_sections = []
        for s in sections:
            sid = s.get("id", "?")
            slabel = s.get("label", sid)
            stype = s.get("type", "list")
            source = s.get("source")
            content = None
            error = None
            if source:
                try:
                    content = read_file_safe(root, source)
                except Exception as exc:
                    error = str(exc)
            rendered_sections.append({
                "id": sid,
                "label": slabel,
                "type": stype,
                "source": source,
                "content": content,
                "error": error,
                "exists": content is not None,
                "extra": {k: v for k, v in s.items() if k not in ("id", "label", "type", "source")},
            })

        tabs.append({
            "tab_id": tab_id,
            "tab_label": tab_label,
            "tab_icon": tab_icon,
            "tab_order": tab_order,
            "scan_dirs": scan_dirs,
            "sections": rendered_sections,
            "metadata": sec_def.get("metadata", {}),
            "source_file": sec_def.get("_source_file"),
        })

    tabs.sort(key=lambda t: (t.get("tab_order", 100), t.get("tab_id", "")))

    return {
        "version": VERSION,
        "project_name": config.get("project_name", os.path.basename(root)),
        "deployed_packages": deployed,
        "tabs": tabs,
        "generated_at": _now_iso(),
    }


# ============================================
# HTTP handler
# ============================================

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.dirname(SCRIPT_DIR))  # dashboard/ → proyecto/


class DashboardHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path

        if path == "/" or path == "/index.html":
            self._serve_file(os.path.join(SCRIPT_DIR, "index.html"), "text/html")
        elif path == "/styles.css":
            self._serve_file(os.path.join(SCRIPT_DIR, "styles.css"), "text/css")
        elif path == "/app.js":
            self._serve_file(os.path.join(SCRIPT_DIR, "app.js"), "application/javascript")
        elif path == "/api/health":
            self._json_response({
                "ok": True,
                "version": VERSION,
                "project_name": load_project_config(ROOT).get("project_name", "unknown"),
                "deployed_packages_count": len(load_project_config(ROOT).get("deployed_packages", [])),
                "now": _now_iso(),
            })
        elif path == "/api/tabs":
            self._json_response(build_tabs_response(ROOT))
        elif path == "/api/file":
            params = parse_qs(parsed.query)
            rel = params.get("path", [""])[0]
            try:
                content = read_file_safe(ROOT, rel)
                if content is None:
                    self._json_response({"error": "not_found", "path": rel}, status=404)
                else:
                    self._json_response({"path": rel, "content": content})
            except Exception as exc:
                self._json_response({"error": str(exc), "path": rel}, status=400)
        elif path == "/api/list":
            params = parse_qs(parsed.query)
            rel = params.get("path", [""])[0]
            try:
                items = list_dir_safe(ROOT, rel)
                if items is None:
                    self._json_response({"error": "not_dir", "path": rel}, status=404)
                else:
                    self._json_response({"path": rel, "items": items})
            except Exception as exc:
                self._json_response({"error": str(exc), "path": rel}, status=400)
        else:
            self.send_error(404, "Not Found")

    def _serve_file(self, path, ctype):
        if not os.path.exists(path):
            self.send_error(404, f"Not Found: {path}")
            return
        with open(path, "rb") as f:
            data = f.read()
        self.send_response(200)
        self.send_header("Content-Type", ctype + "; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _json_response(self, data, status=200):
        body = json.dumps(data, ensure_ascii=False, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        # Silenciar logs por defecto (descomentar si quieres ruido en dev)
        pass


# ============================================
# Main
# ============================================

def find_free_port(start, max_attempts):
    import socket
    for p in range(start, start + max_attempts):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.bind(("127.0.0.1", p))
                return p
            except OSError:
                continue
    return None


def main():
    global ROOT
    parser = argparse.ArgumentParser(description="Multi-tab project dashboard")
    parser.add_argument("--port", type=int, default=DEFAULT_PORT)
    parser.add_argument("--root", type=str, default=ROOT)
    args = parser.parse_args()

    ROOT = os.path.abspath(args.root)

    port = find_free_port(args.port, PORT_RANGE)
    if port is None:
        print(f"❌ No free port in range {args.port}..{args.port + PORT_RANGE}", file=sys.stderr)
        sys.exit(1)

    config = load_project_config(ROOT)
    project_name = config.get("project_name", os.path.basename(ROOT))
    deployed = config.get("deployed_packages", [])

    print(f"")
    print(f"╔══════════════════════════════════════════════╗")
    print(f"║  Dashboard — {project_name:<32}║")
    print(f"╚══════════════════════════════════════════════╝")
    print(f"")
    print(f"  Root:               {ROOT}")
    print(f"  Deployed packages:  {len(deployed)} ({', '.join(deployed) if deployed else '(none yet)'})")
    print(f"  Sections found:     {len(load_dashboard_sections(ROOT))}")
    print(f"  URL:                http://localhost:{port}")
    print(f"")
    print(f"  Endpoints:")
    print(f"    GET /api/health     → status básico")
    print(f"    GET /api/tabs       → estructura de pestañas")
    print(f"    GET /api/file       → contenido de archivo")
    print(f"    GET /api/list       → lista de un directorio")
    print(f"")
    print(f"  Press Ctrl+C to stop.")
    print(f"")

    server = HTTPServer(("127.0.0.1", port), DashboardHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
        server.server_close()


if __name__ == "__main__":
    main()
