# Patch SLA — CVEs and Security Advisories

> When a CVE drops on something we use, how fast do we patch?

## Severity → deadline

| Severity (CVSS) | Deadline from disclosure | Process |
|---|---|---|
| **Critical** (9.0-10.0) | **48 hours** | Emergency patch; interrupt current work if needed |
| **High** (7.0-8.9) | **7 days** | Priority in next deploy |
| **Medium** (4.0-6.9) | **30 days** | Scheduled in normal sprint cadence |
| **Low** (0.1-3.9) | Best effort | Bundle with other updates |
| **Informational** | No SLA | Awareness only |

## Where alerts come from

- **Dependabot security alerts** — the main channel for library CVEs in our projects
- **Azure Security Center / Defender for Cloud** — infra-level CVEs (base images, Azure services)
- **GitHub Security Advisory Database** — general awareness feed
- **Microsoft Security Response Center (MSRC)** — Windows / .NET / SQL Server advisories

Subscribe these to the Teams channel for security (once we pick one — see gap-register).

## The 48-hour Critical flow

1. **Alert fires** — Dependabot PR with Critical label, or manual notice from Azure / MSRC
2. **Triage within 4 hours** — is our app actually affected? Does the vulnerable code path run?
3. **If affected**: assign an owner, drop other work, patch + test + deploy same-day-ish
4. **If not affected**: document why in a short ADR or a comment on the Dependabot PR; still schedule the patch in normal flow
5. **Within 48 hours**: either deployed the patch or explicit risk acceptance by ARB (rare)

## The 7-day High flow

1. Alert fires
2. Owner assigned at the next standup or within 24 hours
3. Patch planned, tested, deployed inside 7 days
4. Post-deploy: note in `CHANGELOG.md` that the patch was applied

## What "patch" actually means

Usually: a `uv add package==<new-version>` followed by `uv sync`, tests, CI, deploy.
Sometimes: workaround (disable the feature, add input validation) while waiting for an upstream fix.
Rarely: rollback to a known-good version while investigating.

## Recording

Every security patch gets:

- A merged PR (normal CI flow)
- A `CHANGELOG.md` entry under `## Security` ([Keep-a-Changelog format](https://keepachangelog.com))
- If it was a Critical with incident flow: a short post-mortem in `docs/post-mortems/`

## No-fix situations

Sometimes there's no patch available and the fix needs to be upstream. If we cannot patch within the SLA:

- Document the compensating control (input validation, rate limit, network restriction)
- ARB signs off on the acceptance
- Re-evaluate weekly until patched

## What this doesn't cover

- **Zero-days** — the SLA starts when disclosure happens, not when exploitation is detected. If we see suspicious activity before disclosure, that's an incident (see `incident-response.md`), not a patch cycle.
- **Non-security bugs** — normal bug-fix cadence. No SLA.
- **Azure platform CVEs** — Microsoft patches; we just need to accept the restart window when they call it.
