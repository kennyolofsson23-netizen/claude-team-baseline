---
name: mssql-best-practices
description: Microsoft SQL Server conventions — T-SQL style, indexing, transactions, migrations via Alembic. Auto-invoked when touching .sql files, models/, alembic/, or when the prompt mentions SQL/MSSQL concepts.
---

# MSSQL Best Practices — Team Edition

Our database is Microsoft SQL Server. All application access goes through SQLAlchemy ORM. See `.claude/rules/mssql.md` for the authoritative rules.

## Connection

```python
# APP_DB_URL example (in .env):
# mssql+pyodbc://user:pwd@host:1433/db?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes

engine = create_engine(settings.db_url, pool_pre_ping=True, pool_recycle=3600)
```

- Driver: ODBC Driver 18 for SQL Server
- Always `pool_pre_ping=True` — detects stale connections
- Always `pool_recycle=3600` — avoids MSSQL's idle timeout kills

## ORM-first, always

```python
# RIGHT — use SQLAlchemy ORM
with session_scope() as s:
    customer = s.get(Customer, customer_id)
    customer.name = new_name

# WRONG — raw SQL in app code is forbidden
s.execute(text(f"UPDATE Customers SET name = '{new_name}' WHERE id = {customer_id}"))
```

Exception: Alembic migrations and narrowly-approved reporting queries may use `text()`. They must be paramterized (never string-concatenated) and must be reviewed by the architect.

## T-SQL style (in migrations and approved queries)

```sql
-- RIGHT
SELECT c.Id, c.Name, c.Email
FROM   dbo.Customers AS c
JOIN   dbo.Orders    AS o ON o.CustomerId = c.Id
WHERE  c.IsActive = 1
  AND  o.CreatedAt >= @since_utc;

-- WRONG
select * from Customers c, Orders o where c.id = o.customerid and isactive = 1
```

Rules:
- Upper-case keywords
- Schema-qualify every table (`dbo.Customers` not `Customers`)
- Never `SELECT *` — list columns
- Always alias tables in joins
- No `NOLOCK` — use `READ COMMITTED SNAPSHOT ISOLATION` at the DB level instead
- Never build SQL by string concatenation

## Indexing

- Every foreign key column → index
- Composite indexes → leading column is most selective
- After creating an index, verify with `EXEC sp_helpindex 'dbo.TableName'`
- Check execution plans for any hot query (SSMS: Ctrl+L to see the estimated plan)

## Data types

| Concept | Type | Why |
|---|---|---|
| Money | `DECIMAL(19, 4)` | `FLOAT` loses precision |
| Dates | `DATETIME2(7)` stored UTC | Higher precision than `DATETIME`; UTC avoids TZ bugs |
| Strings | `NVARCHAR` (Unicode) | ASCII-only exceptions require architect sign-off |
| IDs | `BIGINT IDENTITY` or `UNIQUEIDENTIFIER NEWSEQUENTIALID()` | Avoid random GUIDs (fragmentation) |

## Migrations (Alembic)

- One migration per logical change
- Test downgrade: `alembic downgrade -1 && alembic upgrade head` must succeed
- Data migrations: prefer ORM-level batch operations over raw `text()`
- Migrations run at container boot (Dockerfile ENTRYPOINT)

## Performance patterns

- Pagination beyond 1000 rows: use keyset pagination (seek on indexed column) not `OFFSET`
- N+1 queries: use `joinedload()` for one-to-one, `selectinload()` for one-to-many
- Log slow queries via SQLAlchemy event listener in `src/db.py`
- Batch inserts: `session.bulk_insert_mappings(Model, rows)` — never loop `add()` over thousands

## Transactions

```python
# RIGHT — one session, unit-of-work boundary
with session_scope() as s:
    s.add(order)
    s.add(payment)
    # commits on exit, rolls back on exception

# WRONG — nested commits
session.commit()
try:
    session.add(x)
    session.commit()  # commits inside the outer unit-of-work
except Exception:
    session.commit()  # double-commit — don't do this
```

## Security

- Service accounts only; no shared dev credentials in `.env`
- App user has minimum permissions needed — separate read-only user for analytics
- Enable MSSQL Audit in production (architect configures outside app code)
- Never log SQL strings with parameter values included

## What NOT to do

- No stored procedures for business logic (belongs in Python where it's testable)
- No triggers for business logic
- No cross-database joins without architect approval
- No views coupled to app code (views are an analytics concern)
- Never commit connection strings with credentials — always through `APP_DB_URL` env var
