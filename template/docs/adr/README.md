# Architecture Decision Records

> One file per decision. Numbered sequentially. See `0000-record-architecture-decisions.md` for the convention.

## Not every change needs an ADR

ADRs are **as-needed, not mandatory per feature**. Write one only when:
- You picked a library, framework or pattern that will outlast a sprint
- You made a trade-off someone in 6 months will question
- A decision is subtle enough that "read the commit history" won't explain it

If in doubt, skip it. Three great ADRs beat twenty noisy ones.

## When to write one

- Picked a library / framework / pattern that will affect several files
- Made a trade-off between competing concerns
- Deviated from the baseline or the normal way of doing something
- Someone in the future will ask "why did we do it this way?"

## How to write one

1. Find the highest existing number in this directory. Add one.
2. Copy the template from `process/documentation/adr-template.md` in the baseline.
3. Write it as a PR — the ADR is reviewed like any other change.
4. Merge. It's now a permanent part of the project's history.

## Status values

- `proposed` — under discussion
- `accepted` — decided and in effect
- `deprecated` — no longer in effect
- `superseded-by-ADR-NNNN` — replaced by a later decision

## Keep them short

Most good ADRs are 1 page. If yours is longer, either the decision is too big (split it) or you're writing background material that belongs in SPEC.md or ARCHITECTURE.md.
