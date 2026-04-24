# Incident Response

> Something's broken. This is the flow for getting back to green.

## What counts as an incident

- An app is down or significantly degraded
- Data loss or data corruption
- Security breach or suspected breach
- A fix deployed yesterday is producing wrong results

Not an incident: normal bug report, feature request, slow but working.

## The flow

```
Detect  →  Triage  →  Ivanti ticket  →  Mitigate  →  Resolve  →  Post-mortem
```

### 1. Detect

Detection channels:
- App Insights alert → Teams channel (our main feed — see gap-register for the channel TBD)
- User report → Ivanti ticket, or DM / email to product owner
- Proactive spot by owner during a glance

### 2. Triage — within 15 minutes

- **Severity**: S1 (app down, data at risk) · S2 (major feature broken) · S3 (minor feature broken, workaround exists)
- **Scope**: who's affected, how many users, since when
- **Is data at risk?** If yes, jump to mitigation fast

### 3. Open an Ivanti ticket

Ivanti Service Manager is the source of truth for incidents.

- Title: `<product> — <short description>`
- Category: Incident (not Service Request)
- Severity: as above
- Initial comment: what's broken, what's the blast radius, who's working on it
- Add the Ivanti ticket ID to the Teams thread and any PR related to the fix

### 4. Mitigate — stop the bleeding

Prioritise **stopping the impact**, not finding the root cause. Options:

- Roll back the last deploy (`az webapp config container set --docker-custom-image-name <previous>`)
- Disable a feature via feature flag
- Scale out the App Service if it's capacity
- Restart the App Service (`az webapp restart`) — a restart fixes 30% of incidents, shame on us sometimes
- Restore from backup (last resort; see runbook for each product)

Record what you did in the Ivanti ticket.

### 5. Resolve

- Fix deployed, verified working
- Confirm no data still-being-corrupted
- Update Ivanti ticket: Resolved, with summary of fix
- Communicate to affected users (Teams announcement if broad impact)

### 6. Post-mortem — within 7 days

Every S1 and S2 gets a post-mortem. See `process/documentation/post-mortem-template.md`.

Blameless. We blame the system, the process, or the lack of guardrail — never the person who pushed the button. The goal is **learning**, not punishment.

Output: a file in `docs/post-mortems/YYYY-MM-DD-<slug>.md`, plus any action items added to the issue tracker.

## Severity response times (soft SLAs — Phase 1)

| Severity | Acknowledge | Mitigate | Resolve |
|---|---|---|---|
| S1 | 15 min | 1 hour | 4 hours |
| S2 | 1 hour | 4 hours | 1 business day |
| S3 | 1 business day | 3 business days | next sprint |

Phase 1 is business-hours only. 24/7 coverage is a gap-register entry.

## On-call

No on-call rotation yet. The **product owner is the de-facto first responder** for their product during business hours. Outside business hours: the system waits until morning.

If a product's impact warrants 24/7 coverage, that's a gap-register entry and a product-specific investment, not a team default.

## After an incident

- Any action items from the post-mortem are tracked in GitHub issues or Ivanti, not just in the post-mortem text
- If the incident revealed a broader gap → add to `process/gap-register.md`
- If the incident revealed a baseline improvement → change-wish PR

## What NOT to do

- Don't ignore a recurring symptom because "it usually goes away" — that's a pattern worth a post-mortem on its own
- Don't fix production without a PR — no `ssh in and edit` even under pressure. Create a hotfix branch, PR, merge, deploy, always
- Don't skip the Ivanti ticket because "it's small" — five small un-ticketed incidents become an unexplainable pattern six months later
- Don't blame the person. Blame the gap that let the person make the mistake.
