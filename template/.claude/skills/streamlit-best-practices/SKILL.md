---
name: streamlit-best-practices
description: Streamlit conventions — reactivity model, caching, session state, layout. Auto-invoked when touching src/app.py or when the prompt mentions Streamlit / st.cache / st.session_state.
---

# Streamlit Best Practices — Team Edition

Streamlit is our default for internal tools and dashboards. It is NOT a general-purpose web framework — understanding its reactivity model is what separates working apps from buggy ones.

## The reactivity model — internalize this

**Every user interaction re-runs the entire script top to bottom.** Not just the callback. The whole script.

This means:
- State across reruns must live in `st.session_state` (explicitly named keys) or `st.cache_data` / `st.cache_resource`
- Expensive work (DB queries, API calls, ML inference) must be cached or it runs on every click
- Widgets don't "trigger" code — they change state, then the whole script re-runs, and the new state flows through

If this confuses you, stop and read the official [Streamlit architecture docs](https://docs.streamlit.io/library/advanced-features/caching). Ten minutes there saves hours of head-scratching.

## Caching — the right tool for each job

```python
import streamlit as st

# Pure, deterministic data (list of customers, reference lookup)
@st.cache_data(ttl=300)  # 5-minute TTL
def load_active_customers() -> list[Customer]:
    with session_scope() as s:
        return list(s.query(Customer).filter(Customer.is_active.is_(True)))

# Shared resource — DB engine, ML model, HTTP client
@st.cache_resource
def get_http_client() -> httpx.Client:
    return httpx.Client(base_url=settings.api_url, timeout=10.0)
```

- `cache_data` for serializable return values (lists, dicts, DataFrames, primitives). TTL always set.
- `cache_resource` for non-serializable resources (clients, engines, models). No TTL — lives for the session.
- Pass primitives as args, never ORM models — cache key is hash of args.

## Session state — name every key

```python
# RIGHT — named key, documented lifecycle
if "selected_customer_id" not in st.session_state:
    st.session_state.selected_customer_id = None  # set by customer-picker, read by detail page

# WRONG — magic string, nobody knows what this is
st.session_state["x"] = something
```

Every `session_state` key has a comment explaining its lifecycle: who writes it, who reads it, when it clears.

## Layout patterns

- **Sidebar** for filters and navigation: `with st.sidebar: ...`
- **Tabs** for grouping related views: `t1, t2 = st.tabs(["Overview", "Details"])`
- **Columns** for side-by-side content: `col1, col2 = st.columns(2)`
- **Expanders** for progressive disclosure: `with st.expander("Advanced"): ...`

Never build a single 40-widget page. That's a sign you need tabs or a selectbox-driven page router.

## Feedback — show the user what's happening

- Spinners for anything > 1s: `with st.spinner("Loading..."):`
- Progress bars for bulk operations: `st.progress(0.5, text="50% done")`
- Success / error / warning / info toasts: `st.success("Saved.")`, `st.error("Not found.")`
- Empty states: never a blank table — `st.info("No customers match these filters.")`

## Forms — batch submission

```python
with st.form("customer-form", clear_on_submit=True):
    name = st.text_input("Name")
    email = st.text_input("Email")
    submitted = st.form_submit_button("Save")

if submitted:
    # validation, save, toast
    ...
```

Forms prevent the "re-run on every keystroke" problem for multi-field input. Use them whenever you have > 1 related field.

## Page navigation — native multi-page, not if/elif

For anything beyond a single page, use Streamlit's built-in multi-page app feature — a `pages/` directory next to `app.py`. Each file becomes a page in the sidebar.

```
src/
├── app.py                # home
├── pages/
│   ├── 1_Customers.py
│   └── 2_Reports.py
```

Never build your own navigation with `st.selectbox("Page", ...)` + giant `if/elif`. It breaks URL routing, back-button behavior, and page-level caching.

## What Streamlit CANNOT do well

If you find yourself needing any of these, talk to the architect about switching to FastAPI + Jinja2:

- Complex forms (> 10 fields with validation per field)
- Public URLs meant to be shared / SEO'd
- Custom CSS / bespoke branding beyond the theme config
- Multi-user real-time collaboration (Streamlit sessions don't share state across users)
- Authentication more sophisticated than `streamlit-authenticator` basics
- Embedding in an iframe on another site

## Running locally

```bash
uv run streamlit run src/app.py
# opens http://localhost:8501
```

For headless testing (CI, container smoke tests):

```bash
uv run streamlit run src/app.py --server.headless true &
sleep 5
curl -fsS http://localhost:8501/_stcore/health
```

## Common mistakes to catch in review

- Uncached DB query inside the script body → wrap in `@st.cache_data(ttl=...)`
- `time.sleep(...)` to "wait for state to update" → use `st.rerun()` or fix the state flow
- `st.write(some_huge_object)` in prod → convert to a structured display
- Reading secrets via `st.secrets` when `pydantic-settings` exists → use settings
- A 200-line `app.py` → split into `pages/` and `components/`
