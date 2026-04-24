# Change Approval Matrix

> Who signs off on what. Simple table. Err toward the architect when uncertain.

## The matrix

| Change type | Approver | Mechanism |
|---|---|---|
| Adding a dependency from the approved stack (`uv add <pkg>`) | Project owner | PR review |
| Changing a dependency version (patch or minor) | Project owner | PR review |
| Upgrading a major version of an approved dependency | Architect | PR review, label `stack-change` |
| Adding a **new** library not in `.claude/rules/python.md` approved list | **ARB** | Change-wish issue → ARB review → PR |
| New Azure service (Redis, Service Bus, Blob, etc.) | **ARB** | Change-wish issue → ARB review → update `ARCHITECTURE.md` |
| New SaaS dependency (Stripe, SendGrid, external API that bills) | **ARB** + finance sign-off | Change-wish issue with cost estimate |
| Changing the team `CLAUDE.md`, agents, skills, hooks, rules | **ARB** | PR to `claude-team-baseline` |
| Changing `managed-settings` (Phase 2) | **ARB** + IT | PR to `claude-team-baseline` + MDM redeploy |
| Adding a security deny / allow rule | **ARB** | PR to `claude-team-baseline` |
| Changing the data-classification manifest of a product | **ARB** | PR in product repo |
| Sunsetting a product | **ARB** + product owner | Sunset checklist + ARB sign-off |
| New database schema / table | Project owner | Alembic migration PR |
| Breaking API change in a FastAPI service | Project owner + at least one consumer | PR with consumer checked in comments |
| Deploy to production | Automated via CI on green `main` | No human approval needed per-deploy |
| Emergency hotfix | Architect + one other reviewer | Fast PR, post-hoc ADR within 48h |
| Copy / text changes in internal tools | Project owner | PR review |
| UX / visual changes within the design system | UX expert + project owner | PR review |
| Changes to the **design system itself** | UX expert + ARB | PR to `claude-team-baseline` |

## How to decide when the matrix is ambiguous

- **If it affects multiple products** → ARB
- **If it costs money the team isn't already spending** → ARB
- **If it touches security or data classification** → ARB
- **If it could embarrass the company if it broke** → ARB
- **Anything else** → project owner in the product repo

## What "PR review" means

Standard GitHub Enterprise flow: feature branch → PR → at least one approving review from a repo owner → CI green → squash-merge to `main`.

CODEOWNERS will eventually enforce which files require whose approval. Phase 1, it's honor-system.

## What "ARB review" means

Either:
- Asynchronous: a GitHub issue using the `change-wish` template that the ARB resolves at its next meeting, or within 2 business days if urgent
- Synchronous: the next biweekly ARB meeting, agenda item added in advance

No private-DM approvals. Everything visible to the team.
