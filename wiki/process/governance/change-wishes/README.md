# Change Wishes — how to propose changes to the stack, process, or baseline

This is the place to propose anything that affects more than your own product: new libraries, new processes, changes to rules, new ideas for the baseline.

## How to file one

**Preferred**: open a GitHub issue using the **Change Wish** issue template. It has the right fields and auto-tags the right people.

**Alternative**: copy `TEMPLATE.md` in this directory, fill it in, submit as a PR adding a file at `process/governance/change-wishes/YYYY-MM-DD-<slug>.md`.

Either path lands on the ARB agenda at the next review.

## What happens next

1. ARB sees it on the agenda at their next cadence meeting (≤ 2 weeks typically)
2. ARB reviews and responds with one of: approved, declined, deferred, needs more info
3. If approved → a PR usually follows (by you or the architect)
4. If declined or deferred → a reason is recorded so others know why

## What a good change wish looks like

Short. Concrete. Says what problem it solves — not just what the change is.

Bad: "We should use Redis."
Good: "We need caching for the customer-search endpoint because lookup latency regressed to 2-3s per query and affects the onboarding flow. Redis is the obvious choice because <reasons>. Alternatives considered: in-memory + single replica (rejected because <reason>), App Service in-memory (rejected because <reason>)."

## Archive

Accepted and rejected wishes stay here forever as a record. The files become a history of the team's technical decisions — useful when someone asks "why don't we use X?" three years later.
