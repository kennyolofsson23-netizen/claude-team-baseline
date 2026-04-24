# Troubleshooting

## Setup problems

### `winget install Anthropic.ClaudeCode` fails

- Confirm the ID: `winget search "claude code"`. Microsoft occasionally renames Store packages.
- Try running winget from a regular (non-admin) PowerShell too — some packages install per-user.
- If winget is itself broken, `Get-AppxPackage Microsoft.DesktopAppInstaller` and update from the Microsoft Store.

### `claude` command not found after install

- **Reboot.** Windows often doesn't refresh PATH for running shells. New shells after reboot should find it.
- If still missing: `where claude` — if it returns nothing, reinstall: `winget install --force --id Anthropic.ClaudeCode`.
- If the install is fine but PATH doesn't include `%LOCALAPPDATA%\Programs\ClaudeCode`, add it manually (System Properties → Environment Variables → User PATH).

### `uv sync` fails with a `pyodbc` error

You're missing the Microsoft ODBC Driver 18 for SQL Server.

```powershell
# As Administrator
winget install --id Microsoft.ODBCDriverForSQLServer.18 --source winget --silent
```

Then:

```bash
python -c "import pyodbc; print([d for d in pyodbc.drivers() if 'SQL Server' in d])"
# expected: ['ODBC Driver 18 for SQL Server']
```

### `docker build` fails or Docker Desktop won't start

- First time only: **reboot** after Docker Desktop installs — WSL 2 backend needs the reboot.
- `Docker Desktop > Settings > Resources > WSL Integration` — make sure your distro is enabled.
- Corporate proxy? `Docker Desktop > Settings > Resources > Proxies` — configure.

## Daily workflow problems

### Claude keeps asking for permission on every command

The allow-list in `.claude/settings.json` is too tight. You can either:

- **Temporarily**: approve once via the prompt. It caches for the session.
- **Permanently** (team-wide): open a PR to `claude-team-baseline/template/.claude/settings.json` adding the command to `permissions.allow`.

**Don't** widen the list in your local `.claude/` — it'll get reset next scaffold, and the team won't benefit.

### Claude refuses to install a library I need

That's deliberate. Ask Claude to check if our existing stack solves the problem (90% of the time it does). If you're sure the approved stack can't do it, open a PR to `claude-team-baseline` proposing the addition.

### Pre-commit hook blocks my commit

Read the error. Common reasons:

- **Secret detected** — a real secret leaked into a diff. Unstage, clean the file, re-commit.
- **Image file outside asset dirs** — move the image to `public/`, `static/`, or `assets/` and re-stage.
- **Ruff format** — run `uv run ruff format` to fix, re-stage, re-commit.
- **Ruff lint error** — read the error, fix the code, re-stage.

You can bypass pre-commit with `git commit --no-verify`, but CI will catch you on the PR. Don't do it.

### CI fails but tests pass locally

Usually a missing dependency. Check:

- Is the lib in `pyproject.toml` and `uv.lock`? If you did `pip install` instead of `uv add`, the lock is wrong.
- Is the test env the same as CI's? CI runs on Linux; your local runs on Windows. Path separators, line endings, case sensitivity can differ.
- Is it a flaky test? Run it multiple times locally to reproduce. If it's flaky, that's a bug in the test — fix the test, not the CI.

### Streamlit app runs but doesn't show my changes

Streamlit caches. Two caches to clear:

```bash
# Clear Streamlit's cache
streamlit cache clear

# Or in the app, use `@st.cache_data` TTLs you can control
```

If you changed an `@st.cache_resource` — those don't clear with `cache clear`. Restart Streamlit.

### FastAPI `/docs` returns 404

- Debug mode needs to be on: `FastAPI(debug=True)` — or set `APP_ENV=local` in `.env` since the scaffold wires debug to that.
- You disabled docs: check `src/main.py` for `docs_url=None` or `openapi_url=None`.

### Type error: "APP_DB_URL is not a valid SQLAlchemy URL"

- In `.env`, make sure it's the full SQLAlchemy MSSQL URL:
  ```
  APP_DB_URL=mssql+pyodbc://user:pwd@host:1433/db?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes
  ```
- No spaces. No quotes around the value. The `+` signs in the driver name need to be literal, not URL-encoded.

## Claude-specific problems

### Auto-invoke router isn't firing

Test it manually:

```bash
echo '{"prompt": "deploy this"}' | python template/.claude/hooks/auto-invoke-router.py
```

If no output, one of:

- The hook script errored silently — run without the pipe to see stderr
- The `trigger-rules.yml` syntax is broken — we have a minimal YAML parser; check for unusual indentation
- Claude Code didn't actually call the hook — check `settings.json` for the `UserPromptSubmit` hook config

### An agent is doing something I don't want

You can always interrupt Claude and redirect. Say:

> Stop. I want to do this differently. Let me explain...

If an agent's default behaviour is genuinely wrong for the team, open a PR to `claude-team-baseline/template/.claude/agents/<name>.md`.

### Claude is being too verbose / too brief

Add to your personal `~/.claude/CLAUDE.md`:

```
## Personal preferences
- Concise. Show the answer, not the reasoning, unless asked.
```

Or the opposite, if you want more explanation.

## Getting help

1. Check this wiki — search (Ctrl+K) for a keyword.
2. Ask Claude in-session — paste the error, say "what's wrong".
3. Look at `git log --oneline` on `claude-team-baseline` — has this been hit and fixed before?
4. Ask the architect / Kenny.

None of these should take more than 10 minutes. If you've been stuck longer, you're grinding — stop, ask, move on.
