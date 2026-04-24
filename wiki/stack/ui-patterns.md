# UI Patterns — What Good Looks Like

> The `frontend-design` skill enforces these rules automatically. This page is the human-readable version — read it once, then let Claude apply it.

We are not designers. We follow a small set of rules so our apps look professional
without requiring taste or experience. The rules are not negotiable — if you think
you have a reason to break one, talk to the architect first.

---

## Which technology for which job

| App type | Use | Do NOT use |
|---|---|---|
| Internal tool / dashboard | Streamlit | FastAPI, React, anything else |
| Customer-facing / public URL | FastAPI + Jinja2 + Tailwind | Streamlit, React |
| API-only (no UI) | FastAPI | Streamlit |

If Streamlit genuinely cannot meet the requirement, document why in `ARCHITECTURE.md` and get architect sign-off before switching.

---

## Streamlit — the rules

### Theme
The team theme is in `.streamlit/config.toml` — already in the scaffold. Azure blue primary, white background, clean gray surfaces. Do not override it. Do not add custom CSS unless the architect approves.

### Page structure
```
┌─────────────────────────────────────────┐
│  st.title("Page name")                  │
├──────────────┬──────────────────────────┤
│  st.sidebar  │  col1 (2/3)  col2 (1/3)  │
│  · Filters   │  Main content  Actions   │
│  · Nav       │                          │
└──────────────┴──────────────────────────┘
```

- One `st.title()` per page. Never two.
- Filters and navigation go in `st.sidebar`.
- Split content/actions with `st.columns([2, 1])`.
- Group related widgets in `st.expander("Advanced")`.

### Data tables
Always use `column_config`. Always `use_container_width=True`. Always `hide_index=True`.

```python
st.dataframe(df, column_config={
    "amount":  st.column_config.NumberColumn("Amount", format="kr %.2f"),
    "status":  st.column_config.SelectboxColumn("Status", options=["Active","Closed"]),
    "created": st.column_config.DateColumn("Created", format="YYYY-MM-DD"),
}, use_container_width=True, hide_index=True)
```

### KPI metrics — three in a row
```python
col1, col2, col3 = st.columns(3)
col1.metric("Active users",   "142",  "+12 this week")
col2.metric("Open tickets",   "8",    "-3 vs yesterday")
col3.metric("Avg resolution", "4.2h", "+0.3h")
```

### Feedback — always visible state
| Situation | Use |
|---|---|
| Saved / success | `st.success("Saved.")` |
| Validation error | `st.error("Name is required.")` |
| Warning | `st.warning("No data for this period.")` |
| Empty state | `st.info("No results match this filter.")` |
| Loading > 1s | `with st.spinner("Loading..."):` |

**Never leave a blank area where data should be.**

---

## Jinja2 + Tailwind — the rules

Add one line to `base.html`:
```html
<link href="https://cdn.tailwindcss.com" rel="stylesheet">
```

### Colours — only these, no others

| Purpose | Classes |
|---|---|
| Primary button | `bg-blue-600 text-white hover:bg-blue-700` |
| Secondary button | `bg-white text-blue-600 border border-blue-600 hover:bg-blue-50` |
| Danger button | `bg-red-600 text-white hover:bg-red-700` |
| Page background | `bg-gray-50` |
| Card / surface | `bg-white border border-gray-200 rounded-lg shadow-sm` |
| Primary text | `text-gray-900` |
| Secondary text | `text-gray-500` |
| Caption / meta | `text-gray-400 text-xs` |

If a colour you need is not in this table — stop. Ask the architect. Do not invent.

### Page skeleton
```html
<body class="bg-gray-50 min-h-screen">
  <nav class="bg-white border-b border-gray-200 px-6 py-4">...</nav>
  <main class="max-w-5xl mx-auto px-6 py-8">...</main>
</body>
```

### Cards
```html
<div class="bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
  <h3 class="text-base font-medium text-gray-900 mb-2">Title</h3>
  <p class="text-sm text-gray-500">Content</p>
</div>
```

### Typography hierarchy — one h1 per page
```html
<h1 class="text-2xl font-semibold text-gray-900">Page title</h1>
<h2 class="text-lg font-medium text-gray-900">Section</h2>
<p  class="text-sm text-gray-600">Body</p>
<span class="text-xs text-gray-400">Caption</span>
```

---

## Hard don'ts

- No animations beyond `transition-colors` on interactive elements
- No gradients in app UI (gradients are for marketing, not tools)
- No colour as the **only** signal — always pair with text or icon
- No more than 3 font weights per page
- No custom CSS in Streamlit unless architect-approved
- No `_blank` links without `rel="noopener"`
- No placeholder text as a label — every input has an explicit `<label>`

---

## When to escalate

These rules cover ~90% of internal tool UI needs. Escalate to the architect when:
- A flow has > 4 steps (wizard / multi-step form)
- A page has > 3 data sources shown simultaneously
- You need real-time multi-user updates
- A customer (external to IT) will see it in production

For those cases, the architect decides whether ux-pro MCP is warranted.
