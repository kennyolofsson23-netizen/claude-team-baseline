# ADR-0000: Record Architecture Decisions

## Status

Accepted

## Context

This project is scaffolded from `claude-team-baseline` and inherits the convention of recording significant architectural decisions as Architecture Decision Records (ADRs).

Software decisions live forever in the codebase. Without a record of **why**, future engineers (including future-you) must reverse-engineer the reasoning from scattered commits. ADRs capture the context and trade-offs at the time the decision was made.

## Decision

We will record all significant technical decisions as ADRs in this directory (`docs/adr/`).

- Each ADR is a separate, numbered Markdown file: `NNNN-<slug>.md`
- Numbers are sequential (0000, 0001, 0002, …)
- ADRs are immutable after acceptance; to change a decision, write a new ADR that supersedes the old one
- Use the template at `process/documentation/adr-template.md` in the baseline repo as the starting point

## Consequences

**Positive:**
- Future engineers can understand why the system is the way it is
- Decisions become reviewable artefacts — visible in PRs like any code change
- Patterns emerge over time, which can be graduated into team-wide rules

**Negative:**
- Slight overhead per decision (5-10 minutes to write a good ADR)
- Requires discipline — skipping ADRs erodes their value
