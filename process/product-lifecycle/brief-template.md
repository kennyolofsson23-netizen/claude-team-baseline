# Product Brief — `<product-name>`

> Copy this file to `docs/brief.md` inside your new project, fill in the blanks, and share with the ARB before any code is written. Aim for one page.

## Problem
<What specific problem does this solve? Who feels it today? How do they work around it?>

## Users and goals
<Who uses this? Employees? A specific department? Contractors? What are they actually trying to get done — the job-to-be-done, not the feature list?>

## Success metric
<**One number.** A measurable target that tells us this product is working.>

Example: "HR completes monthly compliance report in under 15 minutes (today: 2 hours)."

## Scope — in / out
**In scope**:
- …
- …

**Out of scope** (deliberately):
- …
- …

## Constraints
- Deadline (if any):
- Budget / infra cost ceiling:
- Data sensitivity class (see `process/data-classification/`): `<employee-standard | restricted-finance | restricted-pii>`
- Regulatory constraints: `<none | GDPR | SOX | other>`

## Stakeholders
| Role | Name | Responsibility |
|---|---|---|
| Product owner | | Accountable for value delivered |
| Architect / ARB | | Signs off on technical approach |
| Builder(s) | | Writes the code |
| Users (primary) | | Use and give feedback |
| UX | | Design-system + UX review |

## Dependencies and risks
- Dependencies (other teams, other systems, Azure resources, external services):
  - …
- Known risks:
  - …

## Decision
- [ ] Approved by ARB on `<YYYY-MM-DD>` — proceed to SPEC.md + ARCHITECTURE.md
- [ ] Deferred — reason:
- [ ] Declined — reason:

---

> Next step after approval: `architect` agent produces `SPEC.md` and `ARCHITECTURE.md` based on this brief. UX expert produces the design-system brief if customer-facing UI is in scope.
