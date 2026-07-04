#!/usr/bin/env python3
"""
Screenshot/Recording Gallery Viewer
Serves a local browser-based gallery for a Screenshots/YYYY/MM/DD/Type/ tree,
with Open, Reveal in Finder, Copy Path, and Copy Image actions.

Usage:
    python3 screenshot_viewer.py [--dir PATH] [--port PORT]

Default dir: ~/Downloads/Screenshots
Default port: 5050
"""

import argparse
import json
import mimetypes
import os
import subprocess
import sys
import threading
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs, unquote

IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".gif", ".heic", ".webp", ".bmp", ".tiff"}
VIDEO_EXTS = {".mov", ".mp4", ".m4v"}
MEDIA_EXTS = IMAGE_EXTS | VIDEO_EXTS

BASE_DIR = None  # set at startup, absolute realpath


def build_index():
    """Walk BASE_DIR and return a list of file metadata dicts."""
    items = []
    for root, _dirs, files in os.walk(BASE_DIR):
        for name in files:
            ext = os.path.splitext(name)[1].lower()
            if ext not in MEDIA_EXTS:
                continue
            full = os.path.join(root, name)
            rel = os.path.relpath(full, BASE_DIR)
            parts = rel.split(os.sep)
            if len(parts) >= 5:
                year, month, day, type_ = parts[0], parts[1], parts[2], parts[3]
            else:
                year, month, day, type_ = "Unsorted", "", "", ""
            try:
                stat = os.stat(full)
                mtime = stat.st_mtime
                size = stat.st_size
            except OSError:
                mtime = 0
                size = 0
            items.append({
                "rel": rel,
                "filename": name,
                "year": year,
                "month": month,
                "day": day,
                "type": type_,
                "kind": "video" if ext in VIDEO_EXTS else "image",
                "mtime": mtime,
                "size": size,
            })
    items.sort(key=lambda x: x["mtime"], reverse=True)
    return items


def safe_abspath(rel):
    """Resolve a relative path safely inside BASE_DIR, raising ValueError if it escapes."""
    rel = unquote(rel)
    candidate = os.path.realpath(os.path.join(BASE_DIR, rel))
    base = os.path.realpath(BASE_DIR)
    if candidate != base and not candidate.startswith(base + os.sep):
        raise ValueError("Path escapes base directory")
    if not os.path.isfile(candidate):
        raise ValueError("Not a file")
    return candidate


