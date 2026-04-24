# SETUP — get going on your work PC

> **Dead-simple path first.** Detailed steps below if anything breaks.

## The one-liner (Windows, PowerShell as Administrator)

```powershell
$pat = "<YOUR-ADO-PAT>"
$headers = @{ Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat")) }
irm -Uri "https://dev.azure.com/<YOUR-ADO-ORG>/<YOUR-ADO-PROJECT>/_apis/git/repositories/claude-team-baseline/items?path=/scripts/go.ps1&api-version=7.0&download=true" -Headers $headers | iex
```

Replace `<YOUR-ADO-ORG>`, `<YOUR-ADO-PROJECT>`, and `<YOUR-ADO-PAT>` (a Personal Access Token with Code Read scope). The script:

1. Installs Git, Azure CLI, Node.js, Python 3.12, Claude Code, uv, Docker Desktop, VS Code, and the MSSQL ODBC driver (via winget, ~10 minutes)
2. Pops a browser for Azure login (`az login`)
3. Pops a browser for Claude login
4. Clones this repo to `~/work/claude-team-baseline`
5. Copies the personal Claude config to `~/.claude/`
6. Opens the wiki in your default browser (http://localhost:7777)
7. Tells you the next command to run

If it tells you to reboot (Docker usually does), reboot and re-run the same one-liner — it's idempotent.

---

## 3-step path (manual)

```powershell
# Step 1 (PowerShell as Admin) — install Git + Azure CLI
winget install -e --id Git.Git             --silent
winget install -e --id Microsoft.AzureCLI --silent

# Close PowerShell, reopen it as Admin

# Step 2 — authenticate and clone
az login
az extension add --name azure-devops
git clone https://dev.azure.com/<YOUR-ADO-ORG>/<YOUR-ADO-PROJECT>/_git/claude-team-baseline "$env:USERPROFILE\work\claude-team-baseline"

# Step 3 — run bootstrap (installs everything else)
cd "$env:USERPROFILE\work\claude-team-baseline"
PowerShell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1
```

Same result, a few clicks more.

---

## What you should see when it's done

- Browser opens at `http://localhost:7777` showing the team wiki
- Terminal prints: `Ready. Type 'claude' in any project to start.`
- `~/work/claude-team-baseline/` contains the full repo
- `~/.claude/CLAUDE.md` is your personal Claude config
- `claude --version`, `uv --version`, `docker --version` all work

## Your first test

```powershell
# Scaffold a throwaway project to verify everything works end-to-end
bash "$env:USERPROFILE\work\claude-team-baseline\scripts\scaffold-project.sh" "$env:USERPROFILE\work\hello-claude"
cd "$env:USERPROFILE\work\hello-claude"
claude
```

First prompt to type at Claude:

> I just joined the team. Walk me through this project and help me add a hello-world page.

If Claude plans first, writes a test, implements, runs tests, and shows you the output — you're live.

---

## Distributing to your team

Once you're happy:

1. Tell each teammate the one-liner (with your ADO org, project, and a PAT in the URL)
2. They run it on their work PC
3. They open the wiki, read `home.md`, and start

That's the whole onboarding. Every question beyond that is answered in the wiki — point them there rather than answering each individually.

---

## If something breaks

- **winget refuses a package** → Run `winget search <id>` to confirm, install manually from the vendor if needed, re-run the one-liner
- **`claude` command not found after install** → Reboot (Windows PATH issue)
- **`uv sync` fails on pyodbc** → The MS ODBC Driver 18 didn't install. Run `winget install -e --id Microsoft.ODBCDriverForSQLServer.18` manually, reboot, retry
- **Behind corporate proxy, winget fails silently** → Configure winget with the proxy, or install each package from its vendor site

## Next steps after setup

1. **Open the wiki** (`python wiki/serve.py` if it's not already running) and read the home page.
2. **Scaffold your first real product** using `scripts/scaffold-project.sh`.
3. **Fill in the product brief** (`docs/brief.md` — template at `process/product-lifecycle/brief-template.md`).
4. **Tell Claude** "read docs/brief.md and plan the architecture". It takes over from there.

The wiki has everything else. If you can't find something in it, that's a gap-register entry — file it.
