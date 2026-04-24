# Internal Productification Checklist

> When does a built app become a **real internal product**? When every box below is ticked. Shorter than the public-SaaS version — we're internal-only.

## Identity

- [ ] **Named** — a human-readable name, not just the code slug
- [ ] **Owned** — one person accountable; backup named
- [ ] **Listed** in the internal tools catalog (Teams / SharePoint page — see gap-register)
- [ ] **Described** in one sentence that a non-technical colleague would understand

## Access

- [ ] **Azure AD Easy Auth** enabled on the App Service
- [ ] **Group-based access** — users are added to an AD group, not individually; group exists and is documented
- [ ] **Access review** on the quarterly calendar

## Running in prod

- [ ] **Custom URL** in the `internal.company.com` zone (optional but improves discovery)
- [ ] **TLS cert** auto-issued
- [ ] **App Insights** instrumented with at least one alert
- [ ] **Alerts route** to the right channel (gap-register for "which channel")

## Operability

- [ ] `docs/runbook.md` written and accurate
- [ ] `docs/adr/` has at least the initial ADRs
- [ ] `CHANGELOG.md` current — a `1.0.0` entry exists
- [ ] Deploy via CI on green `main` — no manual clicks
- [ ] Rollback command documented and tested at least once

## Data

- [ ] Data classification declared in `.claude/data-classification.yml`
- [ ] Backups enabled and **verified once** by restoring to a scratch DB
- [ ] Retention policy explicit if regulated data is involved

## Users

- [ ] **Users know it exists** — announcement in the right Teams channel
- [ ] **Onboarding flow** inside the app — a first-time user can get to value without being guided
- [ ] **Support path** on the app's help page: "Submit Ivanti ticket type X" or "ask in Teams channel Y"
- [ ] **Feedback mechanism** — at minimum, users know how to complain

## Design

- [ ] Uses the design system (once UX expert has produced it; until then, sensible defaults)
- [ ] No obvious UX clangers — tested with at least one real user outside the build team

## Documentation visible to users

- [ ] A short "what this is and how to use it" page — can live inside the app itself, or in a Teams wiki entry
- [ ] Known limitations noted so users aren't surprised

## Sign-off

- [ ] Product owner: `<name>` on `<YYYY-MM-DD>`
- [ ] Architect: `<name>` on `<YYYY-MM-DD>`

---

> A product is "real" when all of these are true. Before then, it's a prototype or a work-in-progress — fine, but don't oversell it. Internal users resent being beta-testers without being told.

> If a box can't be ticked, either fix it, or add a gap-register entry and get explicit waiver from ARB before treating the product as live.
