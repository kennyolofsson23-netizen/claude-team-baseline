"""Smoke tests — must pass on a fresh scaffold with zero configuration.

If any of these fail on a new project, the baseline template itself is broken.
Fix the template, not the test.
"""

from __future__ import annotations


def test_imports() -> None:
    """The app package imports without raising."""
    from src import app  # noqa: F401
    from src import db  # noqa: F401
    from src import errors  # noqa: F401
    from src import main  # noqa: F401
    from src import settings  # noqa: F401


def test_settings_load() -> None:
    from src.settings import get_settings

    s = get_settings()
    assert s.app_env == "test"
    assert s.db_url  # provided by conftest


def test_fastapi_healthz() -> None:
    """The default FastAPI app exposes /healthz returning 200."""
    from fastapi.testclient import TestClient

    from src.main import app

    client = TestClient(app)
    resp = client.get("/healthz")
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "ok"


def test_error_hierarchy() -> None:
    from src.errors import (
        AppError,
        ConfigurationError,
        ExternalServiceError,
        NotFoundError,
        ValidationError,
    )

    for exc in (ConfigurationError, NotFoundError, ValidationError, ExternalServiceError):
        assert issubclass(exc, AppError)
