# The three layers — how Claude Code knows what to do

Claude Code reads configuration from three distinct layers. Each layer has a different owner, a different lifecycle, and a different blast radius if changed.

## Layer 1 — Managed policy (IT-controlled)

- **Where**: `C:\Program Files\ClaudeCode\managed-settings.json`
- **Who owns it**: IT + architect
- **How it's deployed**: MDM (Intune / Jamf / Group Policy) pushes it to every work PC
- **Who can change it**: IT + architect via PR to `claude-team-baseline/managed-settings/` + redeploy
- **Developers can override it**: **NO.** This is the point of the layer.

### What lives here (PHASE 2 — when Enterprise license is bought)

- Forced login to the company Claude Enterprise account
- `disableBypassPermissionsMode` — prevents `--dangerously-skip-permissions`
- Permission deny-list: secrets, off-stack packages, force pushes to main
- Model pin — everyone defaults to Sonnet
- MCP server allow-list — no malicious MCPs auto-loading from cloned repos
- Audit hook — PostToolUse POSTs to central logging

Today, Phase 1, we do not have this layer active. An example file is in `managed-settings/example.json` for when we roll it out.

## Layer 2 — Project (team-controlled)

- **Where**: `.claude/` inside every project repo
- **Who owns it**: Architect
- **How it's deployed**: Every repo is scaffolded from `claude-team-baseline/template/`, so the baseline `.claude/` goes everywhere
- **Who can change it**: Architect via PR to `claude-team-baseline`
- **Developers can override it**: They can edit locally but should not — changes must be proposed as PRs to the baseline so the whole team gets them.

### What lives here

- `CLAUDE.md` — team rules, written in Claude-as-coach voice
- `settings.json` — project-scoped hooks, permissions, MCP servers
- `agents/` — the 13 agents (architect, coder, tester, reviewer, deployer, etc.)
- `skills/` — the 4 stack skills (python, streamlit, fastapi, mssql best-practices)
- `rules/` — path-scoped rules (auto-load when matching files are touched)
- `hooks/` — `auto-invoke-router.py`, safety hooks, secret scanners

This is where 95% of the team's Claude behavior is defined.

## Layer 3 — Personal (each developer)

- **Where**: `~/.claude/` on your machine
- **Who owns it**: You
- **How it's installed**: `scripts/install.sh` copies `dotfiles/` into `~/.claude/` once
- **Who can change it**: You, on your machine, for your preferences
- **Affects the team**: No — this layer is local to you

### What lives here

- `CLAUDE.md` — your personal prefs (concise responses, specific style preferences)
- `settings.json` — theme, keybindings, personal deny-list (on top of what the team already denies)

### What does NOT live here

- Agents — they live in the project `.claude/`
- Skills — same
- Team rules — same
- Anything that affects what code gets written — same

If you find yourself tempted to edit a rule in `~/.claude/` because it annoys you, **stop**. Open a PR to `claude-team-baseline/template/.claude/rules/` instead. Either the rule is wrong for the whole team (and should be changed), or it's right and you need to internalize it.

## Precedence — which layer wins if there's a conflict?

In order, **most specific wins**:

1. Managed policy (Layer 1) — overrides everything
2. Project `.claude/CLAUDE.md` (Layer 2)
3. Project-local `CLAUDE.local.md` (gitignored personal overrides per-project)
4. Personal `~/.claude/CLAUDE.md` (Layer 3)

Permissions merge across layers. Deny always wins — if any layer denies, the action is blocked.

## The simplest mental model

- **Managed** = "the company says no"
- **Project** = "the team agreed"
- **Personal** = "I prefer"