PAGE_HTML = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Screenshot Gallery</title>
<style>
  :root {
    --bg: #0f1117;
    --panel: #171a23;
    --accent: #8b7fe8;
    --accent2: #5fb3f0;
    --text: #e6e6ee;
    --muted: #8a8fa3;
    --border: #262b3a;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    background: var(--bg);
    color: var(--text);
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
  }
  header {
    padding: 16px 20px;
    border-bottom: 1px solid var(--border);
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    align-items: center;
    position: sticky;
    top: 0;
    background: var(--bg);
    z-index: 10;
  }
  header h1 {
    font-size: 16px;
    margin: 0 16px 0 0;
    color: var(--accent);
    font-weight: 600;
    white-space: nowrap;
  }
  select, input[type=text] {
    background: var(--panel);
    color: var(--text);
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 6px 10px;
    font-size: 13px;
  }
  input[type=text] { min-width: 180px; }
  .count { color: var(--muted); font-size: 12px; margin-left: auto; }
  main { padding: 20px; }
  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: 14px;
  }
  .card {
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 10px;
    overflow: hidden;
    cursor: pointer;
    transition: border-color .15s, transform .1s;
  }
  .card:hover { border-color: var(--accent); transform: translateY(-2px); }
  .thumb-wrap {
    width: 100%;
    aspect-ratio: 4/3;
    background: #0a0b10;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
  }
  .thumb-wrap img, .thumb-wrap video {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
  .meta {
    padding: 8px 10px;
    font-size: 11px;
    color: var(--muted);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .meta .fname { color: var(--text); display: block; font-size: 12px; margin-bottom: 2px; overflow: hidden; text-overflow: ellipsis; }
  .badge {
    display: inline-block;
    font-size: 9px;
    padding: 1px 6px;
    border-radius: 4px;
    background: rgba(139,127,232,0.15);
    color: var(--accent);
    margin-right: 4px;
  }
  .empty { color: var(--muted); text-align: center; padding: 60px 20px; }

  .overlay {
    display: none;
    position: fixed; inset: 0;
    background: rgba(0,0,0,0.85);
    z-index: 100;
    align-items: center;
    justify-content: center;
    flex-direction: column;
    padding: 30px;
  }
  .overlay.active { display: flex; }
  .overlay .preview {
    max-width: 90vw;
    max-height: 70vh;
    border-radius: 8px;
    background: #000;
  }
  .overlay .info {
    color: var(--muted);
    margin-top: 14px;
    font-size: 13px;
    text-align: center;
  }
  .overlay .info .fname { color: var(--text); font-size: 15px; display: block; margin-bottom: 4px; }
  .actions {
    display: flex;
    gap: 10px;
    margin-top: 16px;
    flex-wrap: wrap;
    justify-content: center;
  }
  .actions button {
    background: var(--panel);
    border: 1px solid var(--border);
    color: var(--text);
    padding: 8px 16px;
    border-radius: 8px;
    font-size: 13px;
    cursor: pointer;
  }
  .actions button:hover { border-color: var(--accent2); color: var(--accent2); }
  .actions button.primary { background: var(--accent); color: #0f1117; border-color: var(--accent); font-weight: 600; }
  .actions button.primary:hover { opacity: 0.9; }
  .close-btn {
    position: absolute;
    top: 20px; right: 24px;
    background: none; border: none;
    color: var(--muted);
    font-size: 26px;
    cursor: pointer;
  }
  .close-btn:hover { color: var(--text); }
  .toast {
    position: fixed;
    bottom: 24px; left: 50%;
    transform: translateX(-50%) translateY(20px);
    background: var(--accent);
    color: #0f1117;
    padding: 10px 18px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    opacity: 0;
    transition: opacity .2s, transform .2s;
    z-index: 200;
    pointer-events: none;
  }
  .toast.show { opacity: 1; transform: translateX(-50%) translateY(0); }
</style>
</head>
<body>

<header>
  <h1>&#128247; Screenshot Gallery</h1>
  <select id="fYear"><option value="">All years</option></select>
  <select id="fMonth"><option value="">All months</option></select>
  <select id="fType">
    <option value="">All types</option>
    <option value="Screenshots">Screenshots</option>
    <option value="Recordings">Recordings</option>
  </select>
  <input type="text" id="fSearch" placeholder="Search filename...">
  <span class="count" id="count"></span>
</header>

<main>
  <div class="grid" id="grid"></div>
  <div class="empty" id="empty" style="display:none;">No items match this filter.</div>
</main>

<div class="overlay" id="overlay">
  <button class="close-btn" id="closeBtn">&times;</button>
  <div id="previewHolder"></div>
  <div class="info">
    <span class="fname" id="infoName"></span>
    <span id="infoMeta"></span>
  </div>
  <div class="actions" id="actionRow"></div>
</div>

<div class="toast" id="toast"></div>

<script>
let ALL_ITEMS = [];
let CURRENT = null;

function fmtSize(bytes) {
  if (bytes < 1024) return bytes + " B";
  if (bytes < 1024*1024) return (bytes/1024).toFixed(1) + " KB";
  return (bytes/1024/1024).toFixed(1) + " MB";
}

function showToast(msg) {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), 1800);
}

async function loadItems() {
  const res = await fetch('/api/files');
  ALL_ITEMS = await res.json();
  populateFilters();
  render();
}

function populateFilters() {
  const years = [...new Set(ALL_ITEMS.map(i => i.year))].filter(Boolean).sort().reverse();
  const months = [...new Set(ALL_ITEMS.map(i => i.month))].filter(Boolean).sort();
  const ySel = document.getElementById('fYear');
  const mSel = document.getElementById('fMonth');
  years.forEach(y => {
    const opt = document.createElement('option');
    opt.value = y; opt.textContent = y;
    ySel.appendChild(opt);
  });
  months.forEach(m => {
    const opt = document.createElement('option');
    opt.value = m; opt.textContent = m;
    mSel.appendChild(opt);
  });
}

function currentFilters() {
  return {
    year: document.getElementById('fYear').value,
    month: document.getElementById('fMonth').value,
    type: document.getElementById('fType').value,
    search: document.getElementById('fSearch').value.trim().toLowerCase(),
  };
}

function render() {
  const f = currentFilters();
  const filtered = ALL_ITEMS.filter(i => {
    if (f.year && i.year !== f.year) return false;
    if (f.month && i.month !== f.month) return false;
    if (f.type && i.type !== f.type) return false;
    if (f.search && !i.filename.toLowerCase().includes(f.search)) return false;
    return true;
  });

  document.getElementById('count').textContent = filtered.length + " item" + (filtered.length===1?"":"s");
  const grid = document.getElementById('grid');
  grid.innerHTML = '';
  document.getElementById('empty').style.display = filtered.length ? 'none' : 'block';

  filtered.forEach(item => {
    const card = document.createElement('div');
    card.className = 'card';
    card.onclick = () => openOverlay(item);

    const thumbWrap = document.createElement('div');
    thumbWrap.className = 'thumb-wrap';
    if (item.kind === 'video') {
      const v = document.createElement('video');
      v.src = '/media?path=' + encodeURIComponent(item.rel);
      v.preload = 'metadata';
      v.muted = true;
      thumbWrap.appendChild(v);
    } else {
      const img = document.createElement('img');
      img.src = '/media?path=' + encodeURIComponent(item.rel);
      img.loading = 'lazy';
      thumbWrap.appendChild(img);
    }
    card.appendChild(thumbWrap);

    const meta = document.createElement('div');
    meta.className = 'meta';
    const date = [item.year, item.month, item.day].filter(Boolean).join('-');
    meta.innerHTML = '<span class="fname">' + item.filename + '</span>' +
      '<span class="badge">' + (item.type || 'Unsorted') + '</span>' + date;
    card.appendChild(meta);

    grid.appendChild(card);
  });
}

function openOverlay(item) {
  CURRENT = item;
  const holder = document.getElementById('previewHolder');
  holder.innerHTML = '';
  if (item.kind === 'video') {
    const v = document.createElement('video');
    v.src = '/media?path=' + encodeURIComponent(item.rel);
    v.controls = true;
    v.autoplay = false;
    v.className = 'preview';
    holder.appendChild(v);
  } else {
    const img = document.createElement('img');
    img.src = '/media?path=' + encodeURIComponent(item.rel);
    img.className = 'preview';
    holder.appendChild(img);
  }
  document.getElementById('infoName').textContent = item.filename;
  document.getElementById('infoMeta').textContent =
    [item.year, item.month, item.day, item.type].filter(Boolean).join(' / ') + '  ·  ' + fmtSize(item.size);

  const actions = document.getElementById('actionRow');
  actions.innerHTML = '';
  actions.appendChild(makeBtn('Open', () => postAction('/api/open', item.rel), true));
  actions.appendChild(makeBtn('Reveal in Finder', () => postAction('/api/reveal', item.rel)));
  actions.appendChild(makeBtn('Copy Path', () => copyPath(item.rel)));
  if (item.kind === 'image') {
    actions.appendChild(makeBtn('Copy Image', () => postAction('/api/copy-image', item.rel)));
  }

  document.getElementById('overlay').classList.add('active');
}

function makeBtn(label, fn, primary) {
  const b = document.createElement('button');
  b.textContent = label;
  if (primary) b.className = 'primary';
  b.onclick = (e) => { e.stopPropagation(); fn(); };
  return b;
}

async function postAction(url, rel) {
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({path: rel})
    });
    const data = await res.json();
    if (data.ok) {
      showToast(data.message || 'Done');
    } else {
      showToast('Error: ' + (data.error || 'failed'));
    }
  } catch (e) {
    showToast('Request failed');
  }
}

