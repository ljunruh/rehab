"""Lokaler Server für den Foliensatz, damit Sprechernotizen direkt in der HTML-Datei landen.

Start:  uv run präsentation/foliensatz/praesentation_server.py   (oder: python3 präsentation/foliensatz/praesentation_server.py)
Öffnet den Foliensatz im Standardbrowser. Im Präsentator-Fenster (Taste P) bearbeitete Notizen
werden automatisch in die Datei geschrieben. Beenden mit Strg+C.

Geschrieben werden nur die data-notes-Attribute der Folien, der Rest der Datei bleibt bytegleich.
"""

import html
import json
import os
import re
import sys
import tempfile
import webbrowser
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import quote

ROOT = Path(__file__).resolve().parent
DEFAULT_FILE = "ReVia_Abschlusspraesentation.html"
HOST = "127.0.0.1"
PORT = int(os.environ.get("PORT", "8765"))

NOTES_RE = re.compile(r'data-notes="([^"]*)"')
TITLE_RE = re.compile(r'<section\b[^>]*\bdata-title="([^"]*)"')


def escape_attr(value: str) -> str:
    # Wie im Original: Tags bleiben lesbar, nur & und " werden maskiert.
    return value.replace("&", "&amp;").replace('"', "&quot;")


def write_notes(name: str, titles: list[str], notes: list[str]) -> int:
    target = (ROOT / name).resolve()
    if target.parent != ROOT or target.suffix != ".html" or not target.is_file():
        raise ValueError(f"Unbekannte Datei: {name}")

    text = target.read_text(encoding="utf-8")
    found = NOTES_RE.findall(text)
    file_titles = [html.unescape(t) for t in TITLE_RE.findall(text)]
    if len(found) != len(notes) or file_titles != titles:
        raise ValueError("Folien in der Datei passen nicht zum geöffneten Stand, bitte neu laden")

    changed = 0
    replacements = iter(notes)

    def patch(match: re.Match) -> str:
        nonlocal changed
        new = next(replacements)
        if html.unescape(match.group(1)) == new:
            return match.group(0)
        changed += 1
        return f'data-notes="{escape_attr(new)}"'

    patched = NOTES_RE.sub(patch, text)
    if changed:
        fd, tmp = tempfile.mkstemp(dir=ROOT, suffix=".tmp")
        with os.fdopen(fd, "w", encoding="utf-8", newline="") as f:
            f.write(patched)
        os.chmod(tmp, target.stat().st_mode)
        os.replace(tmp, target)
    return changed


class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def _json(self, status: int, payload: dict):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path.split("?")[0] == "/__notes__":
            return self._json(200, {"ok": True})
        super().do_GET()

    def do_POST(self):
        if self.path.split("?")[0] != "/__notes__":
            return self._json(404, {"ok": False, "error": "Nicht gefunden"})
        try:
            length = int(self.headers.get("Content-Length", 0))
            data = json.loads(self.rfile.read(length))
            changed = write_notes(data["file"], data["titles"], data["notes"])
        except (ValueError, KeyError, TypeError) as e:
            return self._json(400, {"ok": False, "error": str(e)})
        if changed:
            print(f"  {changed} Notiz(en) in {data['file']} gespeichert", flush=True)
        self._json(200, {"ok": True, "changed": changed})

    def log_message(self, fmt, *args):
        pass


def main():
    name = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_FILE
    server = ThreadingHTTPServer((HOST, PORT), partial(Handler, directory=str(ROOT)))
    url = f"http://{HOST}:{PORT}/{quote(name)}"
    print(f"Foliensatz: {url}\nNotizen werden direkt in {ROOT / name} gespeichert. Beenden mit Strg+C.", flush=True)
    webbrowser.open(url)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nBeendet.")


if __name__ == "__main__":
    main()
