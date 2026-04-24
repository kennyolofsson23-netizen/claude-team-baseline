# Rollout Checklist

Everything that must be done before handing this to the team.
Work top to bottom. Do not skip. Do not release the repo URL until this is complete.

---

## BLOCKER — Azure DevOps (hard requirement)

- [ ] **Create ADO organization** — dev.azure.com → New organization
- [ ] **Create ADO project** — inside the org (e.g. `team-tools`)
- [ ] **Import repo from GitHub** — ADO → Repos → Import → `https://github.com/kennyolofsson23-netizen/claude-team-baseline`
- [ ] **Create Pipeline** — ADO → Pipelines → New → point at `azure-pipelines.yml`
- [ ] **Set branch policies on main** — require PR + CI pass + 1 approver (you)
- [ ] **Create PAT** — User settings → Personal Access Tokens → Code Read scope
- [ ] **Fill ADO placeholders** — paste org + project name and run:
  ```bash
  # Claude does this once you give the values
  # Replaces <YOUR-ADO-ORG> and <YOUR-ADO-PROJECT> in:
  #   SETUP.md, scripts/go.ps1, scripts/bootstrap.ps1
  ```
- [ ] **Point git remote to ADO**:
  ```bash
  git remote set-url origin https://dev.azure.com/<ORG>/<PROJECT>/_git/claude-team-baseline
  git push
  ```

---

## BLOCKER — Azure infra values

- [ ] **Subscription ID** → fills `AZURE_SUBSCRIPTION_ID` in `dotfiles/.mcp.json` and `template/.mcp.json`
- [ ] **ACR login server** → fills `<registry.company.internal>` in:
  - `template/.claude/agents/deployer.md`
  - `template/.claude/hooks/trigger-rules.yml`
  - `wiki/stack/deploy.md`

---

## BLOCKER — Validation

- [ ] **Test the full install on one clean Windows PC** (not your dev machine)
  - Run `go.ps1` end to end
  - Confirm wiki opens at `http://localhost:7777`
  - Confirm `claude --version`, `uv --version`, `az --version` all work
  - Confirm MCP trust prompt appears and MCPs load
  - Scaffold a hello-claude project and run the smoke test
- [ ] **Walk one teammate through HANDOVER.md** — find the gaps before 9 others do

---

## AFTER rollout (do not block on these)

- Data classification content — per-product at launch
- MSSQL MCP / mssql-tool — first project
- ADO service connection to ACR — when first deploy happens
- Developer RBAC on Azure (Reader + Monitoring Reader + AcrPull) — when ADO is live
- Enterprise Claude license + managed-settings — Phase 2

---

## Hand-off message (send this once all boxes are checked)

> Hey team — Claude Code is ready. Run this in PowerShell as Administrator on your work PC:
>
> ```powershell
> $pat = "<PAT>"
> $headers = @{ Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat")) }
> irm -Uri "https://dev.azure.com/<ORG>/<PROJECT>/_apis/git/repositories/claude-team-baseline/items?path=/scripts/go.ps1&api-version=7.0&download=true" -Headers $headers | iex
> ```
>
> Takes ~10 minutes. After it finishes: `az login`, then `claude`.
> Questions → [Teams channel].
