# Sunset Checklist — Retiring an Internal Product

> Use when a product is no longer needed. The goal is: no users surprised, no data lost, no infra bills leaking.

## Decision
- [ ] Sunset proposed and approved by ARB — decision recorded in this file
- [ ] Replacement (if any) identified: `<other product or manual process>`
- [ ] Final date agreed: `<YYYY-MM-DD>`
- [ ] Communication plan drafted (who to tell, when)

## User communication
- [ ] First notice to users ≥ 30 days before final date (Teams announcement + email)
- [ ] Reminder at 7 days
- [ ] Final-day banner in the app itself ("this tool is being retired today, use X going forward")
- [ ] Internal tools catalog updated to reflect deprecated status

## Data
- [ ] Data export / archive plan — where does the data go, in what format?
- [ ] Archive completed and verified readable
- [ ] Retention requirements satisfied (if regulated data, retain per policy; if not, delete)
- [ ] Anyone with lingering access notified

## Infra teardown
- [ ] DNS / custom domain unmapped
- [ ] App Service stopped, then deleted
- [ ] Container image kept in ACR for 6 months (rollback window), then deleted
- [ ] Key Vault secrets rotated out / deleted
- [ ] MSSQL database backed up, then deleted (if dedicated) or schema dropped (if shared)
- [ ] App Insights / alerts disabled
- [ ] Resource group deleted (last — confirms nothing orphaned)

## Code
- [ ] Repository archived in GitHub (not deleted — preserves history)
- [ ] `README.md` updated with "⚠ RETIRED — see <replacement>" banner
- [ ] `CHANGELOG.md` final entry: "v<last> — Retired on <date>"
- [ ] `docs/runbook.md` updated with retirement context

## Governance
- [ ] Final post-mortem written — what worked, what didn't, lessons for the next product
- [ ] Owner and stakeholders released (so they aren't accidentally paged for an extinct tool)
- [ ] `process/gap-register.md` updated if sunset reveals a wider gap

## Sign-off
- [ ] Product owner: `<name>` on `<YYYY-MM-DD>`
- [ ] Architect: `<name>` on `<YYYY-MM-DD>`

---

> Sunset is boring when done right. The goal is "nobody noticed, and the bill went down." Rushing a sunset is how you lose data or orphan infra.
