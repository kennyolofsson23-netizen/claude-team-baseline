# Cheat sheet — commands you'll use daily

## Project lifecycle

```bash
# Scaffold a new project from the baseline
bash ~/work/claude-team-baseline/scripts/scaffold-project.sh ~/work/my-new-app

# Open it in Claude
cd ~/work/my-new-app
claude

# Verify your baseline install is healthy
bash ~/work/claude-team-baseline/scripts/verify.sh
```

## Daily Python

```bash
# Install dependencies after pull
uv sync

# Add a new dependency
uv add <package-name>
uv add --dev <package-name>        # dev-only (pytest, mypy plugins, etc.)

# Remove a dependency
uv remove <package-name>

# Run the app (Streamlit)
uv run streamlit run src/app.py

# Run the app (FastAPI) with hot reload — restarts on .py file changes
uv run uvicorn src.main:app --reload   # watchfiles is in dev deps, picked up automatically

# Format + lint
uv run ruff format
uv run ruff check

# Fix lint issues automatically
uv run ruff check --fix

# Type check
uv run mypy

# Run tests
uv run pytest
uv run pytest -x                   # stop on first failure
uv run pytest -k "test_customer"   # run only matching tests
uv run pytest --cov                # with coverage report

# Full verification gate (everything CI runs)
uv run ruff format --check && uv run ruff check && uv run mypy && uv run pytest --cov --cov-fail-under=60
```

## Database

```bash
# Create a new migration (after adding/changing a model)
uv run alembic revision --autogenerate -m "add customers table"

# Apply migrations
uv run alembic upgrade head

# Rollback last migration
uv run alembic downgrade -1

# Migration history
uv run alembic history
```

## Git + Azure DevOps

```bash
# New feature branch
git switch -c feat/<short-description>

# Commit (conventional format — enforced by commit-guard hook)
git commit -m "feat: add customer search endpoint"
git commit -m "fix: handle empty result set in orders query"
git commit -m "docs: update MSSQL section of wiki"
git commit -m "refactor: extract session_scope helper"
git commit -m "test: cover validation error path"
git commit -m "chore: bump fastapi to 0.116"

# Push and open PR
git push -u origin HEAD
az repos pr create --title "feat: <description>" --target-branch main --open

# Check CI / PR status
az repos pr list --status active

# Complete PR when CI green + approved
az repos pr update --id <pr-id> --status completed --merge-strategy squash
```

## Docker

```bash
# Build locally
docker build -t myapp-local .

# Run locally against .env
docker run --rm -p 8501:8501 --env-file .env myapp-local

# Tag for push
docker tag myapp-local <registry>/<project>:$(git rev-parse --short HEAD)
docker push <registry>/<project>:$(git rev-parse --short HEAD)

# Check the image is small enough
docker images | grep <project>
```

## Claude Code

```bash
# Start a session in the current project
claude

# Show session status (which settings layers loaded, which MCPs)
# — run inside a Claude session:
/status

# Show what's in CLAUDE.md
/memory

# Start a brand-new conversation
/clear

# Switch model within a session
/model sonnet       # faster
/model opus         # more capable

# Exit
/exit
```

## Typical prompts for each agent

| Agent | Example prompt |
|---|---|
| architect | "plan the customer dashboard feature" |
| spec-writer | "write user stories for the login flow" |
| feature-builder | (just describe the task — it fires after architect) |
| test-writer | "write tests for the order total calculation" |
| code-reviewer | "ready for PR review" |
| security-reviewer | "review the auth middleware" |
| performance-reviewer | "the orders list is slow, please look" |
| qa-runner | "is this done?" / "ship it" |
| error-detective | paste a traceback, "what's wrong here?" |
| refactoring-specialist | "refactor the customers service" |
| deployer | "deploy to staging" |
| project-scaffolder | "start a new project called invoice-tool" |

## Useful slash commands (built-in)

- `/tdd` — start a red-green-refactor cycle for a feature
- `/test-fix` — diagnose and fix failing tests
- `/qa-setup` — run a full health check of your Claude setup
- `/checkpoint` — save a session state summary
- `/diagram` — generate a Mermaid diagram from code or prose
- `/orchestrate` — multi-step workflow for a complex task
- `/wrap-up` — end a session with a structured summary
