#!/usr/bin/env python3
"""Serve the wiki over a local HTTP server and open it in the browser.

Docsify fetches markdown via AJAX, which browsers refuse when opened as
file:// due to CORS. Running a local HTTP server fixes this — any browser
can fetch http://localhost:<port>/... without restriction.

Usage:
    python wiki/serve.py            # serves on http://localhost:7777
    python wiki/serve.py --port 8080
    python wiki/serve.py --no-open   # don't auto-open the browser

Ctrl+C to stop.
"""

from __future__ import annotations

import argparse
import http.server
import os
import socketserver
import sys
import threading
import webbrowser
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description="Serve the team wiki over localhost.")
    parser.add_argument("--port", type=int, default=7777, help="Port to bind (default: 7777)")
    parser.add_argument("--no-open", action="store_true", help="Do not auto-open the browser")
    args = parser.parse_args()

    wiki_dir = Path(__file__).resolve().parent
    os.chdir(wiki_dir)

    # Resolve port — if the requested one is taken, try +1, +2, ... +10 before giving up
    port = args.port
    for attempt in range(10):
        try:
            server = socketserver.TCPServer(("127.0.0.1", port), http.server.SimpleHTTPRequestHandler)
            break
        except OSError:
            port += 1
    else:
        print(f"Could not bind ports {args.port}-{args.port + 9}. Pass --port to pick another.", file=sys.stderr)
        return 1

    url = f"http://localhost:{port}/index.html"
    print(f"Wiki serving at: {url}")
    print(f"Root:            {wiki_dir}")
    print("Press Ctrl+C to stop.")

    if not args.no_open:
        threading.Timer(0.7, lambda: webbrowser.open(url)).start()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping.")
        server.shutdown()
        server.server_close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
