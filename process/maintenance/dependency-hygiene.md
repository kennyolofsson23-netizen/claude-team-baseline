# Dependency Hygiene

> Dependabot opens PRs. Someone has to triage them or they pile up.

## Setup — per project

In `.github/dependabot.yml` of every project:

```yaml
version: 2
updates:
  - package-ecosystem: "uv"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 5
    reviewers:
      - "<your-github-team-or-username>"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 3

  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "monthly"
```

> As of this writing, GitHub Dependabot supports `pip` and emerging support for `uv`. If `uv` isn't supported yet on your org's GitHub Enterprise, use `pip` pointing at `pyproject.toml` — uv + pip share the same manifest.

This is added to the scaffold in a follow-up — track via gap-register if still missing.

## Weekly triage — per project owner

Monday morning, 10 minutes per project:

1. Open the Dependabot-authored PRs for your project
2. For each one, decide:

| Decision | Criteria | Action |
|---|---|---|
| **Approve and merge** | Patch or minor version, no breaking change noted, CI green | Click merge |
| **Defer 1 week** | Unclear, or you're mid-feature and can't test | Add the `dependabot-defer` label, come back next Monday |
| **Approve after testing** | Major version, breaking changes | Run local test, merge if good; file a change-wish if it needs wider discussion |
| **Reject / close** | Dependency you no longer need | Close PR with comment, `uv remove` the dep in a follow-up |

3. If any Dependabot PR has been deferred 3+ weeks, it graduates to an ARB change-wish.

## What's auto-approved

Nothing. All Dependabot PRs require a human click. Automation risks too much — a broken patch version isn't supposed to happen, but it does.

## Security patches take precedence

If a Dependabot PR has a `security` label (Dependabot adds this for CVEs), it jumps the queue. Follow the SLA in `patch-sla.md`.

## What to do if Dependabot bundles 20 PRs at once

Rare, but happens after a long vacation or after a big upstream release. Approach:

1. Sort by severity: security first, then patch versions, then minor, then major
2. Batch-merge the patches if CI stays green across all of them
3. For minors, pair it with quick test runs
4. Majors get individual attention

Don't close them all in a panic — each is a small bug or vulnerability you're about to ignore.

## Cross-project dependency decisions

If 3+ projects pin the same library version, an upgrade is an ARB-worthy decision. File a change-wish so the whole team moves together.
