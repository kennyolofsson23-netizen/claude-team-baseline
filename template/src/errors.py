from __future__ import annotations


class AppError(Exception):
    """Base class for all application errors.

    All domain-specific exceptions subclass this. Do not raise bare `Exception`
    anywhere in application code — define a typed subclass here.
    """


class ConfigurationError(AppError):
    """Raised when required configuration is missing or invalid."""


class NotFoundError(AppError):
    """Raised when a requested resource does not exist."""


class ValidationError(AppError):
    """Raised when input fails business-rule validation (distinct from pydantic field validation)."""


class ExternalServiceError(AppError):
    """Raised when an upstream service (HTTP API, DB, queue) fails in a way we cannot retry out of."""
