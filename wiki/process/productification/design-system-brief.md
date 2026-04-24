# Design System Brief — Template

> For the UX expert to fill in, as the **first real deliverable** before we build the first customer-facing internal product. Aim for ~2 pages.

> Output of this brief: concrete files committed to `claude-team-baseline/template/` so every new product inherits the design system without per-product decisions.

---

## Brand — one-time

- **Name / identity**: `<what do we call ourselves internally?>`
- **Tone of voice**: `<formal | friendly | terse>` — affects microcopy defaults
- **Logo**: `<where is the SVG? which variants exist (dark/light)?>`

## Color palette

Five slots, minimum:

| Slot | Hex | Use |
|---|---|---|
| `primary` | `#???` | Primary actions, headings, brand accent |
| `secondary` | `#???` | Secondary actions, hover states |
| `surface` | `#???` | Background of cards, main canvas |
| `success` | `#???` | Positive feedback |
| `warning` | `#???` | Cautions, non-blocking warnings |
| `error` | `#???` | Destructive / failure states |
| `text-primary` | `#???` | Body text on light surface |
| `text-muted` | `#???` | Secondary text, captions |

Requirements:
- WCAG AA contrast on text-primary vs surface (≥ 4.5:1)
- Must work in Streamlit's theme config (`.streamlit/config.toml`)
- Must work in Jinja templates (CSS variables)

## Typography

- **Heading font**: `<name>` — if not a system font, must be available in Azure-reachable CDN or bundled
- **Body font**: `<name>`
- **Mono font** (for code / numbers): `<name>`
- **Scale** (body / small / h3 / h2 / h1): `<sizes>`

## Spacing and layout

- **Spacing scale**: 4px / 8px / 16px / 24px / 32px / 48px — stick to these
- **Max content width**: `<px>` — for FastAPI+Jinja pages
- **Card / panel radius**: `<px>`
- **Card / panel shadow**: `<token>`

## Iconography

- **Library**: `<Material Icons | Fluent UI Icons | Heroicons>` — pick one, stick with it
- **Stroke weight**: `<regular | bold>`
- Always labeled, never icon-only for actions

## Components

### Streamlit

- `.streamlit/config.toml` committed with chosen theme
- Standard patterns for: sidebar filters, data tables, forms, charts
- Screenshot of reference dashboard showing the above

### FastAPI + Jinja2

- `src/templates/base.html` — header, main, footer, nav
- `src/static/css/theme.css` — CSS variables + minimal component classes
- Standard components: nav bar, card, form, button, table

### Login page

- Azure AD Easy Auth has limited customisation — apply what we can (logo + heading)
- If we need more, it's a separate discussion

## Microcopy defaults

- Loading states: `<"Loading…" | spinner only | etc.>`
- Empty states: `<friendly encouragement | neutral | etc.>`
- Error messages: format / tone
- Success confirmations

## Accessibility baseline

- One `<h1>` per page
- All form inputs labelled
- Focus states visible (never `outline: none` without replacement)
- Color contrast verified (tool: accesslint MCP)
- Keyboard-reachable for every action

## Deliverables (committed to `claude-team-baseline`)

- [ ] `template/.streamlit/config.toml`
- [ ] `template/src/templates/base.html` (FastAPI projects)
- [ ] `template/src/static/css/theme.css` (FastAPI projects)
- [ ] `template/src/static/img/logo.svg`
- [ ] `wiki/stack/design-system.md` (this brief, filled-in — becomes living reference)
- [ ] Example screenshots in `wiki/stack/design-system-examples/`

## Review cadence

- First version: UX expert + Claude, ARB approves
- Revisions: as the team grows, UX expert runs quarterly review of consistency across products
- Change-wish flow for structural changes to the design system
