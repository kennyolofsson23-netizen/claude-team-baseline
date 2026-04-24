# One-command setup

This is the fastest way to go from a fresh Windows PC to a working Claude Code + team stack.

## Prerequisite

You must have **local administrator** on the PC. Everything else is installed for you.

## The command

Open **PowerShell 7+** as Administrator, then run:

```powershell
# If this is the first time — get the repo first by whatever means (git clone, zip download).
# Then cd into it and run:
PowerShell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1 -RepoUrl "<your-company-git-url>"
```

That's it. The script handles:

| Step | What it does |
|---|---|
| 1 | Installs Git, GitHub CLI, Node.js LTS, Python 3.12, Claude Code, uv, VS Code, Docker Desktop, and MS ODBC Driver 18 — all via winget |
| 2 | Sets `PYTHONUTF8=1` and `PYTHONIOENCODING=utf-8` at user scope |
| 3 | Creates `~/work/` as the project directory |
| 4 | Clones this baseline repo into `~/work/claude-team-baseline/` (or pulls if already present) |
| 5 | Runs `scripts/install.sh` via Git Bash — copies the personal layer to `~/.claude/`, verifies the install |

## After the script finishes

You may need to **reboot** if winget just installed Docker Desktop or if some PATH entries haven't propagated. The script will tell you.

Once rebooted, finish with:

```bash
# Authenticate GitHub
gh auth login

# Authenticate Claude (browser popup — use your company account)
claude
# type /exit or Ctrl+C once login succeeds
```

Now you're ready to scaffold your first project:

```bash
bash ~/work/claude-team-baseline/scripts/scaffold-project.sh ~/work/hello-claude
cd ~/work/hello-claude
claude
```

Follow [Your first project](getting-started/first-project.md) for the walk-through.

## If the script fails

- **winget unknown package**: Run `winget search <id>` to confirm the ID. Some names change over Windows updates. The script continues on failures — check the output for `[!!]` warnings.
- **Git Bash not found**: The script needs Git Bash to run `install.sh`. If Git installed but bash.exe isn't at the default path, run `bash scripts/install.sh` manually.
- **Execution policy blocked**: You ran PowerShell as a standard user, not Administrator. Close, right-click PowerShell → Run as Administrator, try again.
- **Behind a corporate proxy**: winget may fail silently. Either configure winget to use the proxy, or install the packages manually (see [Manual setup](getting-started/handover.md)).

## What if I'm not on Windows?

The bootstrap script is Windows-only right now. On macOS or Linux, follow the manual [HANDOVER.md](getting-started/handover.md) — it documents every step so you can adapt.
