#!/usr/bin/env bash
# Open the wiki in a browser via a local HTTP server.
# Docsify fetches markdown via AJAX — file:// URLs are blocked by CORS.
# This works around that by serving over http://localhost:<port>.

exec python "$(dirname "$0")/serve.py" "$@"
