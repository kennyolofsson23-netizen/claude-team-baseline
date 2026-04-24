"""Default Streamlit entry point. Replace for FastAPI projects — see src/main.py."""

from __future__ import annotations

import streamlit as st

from src.settings import get_settings


def main() -> None:
    settings = get_settings()

    st.set_page_config(page_title=settings.app_name, layout="wide")

    st.title(settings.app_name)
    st.caption(f"Environment: {settings.app_env}")

    st.markdown(
        "Welcome. This is a fresh scaffold from `claude-team-baseline`. "
        "Replace this page with your application. See `ARCHITECTURE.md` for the plan."
    )

    with st.expander("Settings"):
        st.code(
            f"app_env = {settings.app_env}\nlog_level = {settings.log_level}",
            language="ini",
        )


if __name__ == "__main__":
    main()
