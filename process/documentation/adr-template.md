# ADR-`<NNNN>`: `<title>`

> Copy this file to `docs/adr/NNNN-<slug>.md` inside your project, number it sequentially (`0001-…`, `0002-…`), fill in the sections.
> An ADR captures one technical decision that outlasts the sprint it was made in. Keep it short — most ADRs are a page.

## Status

`<proposed | accepted | superseded-by-ADR-XXXX | deprecated>`

## Context

<What's the situation that forced a decision? What constraints are in play? What were we not able to do before? What problem does this solve?>

## Decision

<What did we decide? One or two sentences, clear.>

## Alternatives considered

<At minimum two alternatives with one-line reasons for rejection. Skipping this section is how you end up with "why did we pick X?" arguments six months later.>

1. **Option A**: …
   Rejected because: …

2. **Option B**: …
   Rejected because: …

## Consequences

**Positive**:
- …

**Negative**:
- …

**Follow-up**:
- <Any work this decision creates — new ADR, change-wish, gap entry>

---

## When to write an ADR

- You picked a library / framework / pattern that will affect several files
- You made a trade-off between competing concerns (performance vs simplicity, etc.)
- You deviated from the baseline or the normal way of doing something
- Someone in the future will ask "why did we do it this way?"

## When NOT to write an ADR

- Implementing a single feature the normal way
- Renaming something
- Fixing a bug
- Any decision that only affects one file and one day

If you're unsure, err toward writing one — five minutes of ADR now saves an hour of archaeology later.

## Where the number comes from

Sequential in the project. Check `docs/adr/` for the highest number, add one.
The first ADR in every project should be `0000-record-architecture-decisions.md` — declaring that this project uses ADRs.
