#!/usr/bin/env python3
"""
Architect Console — Bridge

UI del meta-sistema arquitecto. Muestra el estado del ecosistema de paquetes,
propagaciones recientes y reportes de auditoría.

DISTINTO al dashboard multi-pestaña de proyectos clientes:
- 3 secciones fijas (Paquetes, Propagaciones, Auditorías), no pestañas dinámicas
- Lee archivos del propio arquitecto, no de paquetes ni proyectos

Uso:
    python3 bridge.py [--port 7710] [--root <path-al-arquitecto>]

Endpoints:
    GET /                  → index.html
    GET /styles.css        → CSS
    GET /app.js            → JS
    GET /api/health        → status básico + counts
    GET /api/packages      → catálogo de paquetes (lee exports/README.md + exports/*/agent.yaml)
    GET /api/propagations  → últimas N entradas de changelog/propagations.md
    GET /api/audits        → lista de auditorías en docs/architect/audits/
    GET /api/file?path=X   → contenido raw de un archivo (validado contra root)

Sin dependencias externas. stdlib + parser YAML minimalista propio.
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
DEFAULT_PORT = 7710  # paralelo a 7700 del dashboard de proyecto
PORT_RANGE = 10


def _now_iso():
    tz = getattr(datetime, "UTC", datetime.timezone.utc)
    return datetime.datetime.now(tz).replace(microsecond=0).strftime("%Y-%m-%dT%H:%M:%SZ")


# ============================================
# YAML parser minimalista (igual que en project-template/dashboard/bridge.py)
# ============================================

def _yaml_minimal_load(text):
    """Parser YAML simple. Devuelve dict o lista."""
    try:
        import yaml  # noqa
        return yaml.safe_load(text)
    except ImportError:
        pass
    lines = text.split("\n")
    return _parse_yaml_block(lines, 0, 0)[0]


def _parse_yaml_block(lines, idx, indent):
    result = None
    while idx < len(lines):
        raw = lines[idx]
        stripped = raw.split("#", 1)[0].rstrip()
        if not stripped.strip():
            idx += 1
            continue
        line_indent = len(raw) - len(raw.lstrip())
        if line_indent < indent:
            break
        if line_indent > indent:
            idx += 1
            continue
        content = stripped.strip()

        if content.startswith("- "):
            if result is None:
                result = []
            item_content = content[2:].strip()
            if ":" in item_content and not item_content.startswith('"'):
                key, _, value = item_content.partition(":")
                key = key.strip()
                value = value.strip()
                item_dict = {}
                if value:
                    item_dict[key] = _parse_yaml_value(value)
                else:
                    sub_obj, idx_after = _parse_yaml_block(lines, idx + 1, indent + 2)
                    item_dict[key] = sub_obj
                    result.append(item_dict)
                    idx = idx_after
                    continue
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
                    sub_content = next_stripped.strip()
                    if sub_content.startswith("- "):
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
# Lectores específicos del arquitecto
# ============================================

def read_file_safe(root, rel_path):
    abs_root = os.path.abspath(root)
    abs_path = os.path.abspath(os.path.join(root, rel_path))
    if not abs_path.startswith(abs_root + os.sep) and abs_path != abs_root:
        raise ValueError(f"Path escapes root: {rel_path}")
    if not os.path.isfile(abs_path):
        return None
    with open(abs_path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()


def load_packages_catalog(root):
    """Lee exports/*/ y construye catálogo. NO entra a leer contenido específico
    de cada paquete (solo agent.yaml y system-overview.md), per rul-scope-boundaries."""
    exports_dir = os.path.join(root, "exports")
    if not os.path.isdir(exports_dir):
        return {"packages": [], "exports_readme": None}

    # README del catálogo (mantenido por cataloger)
    readme_path = os.path.join(exports_dir, "README.md")
    readme = None
    if os.path.exists(readme_path):
        with open(readme_path, "r", encoding="utf-8") as f:
            readme = f.read()

    packages = []
    for entry in sorted(os.listdir(exports_dir)):
        pkg_path = os.path.join(exports_dir, entry)
        if not os.path.isdir(pkg_path):
            continue
        if entry.startswith(".") or entry == "template":
            continue

        pkg_info = {
            "name": entry,
            "path": f"exports/{entry}/",
        }

        # agent.yaml del paquete: leer name, version, description, metadata (prefix, domain)
        agent_yaml_path = os.path.join(pkg_path, "agent.yaml")
        if os.path.exists(agent_yaml_path):
            try:
                with open(agent_yaml_path, "r", encoding="utf-8") as f:
                    yaml_data = _yaml_minimal_load(f.read())
                if isinstance(yaml_data, dict):
                    pkg_info["yaml_name"] = yaml_data.get("name")
                    pkg_info["version"] = yaml_data.get("version")
                    pkg_info["description"] = yaml_data.get("description")
                    meta = yaml_data.get("metadata", {}) or {}
                    if isinstance(meta, dict):
                        pkg_info["prefix"] = meta.get("prefix")
                        pkg_info["domain"] = meta.get("domain")
                        pkg_info["generated_at"] = meta.get("generated_at")
                    agents_section = yaml_data.get("agents", {}) or {}
                    if isinstance(agents_section, dict):
                        pkg_info["agents_count"] = len(agents_section)
            except Exception as exc:
                pkg_info["yaml_error"] = str(exc)

        # system-overview.md existencia
        sov = os.path.join(pkg_path, "system-overview.md")
        pkg_info["has_system_overview"] = os.path.exists(sov)

        # Último commit del paquete (si tiene git anidado)
        git_dir = os.path.join(pkg_path, ".git")
        pkg_info["has_git"] = os.path.exists(git_dir)

        # context-ledger: contar entradas
        ledger_dir = os.path.join(pkg_path, "context-ledger")
        if os.path.isdir(ledger_dir):
            entries = [f for f in os.listdir(ledger_dir) if f.endswith(".md") and not f.startswith("README")]
            pkg_info["ledger_entries"] = len(entries)
        else:
            pkg_info["ledger_entries"] = 0

        packages.append(pkg_info)

    return {
        "packages": packages,
        "exports_readme": readme,
    }


def load_propagations(root, limit=20):
    """Lee changelog/propagations.md y devuelve últimas N entradas."""
    path = os.path.join(root, "changelog", "propagations.md")
    if not os.path.exists(path):
        return {"exists": False, "entries": [], "raw": None}

    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Parsear entradas: cada entrada empieza con "## " seguido de fecha/timestamp.
    # Formato esperado:  ## YYYY-MM-DD <timestamp> — <scope> — <descripción breve>
    entries = []
    current = None
    for line in content.split("\n"):
        if line.startswith("## "):
            if current:
                entries.append(current)
            current = {"header": line[3:].strip(), "body": []}
        elif current is not None:
            current["body"].append(line)
    if current:
        entries.append(current)

    # Reverso (más reciente primero) y limit
    entries.reverse()
    entries = entries[:limit]
    for e in entries:
        e["body"] = "\n".join(e["body"]).strip()

    return {
        "exists": True,
        "entries": entries,
        "total": len(entries),
        "raw": content if len(entries) == 0 else None,  # si no se parsea nada, devolver raw para debug
    }


def load_audits(root, limit=10):
    """Lista archivos en docs/architect/audits/."""
    audits_dir = os.path.join(root, "docs", "architect", "audits")
    if not os.path.isdir(audits_dir):
        return {"exists": False, "audits": []}

    audits = []
    for fname in sorted(os.listdir(audits_dir), reverse=True):
        if not fname.endswith(".md"):
            continue
        full = os.path.join(audits_dir, fname)
        try:
            with open(full, "r", encoding="utf-8") as f:
                content = f.read()
            # Preview: primeras 5 líneas no vacías
            preview_lines = [l for l in content.split("\n") if l.strip()][:5]
            audits.append({
                "filename": fname,
                "path": f"docs/architect/audits/{fname}",
                "size_bytes": os.path.getsize(full),
                "preview": "\n".join(preview_lines),
            })
        except Exception as exc:
            audits.append({"filename": fname, "error": str(exc)})
        if len(audits) >= limit:
            break

    return {"exists": True, "audits": audits, "total": len(audits)}


# ============================================
# HTTP handler
# ============================================

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.dirname(SCRIPT_DIR))  # architect-console/ → AgentArchitect/


class ArchitectConsoleHandler(BaseHTTPRequestHandler):
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
            catalog = load_packages_catalog(ROOT)
            audits = load_audits(ROOT)
            prop = load_propagations(ROOT, limit=5)
            self._json_response({
                "ok": True,
                "version": VERSION,
                "root": ROOT,
                "counts": {
                    "packages": len(catalog["packages"]),
                    "audits": len(audits.get("audits", [])),
                    "propagations_recent": len(prop.get("entries", [])),
                },
                "now": _now_iso(),
            })
        elif path == "/api/packages":
            self._json_response(load_packages_catalog(ROOT))
        elif path == "/api/propagations":
            params = parse_qs(parsed.query)
            limit = int(params.get("limit", ["20"])[0])
            self._json_response(load_propagations(ROOT, limit=limit))
        elif path == "/api/audits":
            params = parse_qs(parsed.query)
            limit = int(params.get("limit", ["10"])[0])
            self._json_response(load_audits(ROOT, limit=limit))
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
    parser = argparse.ArgumentParser(description="Architect Console")
    parser.add_argument("--port", type=int, default=DEFAULT_PORT)
    parser.add_argument("--root", type=str, default=ROOT)
    args = parser.parse_args()

    ROOT = os.path.abspath(args.root)

    port = find_free_port(args.port, PORT_RANGE)
    if port is None:
        print(f"No free port in range {args.port}..{args.port + PORT_RANGE}", file=sys.stderr)
        sys.exit(1)

    catalog = load_packages_catalog(ROOT)
    packages_count = len(catalog["packages"])

    print(f"")
    print(f"╔══════════════════════════════════════════════╗")
    print(f"║  Architect Console — Meta-system Dashboard   ║")
    print(f"╚══════════════════════════════════════════════╝")
    print(f"")
    print(f"  Root:       {ROOT}")
    print(f"  Packages:   {packages_count} {'(' + ', '.join(p['name'] for p in catalog['packages']) + ')' if catalog['packages'] else '(none yet)'}")
    print(f"  URL:        http://localhost:{port}")
    print(f"")
    print(f"  Endpoints:")
    print(f"    GET /api/health        → status básico")
    print(f"    GET /api/packages      → catálogo de paquetes")
    print(f"    GET /api/propagations  → propagaciones recientes")
    print(f"    GET /api/audits        → reportes de auditoría")
    print(f"    GET /api/file          → contenido de archivo")
    print(f"")
    print(f"  Press Ctrl+C to stop.")
    print(f"")

    server = HTTPServer(("127.0.0.1", port), ArchitectConsoleHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
        server.server_close()


if __name__ == "__main__":
    main()
