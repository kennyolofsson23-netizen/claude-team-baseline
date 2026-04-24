# Managed settings (Phase 2)

This is the layer we turn on when the company buys a Claude for Enterprise / Team license. Until then, `managed-settings/example.json` sits in the repo as a ready-to-deploy template.

## What it is

A single JSON file at `C:\Program Files\ClaudeCode\managed-settings.json` (Windows), deployed via MDM (Intune, Jamf, or Group Policy). Once deployed, it:

- **Overrides every other settings layer** — personal `~/.claude/`, project `.claude/`, environment variables all lose to it
- **Cannot be bypassed by the developer** — `--dangerously-skip-permissions` stops working
- **Survives reinstalls** — even if a dev reinstalls Claude Code, the MDM pushes this back

## What lives in it

### Authentication
- **`forceLoginMethod: "claudeai"`** — no API key logins, only Claude.ai accounts
- **`forceLoginOrgUUID`** — pins the login to the company's Enterprise org; personal Pro/Max accounts stop working

### Bypass prevention
- **`disableBypassPermissionsMode: "disable"`** — this is the most important flag. Without it, any dev can run `claude --dangerously-skip-permissions` and void every other control.
- **`allowManagedPermissionRulesOnly: true`** — devs cannot add to the allow-list locally. All approved commands come from managed.

### MCP control
- **`allowManagedMcpServersOnly: true`** — no developer-installed MCPs
- **`strictKnownMarketplaces: true`** — no rogue marketplaces. Protects against CVE-2025-59536 (malicious `.mcp.json` in cloned repos auto-loading).

### Model
- **`model: "claude-sonnet-4-6"`** — default everyone to Sonnet. Devs can request Opus for specific tasks but have to opt in manually.

### Deny list (security)
- Read: `.env*`, `secrets/`, `.ssh/`, private keys, PFX certs
- Bash: force pushes, pushes to main/master, all off-stack npm installs
- Write: `.tsx`, `.jsx`, `.vue`, `.svelte`, `package.json`, `package-lock.json`, `pnpm-lock.yaml`

### Audit
- **PostToolUse HTTP hook** — every tool call Claude makes is POSTed to an internal logging endpoint. Timeout 5s so a slow audit service never blocks developers. The log captures: tool name, input, outcome, timestamp, user.

## Deployment steps (when we buy the license)

1. **Enterprise onboarding** — IT sets up the Claude for Enterprise account, gets the org UUID
2. **Edit the file** — replace `<REPLACE_WITH_ENTERPRISE_ORG_UUID>` and `<audit-endpoint-internal>` with real values
3. **Rename** — `managed-settings/example.json` → `managed-settings/managed-settings.json`
4. **Deploy via MDM** — Intune preferred on Windows. File deploys to `C:\Program Files\ClaudeCode\managed-settings.json`
5. **Migrate developers** — they log out of their personal Claude accounts and log in with the Enterprise account
6. **Verify** — try `claude --dangerously-skip-permissions` on a test machine. It should refuse.

## What does NOT belong in managed settings

- Project-specific rules → those live in `template/.claude/`
- Personal preferences → those live in `dotfiles/`
- Secret values → managed-settings is plain JSON on disk; treat it as public-within-company

## Risks and mitigations

- **Dev needs a forbidden tool for a legit reason** → open a PR to `claude-team-baseline/managed-settings/` proposing the allow-list entry. Architect reviews, IT redeploys.
- **MDM push fails on a specific machine** → IT sees it in MDM's compliance report. Until fixed, that machine has no managed layer — the project + personal layers still apply.
- **Audit endpoint down** → hooks time out at 5s, session continues. Lose the log for that window but don't block devs.
- **Dev is not on the company network (WFH)** → managed settings file is on disk, still works. Audit hook POSTs fail silently until back on VPN (OK for eventual consistency).
