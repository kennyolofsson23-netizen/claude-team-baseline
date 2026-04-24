---
name: frontend-design
description: Visual design rules for Streamlit and Jinja2 apps. Auto-invoked when building UI, adding pages, designing layouts, or when the prompt mentions colours, design, dashboard, or UI. Keeps junior output looking professional without a dedicated designer.
---

# Frontend Design — Team Rules

We are not designers. We follow a small set of concrete rules so our apps look
professional by default, without requiring taste or experience.

**Stack**: Streamlit for internal tools. FastAPI + Jinja2 + Tailwind CDN for
customer-facing. Never mix. Never invent a third option.

---

## Streamlit — theme and layout

The scaffold already includes `.streamlit/config.toml` with the team theme.
Do not override it per-app. Do not add custom CSS unless the architect approves.

### Space and structure

- One `st.title()` per page. Never two.
- Group related controls in `st.sidebar` or `st.expander`, never scattered.
- Use `st.columns([2, 1])` for content + action panel. Never `st.columns(4)` — too narrow on laptops.
- Separate sections with `st.divider()`, not `st.write("---")`.
- Max three levels of visual hierarchy per page: title → section header → content.

### Data display

```python
# RIGHT — column config makes tables readable
st.dataframe(df, column_config={
    "amount":  st.column_config.NumberColumn("Amount", format="kr %.2f"),
    "status":  st.column_config.SelectboxColumn("Status", options=["Active","Closed"]),
    "created": st.column_config.DateColumn("Created", format="YYYY-MM-DD"),
}, use_container_width=True, hide_index=True)

# WRONG — raw dataframe dump
st.write(df)
```

Always use `column_config`. Always `use_container_width=True`. Always `hide_index=True`.

### Metrics and KPIs

```python
col1, col2, col3 = st.columns(3)
col1.metric("Active users",   "142",  "+12 this week")
col2.metric("Open tickets",   "8",    "-3 vs yesterday")
col3.metric("Avg resolution", "4.2h", "+0.3h")
```

Three metrics in a row is the standard pattern. Use `delta` for trend, not a separate column.

### Feedback

| Situation | Component |
|---|---|
| Action succeeded | `st.success("Saved.")` |
| Validation error | `st.error("Name is required.")` |
| Warning, not blocking | `st.warning("No data for this period.")` |
| Info / empty state | `st.info("No results match this filter.")` |
| Loading > 1s | `with st.spinner("Loading..."):` |

Never leave a blank area where data should be. Always show an info message for empty state.

### Colour — do not invent

The theme provides one primary colour (blue). Use it only via Streamlit's own
components (buttons, progress, metrics delta). Never `st.markdown('<span style="color:red">')`.

The only exception: `st.status` for pipeline steps with `:running:` / `:complete:` / `:error:`.

---

## Jinja2 + Tailwind — customer-facing apps

Add this to your base template `src/templates/base.html`. One line. Done.

```html
<link href="https://cdn.tailwindcss.com" rel="stylesheet">
```

### Colour palette — use only these

```
Primary action:   bg-blue-600   text-white      hover:bg-blue-700
Secondary action: bg-white      text-blue-600   border border-blue-600
Destructive:      bg-red-600    text-white      hover:bg-red-700
Surface:          bg-white
Background:       bg-gray-50
Border:           border-gray-200
Text primary:     text-gray-900
Text secondary:   text-gray-500
```

No custom colours. No `style="color: #ABC123"`. If the palette doesn't cover it, ask the architect.

### Typography

```html
<h1 class="text-2xl font-semibold text-gray-900">Page title</h1>
<h2 class="text-lg font-medium text-gray-900">Section</h2>
<p  class="text-sm text-gray-600">Body text</p>
<span class="text-xs text-gray-400">Caption / metadata</span>
```

One `h1` per page. `font-semibold` for titles, `font-medium` for sections, `font-normal` for body.

### Layout skeleton

```html
<body class="bg-gray-50 min-h-screen">
  <nav class="bg-white border-b border-gray-200 px-6 py-4">
    <!-- logo + nav items -->
  </nav>
  <main class="max-w-5xl mx-auto px-6 py-8">
    <!-- content -->
  </main>
</body>
```

Max width `max-w-5xl`. Padding `px-6 py-8`. Always center with `mx-auto`.

### Cards

```html
<div class="bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
  <h3 class="text-base font-medium text-gray-900 mb-2">Card title</h3>
  <p class="text-sm text-gray-500">Card content</p>
</div>
```

All content surfaces are cards with `rounded-lg border border-gray-200 shadow-sm`. Never naked divs with background colour.

### Tables

```html
<table class="w-full text-sm text-left">
  <thead class="bg-gray-50 text-gray-500 uppercase text-xs tracking-wider">
    <tr>
      <th class="px-4 py-3 border-b border-gray-200">Name</th>
      <th class="px-4 py-3 border-b border-gray-200">Status</th>
    </tr>
  </thead>
  <tbody class="divide-y divide-gray-100">
    <tr class="hover:bg-gray-50">
      <td class="px-4 py-3 text-gray-900">Example</td>
      <td class="px-4 py-3">
        <span class="px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full">Active</span>
      </td>
    </tr>
  </tbody>
</table>
```

### Buttons

```html
<!-- Primary -->
<button class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 transition-colors">
  Save
</button>

<!-- Secondary -->
<button class="px-4 py-2 bg-white text-blue-600 text-sm font-medium rounded-md border border-blue-600 hover:bg-blue-50 transition-colors">
  Cancel
</button>

<!-- Destructive -->
<button class="px-4 py-2 bg-red-600 text-white text-sm font-medium rounded-md hover:bg-red-700 transition-colors">
  Delete
</button>
```

Always `transition-colors`. Always `rounded-md`. Never rounded-full on action buttons.

### Form inputs

```html
<label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
<input type="email"
  class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
  placeholder="name@company.com">
<p class="text-xs text-red-600 mt-1">Required field</p>  <!-- validation error -->
```

---

## What NOT to do

- No animations except `transition-colors` on interactive elements
- No gradients (leave those to the executive summary)
- No more than 3 font weights per page (normal, medium, semibold)
- No icons without a label for important actions
- No colour to convey the only meaning — always pair with text or icon
- No placeholder text as a label — every field has an explicit `<label>`
- Never open a link in `_blank` without `rel="noopener"`

---

## When to escalate to ux-pro MCP

Only when building a **customer-facing** app with **complex flows** (multi-step
wizards, dashboards with drill-down, data-entry forms > 8 fields). For internal
Streamlit tools: follow this skill. The rules above are sufficient.
