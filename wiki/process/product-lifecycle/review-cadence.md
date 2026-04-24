# Product Review Cadence

> How often do we look at a product and ask "is this still worth running?"

## Why this exists

Internal products decay. Users leave the team that asked for it. The problem it solved changes. Nobody noticed it hasn't been touched in a year. The Azure bill keeps arriving.

A regular cadence forces the conversation.

## Cadence

### Monthly — by product owner
- Look at App Insights: active users, error rate, top complaints
- Are the success metrics from `docs/brief.md` being met?
- Any change-wishes pending for this product?
- Anything blocking next sprint?

Output: 3-5 bullet update in the internal tools catalog entry.

### Quarterly — ARB
- Review every live product briefly
- Decide for each: **double down**, **maintain**, or **sunset**
- Check cost against value delivered
- Approve or defer any major changes requested in the change-wish register

Output: entry in `docs/adr/` of the relevant product if a direction change was decided.

### Annually — full review
- Re-read the product brief — is the problem statement still correct?
- Are the users still the intended users? Have they moved on?
- Is the tech stack still appropriate? Any debt worth paying down?
- Could this be retired and the work done another way?

Output: either a renewed brief (same problem, updated goals) or a sunset entry in `process/product-lifecycle/sunset-checklist.md`.

## What to watch for

- **Product with no monthly activity** → candidate for sunset, or it's working so well nobody has to touch it. Ask the users.
- **Product with steadily rising cost per user** → investigate. Usually a data-growth problem.
- **Product in maintenance for 6+ months with no feature changes** → fine, but check the dependencies are still getting patched.
- **Product the product owner no longer remembers** → sunset candidate.

## Link to the engineering cadence

Engineering cadence (in `process/maintenance/calendar.md`) is about **keeping products running**. Product cadence (this doc) is about **deciding which products to keep running**. Both happen; don't confuse them.
