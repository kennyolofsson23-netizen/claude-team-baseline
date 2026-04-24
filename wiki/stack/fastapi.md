# FastAPI Best Practices — Team Edition

FastAPI is our choice for customer-facing apps (with Jinja2) and for pure API services. Streamlit is the default; FastAPI is used when Streamlit cannot meet the requirement.

## Entry point

`src/main.py`:

```python
from fastapi import FastAPI
from src.settings import get_settings
from src.routes import customers, orders

def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(title=settings.app_name, debug=(settings.app_env == "local"))
    app.include_router(customers.router, prefix="/customers", tags=["customers"])
    app.include_router(orders.router, prefix="/orders", tags=["orders"])
    return app

app = create_app()
```

- Always factory-style (`create_app`). Never module-level `app = FastAPI()` with side effects.
- One router per domain concept, mounted under a prefix.
- `/healthz` route always exists for smoke tests and container orchestration.

## Dependency injection — use it

```python
from fastapi import Depends
from sqlalchemy.orm import Session
from src.db import get_session_factory

def get_session() -> Session:
    factory = get_session_factory()
    session = factory()
    try:
        yield session
    finally:
        session.close()

@router.get("/{customer_id}")
def read_customer(customer_id: int, s: Session = Depends(get_session)) -> CustomerRead:
    customer = s.get(Customer, customer_id)
    if customer is None:
        raise HTTPException(404, "Customer not found")
    return CustomerRead.model_validate(customer)
```

- Every route takes its dependencies via `Depends` — never global state.
- Session is per-request, cleaned up in `finally`.
- Reuse auth / authz / rate-limiting via layered dependencies.

## Pydantic models — separate input and output

```python
class CustomerCreate(BaseModel):
    """Request body for POST /customers"""
    name: str = Field(min_length=1, max_length=200)
    email: EmailStr

class CustomerRead(BaseModel):
    """Response shape — never exposes internal columns like created_by_id"""
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str
    email: str

class CustomerUpdate(BaseModel):
    """PATCH body — all fields optional"""
    name: str | None = None
    email: EmailStr | None = None
```

- `*Create` for POST, `*Update` for PATCH/PUT, `*Read` for responses.
- Response models never include internal fields. Assume everything returned is public.

## Async vs sync

- **Sync** route handlers for DB-bound work with SQLAlchemy sync engine. FastAPI runs them in a thread pool.
- **Async** route handlers when calling external HTTP (`httpx.AsyncClient`) or async-native DBs.
- Never mix: if the handler is `async def`, it must not call a blocking function directly. Use `asyncio.to_thread(...)` for sync work inside an async handler.

## Errors

- Raise `HTTPException(status_code, detail)` for expected errors (404, 400, 409).
- Raise typed `AppError` subclasses for business errors; register an exception handler on the app that maps them to HTTP responses.
- Never return `{"error": "..."}` manually — use `HTTPException` or a response model.

```python
@app.exception_handler(NotFoundError)
def handle_not_found(request: Request, exc: NotFoundError) -> JSONResponse:
    return JSONResponse({"detail": str(exc)}, status_code=404)
```

## Background tasks

- `BackgroundTasks` for small, fire-and-forget work (send email, cache invalidation).
- Anything > 30s → use a real queue (Celery, ARQ, Azure Queue Storage). Do NOT use BackgroundTasks for heavy lifting — it dies if the process restarts.

## Jinja2 + htmx + Alpine (customer-facing profile)

```python
from fastapi.templating import Jinja2Templates

templates = Jinja2Templates(directory="src/templates")

@router.get("/")
def home(request: Request):
    return templates.TemplateResponse("home.html", {"request": request, "name": "world"})
```

- Base template with `{% block %}` sections; never duplicate layout.
- htmx for interactive fragments: `hx-get`, `hx-post`, `hx-swap`. Server returns HTML fragments, not JSON.
- Alpine.js for small client-side state (open/closed, selected tab). Anything bigger → reconsider whether you actually need more than htmx.
- Semantic HTML: one `<h1>` per page, `<main>`, `<nav>`, `<form>` with explicit `<label>`.

## Testing

```python
# sync routes
from fastapi.testclient import TestClient
from src.main import app

def test_healthz():
    client = TestClient(app)
    resp = client.get("/healthz")
    assert resp.status_code == 200
```

```python
# async routes — use httpx.AsyncClient, not the sync TestClient
import httpx
import pytest

@pytest.mark.asyncio
async def test_async_endpoint():
    async with httpx.AsyncClient(app=app, base_url="http://test") as client:
        resp = await client.get("/customers/1")
        assert resp.status_code == 200
```

## Performance

- Add `response_model` to every route — FastAPI validates the response (cost worth it in dev, consider `response_model_exclude_unset` in prod).
- Set reasonable timeouts on `httpx.AsyncClient`: `timeout=httpx.Timeout(10.0)`.
- Avoid heavy work in request handlers: push it to background tasks or a queue.
- Run with `uvicorn src.main:app --workers 4` in prod (Dockerfile sets this up).

## Common mistakes to catch in review

- Raw SQL in route handlers → go through a service layer that uses SQLAlchemy ORM
- Module-level state (caches, clients, connections) → use `Depends` or app startup events
- `time.sleep()` in async handlers → `await asyncio.sleep()`
- Forgotten `response_model` → PII leaks when the ORM model has more fields than intended
- Mutable default args (`def f(items: list = []): ...`) → same Python-wide pitfall
- CORS wide open in prod (`allow_origins=["*"]`) → pin explicit origins from settings
