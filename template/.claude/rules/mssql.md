---
paths:
  - "**/*.sql"
  - "**/models/**/*.py"
  - "**/db/**/*.py"
  - "alembic/**/*.py"
---
# MSSQL (Microsoft SQL Server) — Team Rules

Our database is Microsoft SQL Server. All application-level database access goes through SQLAlchemy ORM. Raw SQL appears only in Alembic migrations and in carefully-reviewed reporting queries.

## Connection
- Driver: `pyodbc` + ODBC Driver 18 for SQL Server
- Connection string format:
  ```
  mssql+pyodbc://<user>:<pwd>@<host>:1433/<db>?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes
  ```
- Read the URL from `APP_DB_URL` env var via `pydantic-settings`. Never hardcode.
- Always use a connection pool — `sqlalchemy.create_engine(..., pool_pre_ping=True)`.

## ORM-First Rule
- All reads and writes go through SQLAlchemy ORM models in `src/models/`.
- Complex read queries: use SQLAlchemy Core (`select()`) — still typed and safe, no string concatenation.
- Raw `text()` SQL is forbidden in application code. Exceptions require architect approval and must be accompanied by a comment explaining why ORM cannot express the query.

## T-SQL Style (in migrations and approved reporting queries)
- **Always upper-case keywords**: `SELECT`, `FROM`, `WHERE`, `JOIN`, not `select`.
- **Never `SELECT *`** — list columns explicitly. Enforced by `sqlfluff` in CI.
- **Always schema-qualify**: `dbo.Customers` not `Customers`.
- **Always alias tables** in joins, use the alias everywhere.
- **Indent cleanly**: one clause per line, joined conditions indented.
- **No `NOLOCK` hints**. They cause dirty reads. If you need read concurrency, use `READ COMMITTED SNAPSHOT ISOLATION` at the database level.
- **Explicit transactions** only where needed. SQLAlchemy session handles most — do not nest.

## Indexing
- Every foreign key gets an index. Alembic auto-generates this — verify.
- Never rely on implicit indexes on non-primary-key columns. Declare them explicitly.
- Composite indexes: leading column is the most selective one.
- After adding an index, run `EXEC sp_helpindex 'dbo.TableName'` to verify it exists.

## Migrations (Alembic)
- Every schema change goes through Alembic. Never edit the schema directly.
- One migration per logical change. Do not bundle unrelated changes.
- Test the downgrade: `alembic downgrade -1` then `alembic upgrade head`. Both must succeed.
- Data migrations: use `op.execute(text(...))` sparingly. Prefer orchestrating via ORM in the migration.
- Migrations run before app start in the Dockerfile entrypoint.

## Transactions
- SQLAlchemy session + unit-of-work pattern. Open one session per request / per task.
- Never commit inside a loop over a large result set — batch in chunks of 1000.
- Use `session.begin_nested()` for savepoints, not nested `try/commit` patterns.

## Query Performance
- Any query returning > 1000 rows: paginate via `LIMIT` / `OFFSET` or keyset pagination.
- Any endpoint doing N+1 queries fails code review. Use `joinedload()` or `selectinload()`.
- Log slow queries (> 500ms) via SQLAlchemy event listener — configured in `src/db.py`.
- Use `EXPLAIN`-equivalent: in SSMS, "Display Estimated Execution Plan" (Ctrl+L). The architect reviews plans for any hot query.

## Data Types
- Money: use `DECIMAL(19, 4)` — never `FLOAT`.
- Dates: prefer `DATETIME2(7)` over `DATETIME`. Always store UTC.
- Strings: `NVARCHAR` (Unicode) by default. `VARCHAR` only when you can prove the column is ASCII-only.
- Identifiers: `BIGINT IDENTITY` or `UNIQUEIDENTIFIER` (NEWSEQUENTIALID default) depending on insert pattern.

## Security
- Never build SQL via string concatenation. SQLAlchemy parameterizes automatically — keep it that way.
- Service accounts only — no shared credentials in `.env`.
- The app's DB user has the minimum permissions needed. Separate read-only reporting user for analytics.
- Enable MSSQL Audit on production. The architect configures this outside of app code.

## Common Pitfalls to Avoid
- Implicit case-insensitive collation — test with mixed-case data.
- Unicode parameter binding issue: always pass `str` not `bytes` for NVARCHAR columns.
- ODBC Driver version drift — pin the driver version in the Dockerfile.
- Forgetting to set `pool_recycle` on long-running apps — connection timeout kills the pool.

## What NOT to do
- No stored procedures for application logic. Business logic lives in Python.
- No triggers for business logic. Put it in the app where it is testable.
- No views coupled to app code. Views are a reporting concern, owned by the analytics team.
- No cross-database joins without architect approval.
