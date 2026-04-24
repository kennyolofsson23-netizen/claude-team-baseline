# Next-session handover prompt

> Paste the block below verbatim into a fresh Claude Code session
> (run `claude` in `~/work/claude-team-baseline/`).

---

```
You are continuing work on `claude-team-baseline` — a Claude Code team setup.
Phase 1. NOT yet released. ADO migration is a hard requirement before rollout.

## What is done

- Full Azure DevOps migration (scripts, CI, docs) — placeholders still need real values
- MCPs: Context7, Playwright, Sequential Thinking, Azure MCP in template/.mcp.json
- Superpowers plugin wired into install.sh
- Hooks fixed: PreCommit removed, timeout_ms→timeout, pyyaml router, Stop hook added
- watchfiles + pyyaml in dev deps
- ROLLOUT.md created — single checklist for what's left

## What is needed before rollout (see ROLLOUT.md)

1. ADO org name + project name (user creates in browser, then pastes here)
   → fills <YOUR-ADO-ORG> / <YOUR-ADO-PROJECT> in SETUP.md, go.ps1, bootstrap.ps1
   → git remote set-url to ADO
   → git push to ADO

2. Azure subscription ID (from infra manager)
   → fills AZURE_SUBSCRIPTION_ID in dotfiles/.mcp.json and template/.mcp.json

3. ACR login server (from infra manager)
   → fills <registry.company.internal> in deployer.md, trigger-rules.yml, wiki/stack/deploy.md

4. Teams channel name for alerts + support
   → update runbooks and incident-response.md

5. Clean-machine test + one teammate walkthrough

## Post-rollout (do not touch now)

- Data classification content — per-product
- MSSQL MCP / mssql-tool — first project
- ADO service connection to ACR
- Developer RBAC on Azure

## Rules

- Phase 1 only — no MDM, no managed-settings, no MCP gateway
- Coverage floor 60% — do not raise
- No new agents/skills/hooks/rules without ARB approval (= Kenny)
- Commit after each logical group, push to origin

## Orient yourself

Run ls in repo root, read ROLLOUT.md, then ask:
"Paste the ADO org/project name and the two infra values and I'll wire them all in."
```

---

## How to use

1. `cd ~/work/claude-team-baseline && claude`
2. Paste the block above.
3. Provide ADO org + project name + subscription ID + ACR login server.
4. Claude wires them in, commits, pushes to ADO.
5. Test on clean machine. Walk one teammate through it. Release.
