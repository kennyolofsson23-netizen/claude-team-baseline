"""FastAPI entry point. Used only for customer-facing and pure-API profiles.

Delete this file if the project is an internal Streamlit tool.
"""

from __future__ import annotations

from fastapi import FastAPI
from fastapi.responses import JSONResponse

from src.settings import get_settings


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(title=settings.app_name, debug=(settings.app_env == "local"))

    @app.get("/healthz")
    def healthz() -> JSONResponse:
        return JSONResponse({"status": "ok", "env": settings.app_env})

    @app.get("/")
    def index() -> JSONResponse:
        return JSONResponse(
            {
                "service": settings.app_name,
                "message": "Replace this with your application. See ARCHITECTURE.md.",
            }
        )

    return app


app = create_app()
