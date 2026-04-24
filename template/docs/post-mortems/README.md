# Post-mortems

> One file per incident (S1 or S2). Named `YYYY-MM-DD-<slug>.md`. Template: `process/documentation/post-mortem-template.md` in the baseline.

## Why

Every incident is a chance to make the system a little harder to break. Post-mortems are how we capture the lesson so it outlives the person who learned it.

## When to write one

- **Mandatory**: every S1 and S2 incident, within 7 days
- **Recommended**: S3 that revealed a real gap
- **Skip**: trivial bugs caught immediately, nothing learned

## Blameless

We blame the system, the process, the lack of guardrail. Never the person who pushed the button. The goal is learning; treating post-mortems as performance reviews kills honest reporting.

## Each file contains

See the template for full detail. In short:

- Summary (severity, duration, Ivanti ticket)
- Timeline
- Impact
- Root cause (dig 2-3 "why" levels deep)
- Contributing factors
- What went well
- Action items (tracked, not just text)
- Lessons for the team

## Lifecycle

1. Draft within 3 days of resolution
2. Review with the affected stakeholders
3. Publish here
4. Action items migrate to GitHub issues or Ivanti
5. At the next ARB, the summary is shared so the whole team benefits
