from __future__ import annotations

import os
from collections.abc import Iterator

import pytest


@pytest.fixture(autouse=True)
def _test_env(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    """Set safe defaults for tests so settings load without a real .env file."""
    monkeypatch.setenv("APP_ENV", "test")
    monkeypatch.setenv(
        "APP_DB_URL",
        os.environ.get(
            "APP_DB_URL",
            "sqlite:///:memory:",  # safe default — integration tests override this
        ),
    )
    yield
