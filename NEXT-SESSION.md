# Next-session handover prompt

> Paste the block below verbatim into a fresh Claude Code session
> (run `claude` in `~/work/claude-team-baseline/`).

---

```
You are continuing work on `claude-team-baseline` — a Claude Code team setup.
It is NOT yet released to the team of 10 IT people. Phase 1 only.

## What was done in the last session

- Migrated all GitHub references to Azure DevOps (scripts, docs, CI pipeline)
- Replaced GitHub Actions with `template/azure-pipelines.yml`
- Fixed wiki counts to match reality: 12 agents, 4 skills, 8 hooks, 7 rules
- Fixed coverage floor to 60% in deployer.md (was 80%)
- Applied Azure CAF naming in deployer.md and wiki/stack/deploy.md:
    APP_NAME = app-<project>-<env>
    RG_NAME  = rg-<project>-<env>
    URL      = https://${APP_NAME}.azurewebsites.net  (derived, no separate placeholder)
- .deploy/config.env pattern documented for per-project names

## What is still outstanding (do these in order)

1. ACR login server — paste from infra-manager session.
   Replace <registry.company.internal> in:
     - template/.claude/agents/deployer.md
     - template/.claude/hooks/trigger-rules.yml
     - wiki/stack/deploy.md

2. ADO org + project name — paste from the ADO browser setup.
   Replace <YOUR-ADO-ORG> and <YOUR-ADO-PROJECT> in:
     - SETUP.md
     - scripts/go.ps1
     - scripts/bootstrap.ps1

3. Point git remote to ADO once the repo is imported there:
     git remote set-url origin https://dev.azure.com/<ORG>/<PROJECT>/_git/claude-team-baseline
     git push

4. Update gap-register.md — move any gaps resolved by infra wiring to Resolved section.

## Rules (do not deviate)

- Phase 1 only — no MDM, no managed-settings, no MCP gateway
- Coverage floor is 60% — do not raise it
- No new agents/skills/hooks/rules without ARB approval (= ask Kenny)
- Do not release repo URL to team yet
- Commit after each logical group, push to origin/main
- Conventional commits, max 72 chars subject

## Orient yourself first

Run ls in repo root, confirm structure, then read:
  SETUP.md / README.md / ROADMAP.md / process/gap-register.md

Then ask: "Paste the ACR login server and ADO org/project name and I'll wire them in."
```

---

## How to use this

1. `cd ~/work/claude-team-baseline && claude`
2. Paste the block above into the new session.
3. Provide ACR login server + ADO org/project name.
4. Claude wires them in, commits, pushes.
5. Once green — scaffold a first real product to test the baseline end-to-end.
