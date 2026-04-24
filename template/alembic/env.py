"""Alembic environment — reads APP_DB_URL from pydantic-settings, not alembic.ini.

Whenever you add a new SQLAlchemy model, import it here so Alembic's autogenerate
picks it up:

    from src.models.customer import Customer  # noqa: F401
"""

from __future__ import annotations

from logging.config import fileConfig

from alembic import context
from sqlalchemy import engine_from_config, pool

from src.settings import get_settings

# Alembic Config object — provides access to values in alembic.ini
config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Override the URL from environment (via pydantic-settings)
_settings = get_settings()
config.set_main_option("sqlalchemy.url", _settings.db_url)

# SQLAlchemy MetaData for autogenerate support.
# When you have models, set:   target_metadata = Base.metadata
target_metadata = None


def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
