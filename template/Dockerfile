# syntax=docker/dockerfile:1.7

# Python 3.12 + ODBC Driver 18 for SQL Server
FROM mcr.microsoft.com/devcontainers/python:3.12 AS base

# Install Microsoft ODBC Driver 18 for SQL Server
# https://learn.microsoft.com/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

WORKDIR /app

# Dependency layer — copy lock + toml first for build caching
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project

# App layer
COPY . .
RUN uv sync --frozen

# Non-root user for runtime
RUN groupadd -r app && useradd -r -g app -d /app app \
    && chown -R app:app /app
USER app

ENV PYTHONUTF8=1 \
    PYTHONIOENCODING=utf-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/app/.venv/bin:$PATH"

# IMPORTANT — pick ONE entry point below and DELETE THE OTHER TWO before building.
# Leaving both means only the LAST CMD wins and you will ship the wrong app.

# Streamlit (internal tools, dashboards) — the default scaffold
EXPOSE 8501
CMD ["streamlit", "run", "src/app.py", "--server.port=8501", "--server.address=0.0.0.0"]

# FastAPI (customer-facing apps, pure APIs) — uncomment these and delete the Streamlit pair above
# EXPOSE 8000
# CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
