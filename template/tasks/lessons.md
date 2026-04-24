# Lessons

Patterns to avoid and patterns to repeat, learned on this project.

## Format
Each entry has:
- **Date**
- **Rule** — one line
- **Why** — the incident or reason behind it
- **How to apply** — when this kicks in

## Example
- **2026-04-15**
  - **Rule**: Never mock the MSSQL database in integration tests.
  - **Why**: A mock-passing test shipped a broken migration to staging; the mock didn't catch the schema mismatch.
  - **How to apply**: All `tests/integration/` run against a real test MSSQL instance via the `APP_DB_URL` override.
