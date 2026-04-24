# Your first project

The end-to-end walkthrough. If everything is installed, this should take 15-20 minutes.

## Step 1 — Scaffold a project

```bash
bash ~/work/claude-team-baseline/scripts/scaffold-project.sh ~/work/hello-claude
cd ~/work/hello-claude
```

You should now have a fresh Streamlit + FastAPI + SQLAlchemy project with Claude configuration baked in.

## Step 2 — Set up `.env`

```bash
cp .env.example .env
```

Open `.env` in VS Code and fill in `APP_DB_URL` with your local dev MSSQL connection, or use the SQLite default for first-run:

```bash
# .env
APP_NAME=hello-claude
APP_ENV=local
LOG_LEVEL=DEBUG
APP_DB_URL=sqlite:///local.db
```

(Swap to MSSQL once you have a test database configured.)

## Step 3 — Run the smoke test

```bash
uv run pytest tests/test_smoke.py -v
```

All four tests should pass. If they don't, the scaffold is broken — report to the architect.

## Step 4 — Run the app

```bash
# Streamlit (the default scaffold)
uv run streamlit run src/app.py
```

Open http://localhost:8501. You should see a "hello-claude" page with the env banner.

Or, if your project is customer-facing:

```bash
# FastAPI
uv run uvicorn src.main:app --reload
# Then open http://localhost:8000/docs for the auto-generated API docs.
```

## Step 5 — Start Claude

```bash
claude
```

First prompt to try:

> I just scaffolded this project. Walk me through what each file does, and show me how to add a "Hello" page that reads one row from a `customers` table.

Watch what Claude does:

1. **It should plan first** — list the steps it'll take. Read the plan. Confirm or redirect.
2. **It should write a test first** — and you'll see it fail.
3. **It should implement the minimum** to make the test pass.
4. **It should run the test** — confirm pass.
5. **It should run the verification gate** — ruff, mypy, pytest.
6. **It should commit** with a conventional commit message.

If Claude skips a step or jumps straight to code, interrupt it and say "plan first please". That's a signal the auto-invoke hook didn't fire — worth reporting to the architect.

## Step 6 — Your first real change

After the walkthrough, try something substantive:

> Add a `GET /customers` endpoint to the FastAPI app that returns a list of customers from the database, ordered by name. Paginate at 50 per page.

Again, watch the rhythm:

- Plan
- Test (failing)
- Implementation
- Test (passing)
- Verification gate
- Commit

Claude will ask you to confirm the plan before writing code. Read it. Push back if something looks off.

## Step 7 — Push to GitHub

```bash
git remote add origin https://github.com/<your-org>/hello-claude.git
git push -u origin main
```

Then open a PR with any subsequent changes — CI runs automatically, and the `code-reviewer` agent can review the diff in a session.

## Common first-day mistakes

- **Skipping the plan.** "I know what I want, just code it." Fine for experienced devs; bad for juniors. The plan catches misunderstandings before you've written 50 lines of wrong code.
- **Not reading Claude's code.** If you can't explain a line to a teammate, you shouldn't be shipping it. Ask Claude to explain anything that's unclear.
- **Skipping the verification gate** because you're in a hurry. Every time you skip, you're gambling that the CI will catch your mistakes later. CI is slower than local; fix things locally first.
- **Using pip instead of `uv add`.** `uv.lock` is the source of truth. Bypassing it means CI will have different deps than you do.
- **Editing `~/.claude/` files to "fix" something.** Always open a PR to `claude-team-baseline` instead.

## Where to go next

- [Onboarding](getting-started/onboarding.md) — full day-one guide
- [The team stack](stack/overview.md) — why we use what we use
- [Cheat sheet](reference/cheatsheet.md) — commands for daily work
- [Troubleshooting](reference/troubleshooting.md) — when things don't work
