# Skills — the knowledge library

A "skill" in Claude Code is a packaged bundle of knowledge on a specific topic. When it's relevant, Claude reads the `SKILL.md` and applies that knowledge to the task at hand.

Unlike agents, skills don't "do" work — they tell Claude **how to do work** on a specific topic. Claude follows the skill's instructions within the current conversation.

## Our 4 stack skills

| Skill | Fires when | What's in it |
|---|---|---|
| **python-best-practices** | You touch any `.py` file or discuss Python | Approved libraries, typing rules, error handling, testing patterns, file/function size limits, common mistakes to catch in review |
| **mssql-best-practices** | You touch `.sql`, `models/`, `alembic/`, or discuss SQL | T-SQL style (schema-qualify, no `SELECT *`, no `NOLOCK`), indexing, transactions, data types (DECIMAL for money, DATETIME2 UTC for dates), ORM-first rule, migration hygiene |
| **streamlit-best-practices** | You touch `src/app.py` or discuss Streamlit | Reactivity model (script re-runs on every interaction), `st.cache_data` vs `st.cache_resource`, session state patterns, layout (sidebar/tabs/columns), forms, multi-page apps |
| **fastapi-best-practices** | You touch `src/main.py`, `routes/`, or discuss FastAPI | Dependency injection, pydantic request/response split, async vs sync handlers, error handling, background tasks, Jinja2 + htmx + Alpine patterns, testing with TestClient vs httpx.AsyncClient |

## How skills fire

The same `auto-invoke-router.py` hook that fires agents also fires skills. The trigger-rules.yml file maps keywords and file patterns to skill / agent invocations.

Example rule:

```yaml
- name: mssql-ruleset
  match: [".sql", "sql server", "mssql", "stored proc", "query plan"]
  inject: |
    Read `.claude/rules/mssql.md`. Key: no raw SQL in app code (use
    SQLAlchemy ORM), no SELECT *, no NOLOCK, every FK gets an index, schema-
    qualify table names, migrations via Alembic.
```

When your prompt contains any of those keywords, Claude receives the `inject` text as a system-reminder and adjusts its behavior accordingly.

## Skills from the wider ecosystem

Our 4 stack skills are the custom ones we wrote. Claude Code also ships with a large catalog of generic skills (accessibility audits, security reviews, TDD rhythm, verification-before-completion, etc.). These are available by default — you don't need to add anything.

When we find one that helps, we add a keyword trigger for it in `trigger-rules.yml`. When we find one that conflicts with our stack (e.g. a React-focused skill), we don't trigger it.

## Adding a new skill

Rare. Most knowledge belongs in either:

- A team rule (`.claude/rules/`) — simpler, shorter, scoped by file path
- An updated agent — for behaviour that wraps a full workflow

Add a new skill only if:

- The topic is substantial (more than a page of rules)
- The knowledge is reused across many projects
- It's a "how to do X" bundle, not a "check that Y is true" assertion

Process: PR to `claude-team-baseline/template/.claude/skills/<name>/SKILL.md`, plus a trigger rule in `hooks/trigger-rules.yml`.

## Viewing what a skill says

Every skill lives at `template/.claude/skills/<name>/SKILL.md`. Just open it. They're written to be read.

If Claude applied a skill's rules to your code and you don't understand why, read that `SKILL.md` — the reasoning is usually explicit.
