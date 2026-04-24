# Runbook — `<project-name>`

> Starter scaffold. Fill in the TODOs as you build. See `process/documentation/runbook-template.md` in the baseline for the full template with guidance.

## What this product does

TODO — two sentences.

## Owner

- **Product owner**: TODO
- **Technical owner**: TODO
- **Backup**: TODO

## Architecture at a glance

TODO — link to `docs/ARCHITECTURE.md` or paste a one-line summary.

## How to run locally

```bash
git clone <repo>
cd <project>
uv sync
cp .env.example .env    # fill in local values
uv run alembic upgrade head
uv run streamlit run src/app.py    # or uvicorn for FastAPI
```

## How to deploy

Automated via `.github/workflows/ci.yml` on green `main`.

Manual deploy: see the `deployer` agent or `process/documentation/runbook-template.md` for commands.

## How to roll back

See `DEPLOY.md` (written by each deploy) for the previous image tag. Then `az webapp config container set --docker-custom-image-name <prev>`.

## Common incidents

TODO — add entries as they happen.

## Dependencies

TODO — list Azure SQL DB, Key Vault, App Insights, Azure AD tenant, external APIs.

## Backups

| Frequency | Where | Retention |
|---|---|---|
| TODO | TODO | TODO |

## Backup verification history

| Date | Checked by | Result | Notes |
|---|---|---|---|

## Access review history

| Quarter | Reviewed by | Removed | Notes |
|---|---|---|---|

## Support path

TODO — Ivanti category, Teams channel, etc.

## Useful links

- Azure App Service: TODO
- Azure SQL Database: TODO
- Key Vault: TODO
- App Insights: TODO
- GitHub repo: TODO
- Internal tools catalog entry: TODO