function copyPath(rel) {
  fetch('/api/abspath?path=' + encodeURIComponent(rel))
    .then(r => r.json())
    .then(data => {
      navigator.clipboard.writeText(data.abspath).then(() => {
        showToast('Path copied');
      });
    });
}

document.getElementById('closeBtn').onclick = () => {
  document.getElementById('overlay').classList.remove('active');
  document.getElementById('previewHolder').innerHTML = '';
};
document.getElementById('overlay').addEventListener('click', (e) => {
  if (e.target.id === 'overlay') {
    document.getElementById('overlay').classList.remove('active');
    document.getElementById('previewHolder').innerHTML = '';
  }
});
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    document.getElementById('overlay').classList.remove('active');
    document.getElementById('previewHolder').innerHTML = '';
  }
});

['fYear','fMonth','fType'].forEach(id => document.getElementById(id).addEventListener('change', render));
document.getElementById('fSearch').addEventListener('input', render);

loadItems();
</script>
</body>
</html>
"""


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # quiet

    def _send_json(self, obj, status=200):
        body = json.dumps(obj).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/":
            body = PAGE_HTML.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        elif parsed.path == "/api/files":
            self._send_json(build_index())
        elif parsed.path == "/api/abspath":
            qs = parse_qs(parsed.query)
            rel = qs.get("path", [""])[0]
            try:
                abspath = safe_abspath(rel)
                self._send_json({"abspath": abspath})
            except ValueError:
                self._send_json({"error": "invalid path"}, 400)
        elif parsed.path == "/media":
            qs = parse_qs(parsed.query)
            rel = qs.get("path", [""])[0]
            try:
                abspath = safe_abspath(rel)
            except ValueError:
                self.send_response(404)
                self.end_headers()
                return
            ctype, _ = mimetypes.guess_type(abspath)
            ctype = ctype or "application/octet-stream"
            try:
                with open(abspath, "rb") as f:
                    data = f.read()
                self.send_response(200)
                self.send_header("Content-Type", ctype)
                self.send_header("Content-Length", str(len(data)))
                self.end_headers()
                self.wfile.write(data)
            except OSError:
                self.send_response(404)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        parsed = urlparse(self.path)
        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length) if length else b"{}"
        try:
            payload = json.loads(raw or b"{}")
        except json.JSONDecodeError:
            payload = {}
        rel = payload.get("path", "")

        try:
            abspath = safe_abspath(rel)
        except ValueError:
            self._send_json({"ok": False, "error": "invalid path"}, 400)
            return

        if parsed.path == "/api/open":
            try:
                subprocess.run(["open", abspath], check=True)
                self._send_json({"ok": True, "message": "Opened"})
            except Exception as e:
                self._send_json({"ok": False, "error": f"open failed: {e}"}, 500)
        elif parsed.path == "/api/reveal":
            try:
                subprocess.run(["open", "-R", abspath], check=True)
                self._send_json({"ok": True, "message": "Revealed in Finder"})
            except Exception as e:
                self._send_json({"ok": False, "error": f"reveal failed: {e}"}, 500)
        elif parsed.path == "/api/copy-image":
            ext = os.path.splitext(abspath)[1].lower()
            try:
                if ext == ".png":
                    apple_script = 'set the clipboard to (read (POSIX file "%s") as «class PNGf»)' % abspath
                else:
                    apple_script = 'set the clipboard to (read (POSIX file "%s") as JPEG picture)' % abspath
                subprocess.run(["osascript", "-e", apple_script], check=True)
                self._send_json({"ok": True, "message": "Image copied"})
            except Exception as e:
                self._send_json({"ok": False, "error": f"copy failed: {e}"}, 500)
        else:
            self._send_json({"ok": False, "error": "unknown action"}, 404)


def main():
    global BASE_DIR
    parser = argparse.ArgumentParser()
    parser.add_argument("--dir", default=os.path.expanduser("~/Downloads/Screenshots"))
    parser.add_argument("--port", type=int, default=5050)
    parser.add_argument("--no-browser", action="store_true")
    args = parser.parse_args()

    BASE_DIR = os.path.realpath(os.path.expanduser(args.dir))
    if not os.path.isdir(BASE_DIR):
        print(f"Directory not found: {BASE_DIR}")
        sys.exit(1)

    server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    url = f"http://127.0.0.1:{args.port}"
    print(f"Serving gallery for {BASE_DIR}")
    print(f"Open: {url}")

    if not args.no_browser:
        threading.Timer(0.5, lambda: webbrowser.open(url)).start()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down.")
        server.shutdown()


if __name__ == "__main__":
    main()
