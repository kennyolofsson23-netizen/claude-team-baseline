# The team stack — one way per concern

We are deliberate and narrow. Fewer choices means fewer bugs, faster onboarding, and nothing to argue about on a Monday morning.

## The full stack

| Concern | Choice | Why |
|---|---|---|
| Language | **Python 3.12** (pinned) | Single language across backend, frontend, scripts |
| UI — internal | **Streamlit** | Write a script, get a web app; good for data-heavy interfaces |
| UI — customer-facing | **FastAPI + Jinja2 + htmx + Alpine.js** | Server-rendered, SEO-friendly, no JS build pipeline |
| API-only services | **FastAPI** | Industry standard for Python APIs; typed; fast |
| Database | **Microsoft SQL Server** via **SQLAlchemy ORM** | Company standard; ORM hides most raw SQL complexity |
| Migrations | **Alembic** | Auto-generated from ORM changes |
| Dependency manager | **uv** | One fast tool; replaces pip + poetry + pyenv |
| Format + lint | **Ruff** | Replaces black + isort + flake8 with one tool |
| Types | **mypy** (default mode, not strict) | Strict mode fights juniors more than it helps |
| Tests | **pytest** + **pytest-asyncio** + **pytest-cov** | De facto standard; coverage floor 80% |
| Config | **pydantic-settings** reading `.env` | Validated at boot; app refuses to start if required config missing |
| HTTP client | **httpx** | async-capable, drop-in replacement for `requests` |
| Logging | **structlog** (JSON in prod) | Structured by default; plays well with observability tools |
| Container | **Docker** | One runtime, any cloud |
| CI | **Azure Pipelines** | `azure-pipelines.yml` runs ruff + pytest + mypy |
| Deploy | **Azure App Service for Containers** (assumed default) | Sensible Azure+MSSQL default; swap in your target |

## Not in our stack (common things devs ask for, all NO unless architect approves)

- **React / Vue / Svelte / Next.js** — all customer-facing UI goes through FastAPI + Jinja2 + htmx. If you need a true SPA, talk to the architect with a specific technical reason Streamlit + htmx cannot solve.
- **requests** — use `httpx`.
- **Raw SQL in application code** — use SQLAlchemy ORM. Alembic migrations may use `text()` sparingly and only with parameterization.
- **Stored procedures for business logic** — business logic lives in Python where it's testable.
- **Triggers for business logic** — same reason.
- **NoSQL / Mongo / DynamoDB** — talk to the architect.
- **MongoDB / Redis / Kafka** — each needs architect sign-off.
- **Poetry / pipenv / conda** — we standardized on uv.
- **black / flake8 / isort** — ruff replaces all three.

## How the stack is enforced

Four layers, described in [Permissions & safety](governance/permissions.md):

1. **Claude settings** — deny-list blocks `npm install react*`, `Write(**/*.tsx)`, etc. Claude refuses to add off-stack code.
2. **Pre-commit hooks** — block `.tsx/.jsx` files from being staged, run ruff + mypy.
3. **CI** — re-runs all pre-commit checks, plus pytest with coverage. Failing CI blocks merge.
4. **CODEOWNERS** (Phase 2) — architect must approve any change that touches stack-defining files.

## What we deliberately deferred

- **React escape hatch** — it's written into `ARCHITECTURE.md` as possible but gated behind architect approval. We haven't needed it yet.
- **Real-time / WebSocket** — FastAPI supports it; architect decides per-project if we need it.
- **Background jobs / message queues** — Azure Queue Storage when we need it; not part of the default scaffold.
- **Observability stack** (OpenTelemetry, Sentry, Prometheus) — plugged in as projects need them; no one-size-fits-all config yet.
- **Feature flags** — solved with `settings.py` env vars for now; proper flag system later when we have more deploys.

## When you want to add something

1. Open a PR to `claude-team-baseline` — not to your project.
2. In the PR description: what, why, alternatives considered, what the architect should worry about.
3. Architect reviews. If approved, this wiki + the rules + the baseline template all get updated in one PR.
4. Everyone's Claude picks up the change next time they scaffold or pull.
