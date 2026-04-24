# Open the wiki in a browser via a local HTTP server.
# Docsify fetches markdown via AJAX — file:// URLs are blocked by CORS.
# This works around that by serving over http://localhost:<port>.

$serveScript = Join-Path $PSScriptRoot "serve.py"
& python $serveScript $args
