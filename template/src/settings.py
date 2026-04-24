from __future__ import annotations

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings, loaded from environment variables and .env.

    All required settings must be provided at boot — the app will refuse to start
    if any are missing. Use `.env.example` as the source of truth for required keys.
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="forbid",
    )

    app_name: str = Field(default="project-name-here")
    app_env: str = Field(default="local", description="local | dev | staging | prod")

    db_url: str = Field(
        ...,
        alias="APP_DB_URL",
        description="SQLAlchemy URL, e.g. mssql+pyodbc://user:pwd@host:1433/db?driver=ODBC+Driver+18+for+SQL+Server",
    )

    log_level: str = Field(default="INFO")


def get_settings() -> Settings:
    """Return the active Settings instance. Cached via module import."""
    return Settings()  # type: ignore[call-arg]
