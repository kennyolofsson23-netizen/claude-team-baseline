# CI enforcement

Our CI runs on Azure Pipelines. One pipeline file, two jobs, all blocking. Green CI is required before merge.

## The pipeline file

`template/azure-pipelines.yml` — copied into every new project by the scaffolder. Do not edit it in an individual project; propose changes via PR to `claude-team-baseline` instead.

## What CI runs

### Job 1 — `quality` (Python stack checks)

Runs on every push and every pull request:

1. **Setup** — checkout, install uv, install Python 3.12, `uv sync --frozen`
2. **Ruff format check** — `uv run ruff format --check`. Fails if any file needs formatting.
3. **Ruff lint** — `uv run ruff check`. Fails on any lint error.
4. **mypy** — `uv run mypy`. Fails on any type error.
5. **pytest with coverage** — `uv run pytest --cov --cov-fail-under=60`. Fails on any test failure or if coverage drops below 60%.

All four steps must pass for the job to succeed.

### Job 2 — `secret_scan`

Runs `gitleaks` against the full git history of the PR branch. Catches API keys, private keys, `.env` content, and other secret patterns.

## Why these specific checks

| Check | Catches | Why it matters |
|---|---|---|
| Ruff format | Inconsistent whitespace / import order / quote style | Zero-noise diffs, no style debates in review |
| Ruff lint | Unused imports, dead code, obvious bugs, anti-patterns | Many small bugs caught before runtime |
| mypy | Type errors, missing type hints | The "forgot to await this coroutine" class of bug |
| pytest | Logic bugs, regressions | The main safety net |
| Coverage floor | Untested code sneaking in | Forces juniors to keep writing tests; matches the TDD rule in CLAUDE.md |
| gitleaks | Secrets in git history | Leaked credentials are expensive; catch them before they hit main |

## Running CI checks locally

Before you push, run the same checks CI will run:

```bash
uv run ruff format --check
uv run ruff check
uv run mypy
uv run pytest --cov --cov-fail-under=60
```

Or let the pre-commit hook run ruff + gitleaks automatically on every commit (it's already wired up in `.pre-commit-config.yaml` — install with `uv run pre-commit install` once per clone).

## When CI fails

1. **Read the error.** Pipeline logs are shown in the PR. Don't guess what failed — read it.
2. **Reproduce locally.** Run the failing command yourself. If it passes locally but fails in CI, something about your local env differs (usually missing dep in `pyproject.toml`).
3. **Fix and push.** Don't merge-around by force-pushing or closing+reopening.
4. **If you can't fix it after 3 attempts**, tag the architect. Don't spiral alone.

## What CI does NOT check

- Browser behaviour / UI correctness — that's the `qa-runner` agent's job, run locally
- Production smoke tests — that's the `deployer` agent's job
- Security vulnerabilities in dependencies — Phase 2 adds `pip-audit` or ADO Dependabot equivalent
- Performance regressions — Phase 3+ adds benchmark tests for specific endpoints

Keep CI fast. Anything that takes > 5 minutes belongs in a separate pipeline or nightly job.

## Adding a CI check

1. Open a PR to `claude-team-baseline`
2. Update `template/azure-pipelines.yml`
3. Architect reviews — does this check add real value vs. adding time to the feedback loop?
4. Merge → every project gets it on next scaffold or baseline-bump

Don't add checks to individual projects unless they're truly project-specific (e.g. a benchmark on a specific endpoint). General checks belong in the baseline.
