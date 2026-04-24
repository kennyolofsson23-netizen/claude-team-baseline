# Python Best Practices — Team Edition

Our Python stack is opinionated and narrow by design. Fewer choices = fewer bugs, faster onboarding.

## The approved stack

See `.claude/rules/python.md` for the authoritative list. Summary:

- **Runtime**: Python 3.12 (pinned via `.python-version`)
- **Deps**: `uv` — `uv add`, `uv remove`, `uv sync`
- **Web**: `streamlit` (internal) or `fastapi` (customer-facing / API)
- **DB**: `sqlalchemy` 2.x + `alembic` + `pyodbc` for MSSQL
- **Config**: `pydantic-settings`
- **HTTP**: `httpx`. Never `requests`.
- **Logs**: `structlog`
- **Tests**: `pytest` + `pytest-asyncio` + `pytest-cov`
- **Lint/format**: `ruff`
- **Types**: `mypy` (default mode, not strict — too much friction for juniors)

Anything else needs a PR to `claude-team-baseline`.

## Typing — every public signature

```python
from __future__ import annotations

def greet(name: str, count: int = 1) -> str:
    return (f"hello {name}\n" * count).rstrip()
```

- Top of every file: `from __future__ import annotations`
- Public functions always typed
- Prefer `TypedDict` / `pydantic.BaseModel` over raw `dict`
- `datetime` always has `tzinfo=UTC`
- `pathlib.Path` for every path, never `os.path`

## Error handling

- Define typed exceptions in `src/errors.py`, all subclass `AppError`
- Never `except Exception:` without re-raising or handling explicitly
- Never `except:` (bare) — catch specific types
- Never return `None` to signal failure — raise a typed exception
- User-facing error messages never expose stack traces or internal paths

## Testing patterns

- Tests live in `tests/`, mirror `src/` layout
- Every behavior has a test — write the test FIRST
- Async: mark with `@pytest.mark.asyncio` (auto-enabled via `asyncio_mode = "auto"`)
- DB tests: real MSSQL via the `APP_DB_URL` override — never mock the database
- FastAPI: `from fastapi.testclient import TestClient` for sync routes; `httpx.AsyncClient` for async
- Coverage floor: 80% lines, enforced by `pytest --cov-fail-under=80`

## Common mistakes to catch in review

- Swallowed exceptions (`except Exception: pass`)
- `print()` for logging → use `structlog`
- Module-level DB engine (`db = create_engine(...)` at top of module) → use a factory (see `src/db.py`)
- `requests` library → swap to `httpx`
- `datetime.now()` (naive) → `datetime.now(tz=UTC)`
- N+1 queries in SQLAlchemy → use `joinedload()` / `selectinload()`
- Mutable default arguments (`def f(x=[]): ...`) → use `None` and set inside

## File and function sizes

- Max 300 lines per `.py` — split into sub-modules
- Max 40 lines per function — extract helpers
- Max 3 parameters — use an options object for more
- No nested ternaries
- `__init__.py` re-exports only, no logic

## When to look things up

Use Context7 (`mcp__context7__query-docs`) before writing code that uses:
- FastAPI (the API moves; never code from memory)
- SQLAlchemy 2.x (1.x → 2.x was a big shift)
- Pydantic 2.x (v1 → v2 was a bigger shift)
- Alembic (migration patterns change across versions)
- Streamlit (new components ship monthly)

Never trust your training data for any library API — always verify current.
