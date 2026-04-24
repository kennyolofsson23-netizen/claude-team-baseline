# Post-Mortem — `<short incident title>`

> Copy to `docs/post-mortems/YYYY-MM-DD-<slug>.md` in the product repo. Due within 7 days of incident resolution.

## Summary

- **Date**: `<YYYY-MM-DD>`
- **Severity**: `<S1 | S2 | S3>`
- **Duration**: `<start time> → <end time>` (`<total impact time>`)
- **Ivanti ticket**: `<ID>`
- **Author**: `<name>`

<Two sentences. What broke, for whom, for how long.>

## Timeline

<Time-stamped bullets. Include what was noticed, what was tried, what worked. Be honest; this is for learning, not for optics.>

- **HH:MM** — First signal (alert, user report, etc.)
- **HH:MM** — Triage began
- **HH:MM** — Mitigation action taken: `<what>`
- **HH:MM** — Confirmed impact stopped
- **HH:MM** — Root cause identified
- **HH:MM** — Permanent fix deployed
- **HH:MM** — Incident closed

## Impact

- **Users affected**: `<count or approximation>`
- **Data impact**: `<none | data lost | data delayed | data exposed>`
- **Financial impact**: `<if any>`
- **Trust impact**: `<internal perception — honest>`

## Root cause

<The technical cause. Often not the first thing blamed. Dig one or two "why" levels deeper than the surface.>

Example:
- Surface: "Deploy broke because migration failed"
- Deeper: "Migration failed because the new Alembic revision referenced a column name that no longer existed, after a refactor two PRs earlier"
- Root: "Alembic's autogenerate was run against a stale local DB, and CI doesn't run integration tests against the migrated DB"

## Contributing factors

<What made the incident worse or last longer? Every contributing factor is a gap worth fixing.>

- Missing monitoring on `<thing>`
- Runbook section `<section>` was out of date
- Alert didn't fire because threshold was set during a quieter period
- …

## What went well

<Don't skip this. The things that went right tell you what to protect.>

- Alert fired within 2 minutes
- Rollback path worked first try
- Team communication was clear in the Teams thread

## Action items

<Concrete, assigned, tracked. Each one goes into GitHub Issues or Ivanti after this post-mortem is published. "Be more careful" is not an action item.>

| Action | Owner | Due | Tracked |
|---|---|---|---|
| Add integration test that runs Alembic migrations in CI | `<name>` | `<date>` | `<issue URL>` |
| Update runbook section "Common incidents / migrations" | `<name>` | `<date>` | `<issue URL>` |
| Raise change-wish for a staging environment that mirrors prod schema | `<name>` | `<date>` | `<issue URL>` |

## Lessons for the team

<What should every other project owner take from this? These graduate into the `tasks/lessons.md` of the team baseline if they are general.>

- …
- …

## Blameless statement

<One paragraph affirming that this post-mortem is focused on system and process gaps, not on individuals. Example: "The deploy that triggered this incident was the right action at the time given the information available. The gap is in our CI not catching migration issues, not in the person who ran the deploy.">
