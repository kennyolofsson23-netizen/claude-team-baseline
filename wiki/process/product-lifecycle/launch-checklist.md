# Launch Checklist — Internal Product

> Copy this file to `docs/launch-checklist.md` when you're within a week of going live. Tick each box. A product launches when every box is ticked and the ARB has signed off.

## Engineering
- [ ] All acceptance criteria in `SPEC.md` are met and covered by tests
- [ ] `uv run ruff check`, `uv run mypy`, `uv run pytest --cov` all pass in CI
- [ ] Coverage ≥ 80%
- [ ] `docs/runbook.md` written and readable by someone who didn't build the product
- [ ] `docs/adr/` has at least one ADR for the core technical choice
- [ ] `CHANGELOG.md` has a `1.0.0` entry
- [ ] Dockerfile builds and the container starts cleanly from a fresh clone

## Infrastructure
- [ ] App Service deployed in the correct resource group
- [ ] MSSQL database provisioned (or existing DB migration applied)
- [ ] Alembic migrations applied to prod via CI, not manually
- [ ] Key Vault holds all secrets; `.env` is only for local dev
- [ ] Custom domain (if any) mapped; TLS cert issued
- [ ] App Insights instrumented; at least one alert configured (e.g. error rate > 5%)
- [ ] Azure AD Easy Auth enabled; only the intended user groups have access

## Data
- [ ] Data classification declared in `.claude/data-classification.yml`
- [ ] Backup strategy in place (Azure SQL automated backups enabled, tested restore once)
- [ ] Retention policy documented if regulated data is involved
- [ ] No PII in logs (App Insights sampling or redaction rules if needed)

## Governance
- [ ] Product brief approved by ARB
- [ ] Security review triggers checked (see `process/governance/security-review-triggers.md`) — triggered if applicable
- [ ] Any change-wishes that blocked launch are resolved
- [ ] Ownership assigned — a **named person** owns incidents for this product

## User readiness
- [ ] Listed in the internal tools catalog (Teams / SharePoint page)
- [ ] Users know it exists — announcement in the right channel
- [ ] Support path documented — "if this breaks, submit Ivanti ticket type X" or "message channel Y"
- [ ] User docs exist (`docs/user/` or a Teams wiki page — scale to product complexity)
- [ ] First-time user experience tested with at least one real user outside the build team

## Monitoring & on-call
- [ ] App Insights alerts route to the right Teams channel (or email)
- [ ] Someone knows they're the first responder for this product
- [ ] Incident runbook section filled in (`docs/runbook.md` → "When X happens, do Y")

## Sign-off
- [ ] Product owner: `<name>` on `<YYYY-MM-DD>`
- [ ] Architect: `<name>` on `<YYYY-MM-DD>`

---

> If any box is unticked at sign-off time, either (a) tick it, or (b) raise a gap-register entry and get ARB to formally waive it before launching.
