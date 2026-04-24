# ROADMAP — From Bootstrap to Full Enterprise

This document tracks how the team setup evolves as we grow. Phase 1 is what's built now. Phases 2-4 unlock progressively as the team matures and budget allows.

---

## Phase 1 — Bootstrap (NOW)

**Goal**: Every developer on the team shares the same Claude configuration via a cloned repo + one install script.

**Done**:
- `claude-team-baseline` repo with `.claude/` template, 12 agents, 25 skills, 6 hooks, 7 rules
- Auto-invoke router hook (`auto-invoke-router.py`) fires agents/skills on prompt keywords — no manual selection
- Streamlit + SQLAlchemy + MSSQL scaffold with running smoke test
- `scripts/install.sh` and `scripts/install.ps1` bootstrap a fresh Windows PC
- `scripts/scaffold-project.sh` generates new projects with baseline config
- Team CLAUDE.md written in Claude-as-coach voice for a junior/mid team
- Git-side enforcement: pre-commit (ruff + secret scan) + CI (ruff + pytest + mypy)

**Limits**:
- Each developer logs in with their personal Claude account (no SSO)
- Enforcement is social + CI, not Claude-layer-managed
- No centralized MCP gateway — each dev authenticates MCPs locally
- No audit logging of Claude tool calls
- A determined developer can still bypass by editing their local `~/.claude/`

Phase 1 is appropriate for **a small team (≤8) where trust is high and the architect reviews every PR**.

---

## Phase 2 — Enterprise License + Managed Settings (NEXT)

**Trigger**: Company buys Claude for Enterprise / Team license.

**Work**:
1. Deploy `managed-settings/example.json` (rename → `managed-settings.json`) via MDM (Intune preferred on Windows):
   - `disableBypassPermissionsMode: "disable"` — no `--dangerously-skip-permissions`
   - `allowManagedPermissionRulesOnly: true` — devs cannot widen the allowlist
   - `allowManagedMcpServersOnly: true` + `strictKnownMarketplaces: true`
   - `forceLoginMethod: "claudeai"` + `forceLoginOrgUUID: "<org-uuid>"`
   - Deny list: `Read(**/.env*)`, `Bash(git push origin main)`, `Bash(git push --force*)`, `Bash(npm install react*)`, `Write(**/*.tsx)`
   - Default model pinned to Sonnet, Opus escalation via a gated hook
2. Deploy a PostToolUse audit hook that POSTs tool-call metadata to an internal logging endpoint (Splunk / Datadog / simple PostgreSQL table)
3. Configure branch protection on all repos: CI must pass, architect approval required for CODEOWNERS-flagged paths
4. Migrate all devs from personal Claude accounts to company Enterprise seats

**Owner**: IT + architect, one sprint of work.

**What changes for developers**: nothing visible — they keep using Claude the same way. The guardrails are invisible until someone tries something forbidden.

---

## Phase 3 — MCP Gateway + OAuth Per User (LATER)

**Trigger**: Team grows to ≥10 developers OR first MCP sprawl incident (dev installs something insecure).

**Work**:
1. Stand up an internal MCP gateway service. Options:
   - Self-host a simple FastAPI proxy that holds service-account tokens for each upstream (GitHub, Jira, Sentry, MSSQL) and auths incoming requests via SSO / company token
   - Use a vendor (TrueFoundry, LangWatch, or open-source like `mcp-gateway`)
2. Commit a `.mcp.json` to every repo pointing at the gateway, not at individual MCP servers
3. Remove per-dev MCP auth — devs only auth to the gateway via SSO
4. Log every MCP call at the gateway for audit

**Owner**: Platform / DevOps, 2-3 sprints.

**What changes for developers**: they authenticate to the gateway once at session start. All MCP tools "just work" afterwards.

---

## Phase 4 — Maturity (WHEN TEAM OUTGROWS PHASE 1 CLAUDE.md)

**Trigger**: Team has 10+ devs AND a majority are mid/senior — they stop needing the "coaching voice" CLAUDE.md.

**Work**:
1. Rewrite team CLAUDE.md in senior-engineer voice (shorter, less hand-holding)
2. Add advanced skills we deliberately dropped for juniors:
   - `ddd` (domain-driven design)
   - `sdd` (spec-driven development)
   - `property-based-testing`
   - `composition-patterns` (if we've opened the React escape hatch)
3. Add `SessionStart` hook that whitelists which skills can load — locks down "explore" mode entirely
4. Add custom Semgrep rule library per-project for architectural fitness tests
5. Split `claude-team-baseline` into `claude-team-baseline-core` (shared) + `claude-team-baseline-domain` (team-specific variants)

**Owner**: Architect, ongoing.

---

## Things we deliberately deferred

- **Custom MCP servers for our domain**: premature. Use Context7 + the standard set until we have a repeated pain point that a custom MCP would solve.
- **Opus usage policy**: phase 2 pins Sonnet default. We add Opus escalation only when we see real tasks where Sonnet underperforms.
- **A public "awesome-our-stack" skill library**: nice to have, but we are not a platform team — we are a product team using Claude. Build only what we need.
- **Claude CI agents** (running Claude in GitHub Actions on PRs): valuable later, complex to secure now. Phase 3 or 4.

---

## When to revisit this roadmap

- When we buy the Enterprise license → phase 2 kicks off within a week
- When the team hits 10 people → start planning phase 3
- When the team is majority mid/senior → phase 4
- Annually, regardless: read this doc, adjust based on what actually happened
