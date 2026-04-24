# Docker + deployment

Every project ships as a Docker image. The Dockerfile is already in the scaffold — you rarely touch it.

## The build

```bash
docker build -t <registry.company.internal>/<project>:$(git rev-parse --short HEAD) .
docker push <registry.company.internal>/<project>:$(git rev-parse --short HEAD)
```

The Dockerfile:

1. Starts from `mcr.microsoft.com/devcontainers/python:3.12`
2. Installs **Microsoft ODBC Driver 18** for SQL Server (required for `pyodbc`)
3. Installs `uv` and uses it for dependency install (respects `uv.lock`)
4. Runs the app as a non-root `app` user
5. Entrypoint: **Streamlit by default** — uncomment the FastAPI CMD in the Dockerfile if your project is customer-facing or API-only

## Choosing Streamlit vs FastAPI in the Dockerfile

Open `Dockerfile`. You'll see two CMD blocks at the bottom:

```dockerfile
# Streamlit (default) — DELETE IF YOU USE FASTAPI
EXPOSE 8501
CMD ["streamlit", "run", "src/app.py", "--server.port=8501", "--server.address=0.0.0.0"]

# FastAPI — DELETE the Streamlit pair above and UNCOMMENT these
# EXPOSE 8000
# CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

Delete the pair you don't want. **Do not leave both active** — Docker only respects the last `CMD` but keeping both confuses future readers.

## The deploy target

Default assumption: **Azure App Service for Containers**. If you're MSSQL-first on Azure this is the sensible place. Swap if your team uses something different.

```bash
# From the deployer agent — it knows how to run this for you.
# Naming follows Azure CAF:
#   APP_NAME = app-<project>-<env>   e.g. app-invoice-tool-prod
#   RG_NAME  = rg-<project>-<env>    e.g. rg-invoice-tool-prod
# Both are set in .deploy/config.env in each project repo.

source .deploy/config.env
az webapp config container set \
  --name "$APP_NAME" \
  --resource-group "$RG_NAME" \
  --docker-custom-image-name "<registry.company.internal>/<project>:<sha>" \
  --docker-registry-server-url "https://<registry.company.internal>"

az webapp restart --name "$APP_NAME" --resource-group "$RG_NAME"
```

For any other target (Kubernetes, AWS ECS, bare VM), update `ARCHITECTURE.md` and the `deployer` agent will follow that section.

## The smoke test

Every deploy is followed by a smoke test before declaring success:

```bash
URL="https://app-<project>-<env>.azurewebsites.net"  # matches APP_NAME in .deploy/config.env
for i in {1..12}; do
  if curl -fsS "$URL/healthz" > /dev/null; then echo "OK"; break; fi
  sleep 5
done
```

`/healthz` is baked into the FastAPI scaffold. For Streamlit, we probe `_stcore/health` instead (Streamlit's built-in health endpoint).

## The deploy agent

You don't run the commands above by hand — the `deployer` agent does it for you. Just tell Claude:

> deploy this to staging

The agent:

1. Runs the full verification gate (`ruff`, `mypy`, `pytest`)
2. Builds the Docker image tagged with the short SHA
3. Pushes to the registry
4. Deploys to the target
5. Smoke-tests `/healthz`
6. Writes `DEPLOY.md` at the repo root with image tag, URL, timestamp, rollback instructions

If any step fails, the deploy stops and rolls back. No silent failures.

## Rollback

Every deploy writes `DEPLOY.md` including the **previous** image tag. To roll back:

```bash
az webapp config container set \
  --docker-custom-image-name "<previous-image-tag-from-DEPLOY.md>"
```

Or: ask Claude "roll back to the previous deploy" and the `deployer` agent follows `DEPLOY.md`.

## Local-build sanity check

Before pushing:

```bash
docker build -t myapp-local .
docker run --rm -p 8501:8501 \
  --env-file .env \
  myapp-local

# then open http://localhost:8501
```

If the image fails to build locally, it will also fail in CI. Fix it before pushing.

## Common deploy problems

- **ODBC Driver missing in container** — you pinned a Dockerfile base that's not our `devcontainers/python:3.12`. Stay on the baseline base image.
- **`.env` secrets baked into the image** — critical bug. Env vars must be set at runtime, never in the Dockerfile. Ruff / review should catch this.
- **Port mismatch** — `EXPOSE` in Dockerfile, `--port` in CMD, and the `--port` your deploy target listens on all have to match.
- **Streamlit 403 on Azure App Service** — Streamlit blocks cross-origin WebSocket by default. Set `--server.enableCORS=false --server.enableXsrfProtection=false` in the CMD for internal tools only (not customer-facing).
