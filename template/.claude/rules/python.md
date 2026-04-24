---
paths:
  - "**/*.py"
  - "pyproject.toml"
  - "requirements*.txt"
---
# Python — Team Rules

## Version
- Python 3.12 only. Pinned via `.python-version` and `pyproject.toml`.
- No conditional imports for older versions. No `typing_extensions` compatibility shims.

## Dependency Management
- `uv` is the only dep manager. Not pip, not poetry, not conda.
- Add: `uv add <pkg>`. Remove: `uv remove <pkg>`. Sync: `uv sync`.
- `pyproject.toml` and `uv.lock` are both committed. Never edit the lock manually.
- No `requirements.txt` — generated only for Docker builds via `uv export`.

## Approved Libraries (the default stack)
- Web framework: `streamlit` (internal/data) OR `fastapi` (API/server-rendered)
- ORM: `sqlalchemy` 2.x + `alembic` migrations
- Database driver: `pyodbc` (MSSQL) with ODBC Driver 18 for SQL Server
- Validation / config: `pydantic` 2.x + `pydantic-settings`
- HTTP client: `httpx` (sync or async). Never `requests`.
- Logging: `structlog`
- Testing: `pytest`, `pytest-asyncio`, `pytest-cov`
- Lint/format: `ruff`
- Types: `mypy`

Anything outside this list requires architect approval via a PR to `claude-team-baseline`.

## Code Style
- Auto-formatted by `ruff format` (replaces black, isort). Enforced in pre-commit.
- Line length 100 (ruff default stays 88? — we override to 100 in pyproject.toml).
- Double-quoted strings, f-strings for interpolation.
- Never use bare `except:`. Catch specific exceptions.
- Never `except Exception:` without re-raising or logging+handling explicitly.
- Use `pathlib.Path` for file operations, never `os.path`.
- Use `datetime` with `tzinfo=UTC` explicit. Never naive datetimes.

## Types
- Type every function signature. No untyped public functions.
- `mypy` runs in default mode (not `--strict`) — we relax to let juniors ship without fighting the type system.
- Use `from __future__ import annotations` at the top of every file for forward-ref clarity.
- Prefer `TypedDict` or `pydantic.BaseModel` over raw dicts for structured data.

## Errors
- Define project-specific exceptions in `src/errors.py`. Subclass them from a single base `AppError`.
- Never return `None` to signal failure. Raise a typed exception.
- User-facing error messages never expose stack traces, internal paths, DB details, or SQL.

## Testing
- `pytest` from the repo root. Tests live in `tests/`, mirror the `src/` layout.
- Every behavior has a test. Write the test first — implementation follows.
- Use `pytest-asyncio` for async code. Mark with `@pytest.mark.asyncio`.
- Use `httpx.AsyncClient` for testing FastAPI endpoints — not the sync TestClient.
- Database tests: use a dedicated test DB (`APP_DB_URL` env var overridden in `conftest.py`). Never mock the DB — integration tests hit real MSSQL.
- Coverage floor: 60% lines (first 3 months; revisit before raising). Checked in CI via `pytest --cov --cov-fail-under=60`.

## Environment & Secrets
- Config via `pydantic-settings` reading from `.env`.
- `.env` is gitignored. `.env.example` committed with every required key, no values.
- Secrets validated on app boot — the app refuses to start if a required key is missing.
- Never hardcode connection strings, API keys, or tokens.

## Encoding
- Set `PYTHONUTF8=1` and `PYTHONIOENCODING=utf-8` in `.bashrc` (handled by `scripts/install.sh`).
- All source files are UTF-8, no BOM.

## What NOT to do
- No `requests` — use `httpx`.
- No raw SQL in Python code — use SQLAlchemy ORM or SQLAlchemy Core expression language.
- No global mutable state. No module-level `db = create_engine(...)`. Use a factory.
- No `sys.path` manipulation. If you need to import, fix the package structure.
- No `print()` for logging. Use `structlog`.
- No `asyncio.run` in library code — only at the entry point.
