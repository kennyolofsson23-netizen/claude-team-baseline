"""pytest configuration — sets safe default env vars BEFORE any test module imports.

IMPORTANT: This file runs when pytest starts, before any `test_*.py` file is
imported. We set required env vars at the top (module level) so that
`from src.main import app` at test-module-import time does not crash because
Settings() has no APP_DB_URL.

Do NOT move these os.environ.setdefault calls inside a fixture — fixtures run
per-test, which is too late.
"""

from __future__ import annotations

import os

os.environ.setdefault("APP_ENV", "test")
os.environ.setdefault(
    "APP_DB_URL",
    # SQLite in-memory — safe default for unit/smoke tests. Integration tests
    # that need real MSSQL should override APP_DB_URL in their own fixture.
    "sqlite:///:memory:",
)
