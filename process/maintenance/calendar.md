# Maintenance Calendar

> What happens on what cadence. Pinned to the wiki so it's always findable.

## The lean version (use this for the first 3 months)

Only two cadences while we find our rhythm:

| When | Task | Who |
|---|---|---|
| **Weekly (Monday, 10 min)** | Dependabot triage — approve patches, defer anything unclear | Each project owner |
| **Quarterly (2h block)** | Everything else — backup restore, access review, cost check, runbook freshness, ARB product review, gap-register walk-through | ARB + project owners together |

Event-driven things (CVE, incident, change-wish) still happen whenever triggered.

The detailed cadence below is the **target** once we have 3+ live products and a rhythm. Don't try to run everything weekly from day one.

---

## Full cadence (target state, month 4+)

## Weekly

| Task | Who | What |
|---|---|---|
| **Dependabot triage** | Each project owner | Review Dependabot PRs for your projects — approve, defer, or reject with reason. See `dependency-hygiene.md`. |
| **App Insights glance** | Each project owner | 5-minute look at error rate, active users, any anomalies. Act on obvious problems, note the rest. |
| **Ivanti queue scan** | Project owners for their products | Any open tickets against your product? Assign, triage, close. |

## Monthly

| Task | Who | What |
|---|---|---|
| **Backup verification** | Per-product owner | Restore latest backup to a scratch DB, run a smoke query, confirm data is readable. Log result in runbook. See `backup-verification.md`. |
| **Azure cost review** | Kenny | Per-resource-group cost report. Any unexpected spend? Any resources that could be downsized / deleted? |
| **Product metrics review** | Each product owner | 3-5 bullets for the product entry in the internal tools catalog. |
| **Security advisory scan** | Kenny (IT later) | Check Azure Security Center + Dependabot alerts. Triage any Critical / High. See `patch-sla.md`. |

## Quarterly

| Task | Who | What |
|---|---|---|
| **Access review** | Kenny + IT | For each product: who has access via Azure AD? Is it still correct? Revoke the unused. See `access-review.md`. |
| **ARB product review** | ARB | For each live product: double down, maintain, or sunset? |
| **Certificate audit** | IT | Most Azure certs auto-rotate. Audit the exceptions. |
| **Runbook freshness** | Project owners | Re-read `docs/runbook.md` for your product — still accurate? Deploy command still works? |
| **Gap register review** | ARB | Walk through the gap-register; promote, close, or re-park each entry. |

## Annually

| Task | Who | What |
|---|---|---|
| **Product brief re-read** | ARB + product owners | Is the problem still the problem? Users still the users? Renew or sunset. |
| **Security audit sweep** | Kenny / IT | Run security audit against all live products, not just PR diffs. |
| **Stack review** | ARB | Is Python / Streamlit / FastAPI / MSSQL still the right stack? What changed in the ecosystem? |
| **Roadmap review** | Kenny / ARB | Phase 2 / 3 from the roadmap — have triggers fired? Update planning. |

## Event-driven (no fixed cadence — do when triggered)

| Trigger | Task |
|---|---|
| New CVE announced for a dep we use | Patch per `patch-sla.md` (Critical 48h, High 7d, Medium 30d) |
| Incident | Follow `incident-response.md`; write post-mortem within 7 days |
| Change-wish approved | Architect opens PR or assigns it |
| New regulated data class identified | Update `.claude/data-classification.yml`; ARB reviews |
| App Insights alert fires | Triage per product runbook; escalate if needed |

---

## Templates for each task

Every recurring task has a **template in `maintenance/`** showing what to do, what to check, and where to log results. If a template is missing or stale, open a PR to `claude-team-baseline`.

## What we consciously don't do (yet)

- **24/7 on-call rotation** — internal tools, business hours; gap-register entry for when needed.
- **Automated change failures dashboard** — we rely on App Insights alerts for now.
- **Automated compliance scans (SOC 2, ISO)** — not required for internal-only; gap-register if that changes.
