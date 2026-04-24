# HANDOVER — Setting Up Claude on Your Work PC

This is a step-by-step for Kenny (or anyone) to bootstrap a work machine from zero. Assumes:
- Windows 10/11
- Local admin rights
- Git Bash will be installed (or is already)

Time budget: **~30 minutes** including downloads.

---

## Step 1 — Install the prerequisites (one-time)

Open PowerShell **as Administrator** and run:

```powershell
# If you already have winget, skip this check
winget --version

# Install everything we need
winget install --id Git.Git                -e --source winget --silent
winget install --id GitHub.cli             -e --source winget --silent
winget install --id Python.Python.3.12     -e --source winget --silent
winget install --id Anthropic.ClaudeCode   -e --source winget --silent
winget install --id Microsoft.VisualStudioCode -e --source winget --silent
winget install --id astral-sh.uv           -e --source winget --silent
```

> **If winget refuses any line**: download the installer directly from the vendor's site, install manually, continue.

Close PowerShell. Open a **fresh Git Bash** (this gets the new PATH).

Verify each tool:

```bash
git --version
gh --version
python --version       # should say 3.12.x
claude --version
uv --version
```

All five must print a version. If `claude` is missing, reboot — Windows sometimes won't pick up new PATH entries without it.

---

## Step 2 — Authenticate

```bash
# GitHub — you'll get a browser popup
gh auth login

# Claude Code — browser popup, log in with your company account
claude
# When prompted, pick "Claude Pro / Team / Enterprise" (not API key)
# Close the Claude session once login succeeds: Ctrl+C, then type /exit
```

If the company doesn't yet have an Enterprise license, log in with your personal Claude Pro/Max account for now. We'll migrate when the license arrives (see ROADMAP.md).

---

## Step 3 — Clone this baseline repo

```bash
mkdir -p ~/work
cd ~/work
git clone <REPO_URL> claude-team-baseline
cd claude-team-baseline
```

Replace `<REPO_URL>` with the actual URL once pushed to GitHub / the company's Git host.

---

## Step 4 — Run the installer

```bash
bash scripts/install.sh
```

This will:
1. Copy `dotfiles/` into `~/.claude/` (personal config)
2. Symlink the baseline agents, skills, hooks, rules into `~/.claude/` so every Claude session has them available
3. Create `~/work/` directory conventions
4. Verify nothing is broken

If it fails, it will tell you which step failed. Fix that one thing and re-run.

---

## Step 5 — Verify

```bash
bash scripts/verify.sh
```

Expected output:
```
✓ Git Bash OK
✓ Python 3.12 OK
✓ Claude Code OK
✓ uv OK
✓ Baseline installed
✓ Agents: 12 found
✓ Skills: 25 found
✓ Hooks: 6 found
✓ Ready.
```

If any line is ✗, read the error, fix it, re-run.

---

## Step 6 — First Claude session

```bash
mkdir -p ~/work/hello-claude
cd ~/work/hello-claude
bash ~/work/claude-team-baseline/scripts/scaffold-project.sh .
claude
```

First prompt to type:

> I'm new. Introduce yourself, explain what you can do, and walk me through building a tiny Streamlit dashboard that lists mock customers from MSSQL.

Claude should:
1. Introduce itself as your senior engineer
2. Make a plan first (not just code)
3. Write a test before implementation
4. Run the test
5. Implement
6. Run everything and show output

If Claude jumps straight to code without a plan — stop it, say "plan first please", and tell Kenny the hook didn't fire.

---

## Step 7 — Telling the team

Once step 6 works on your machine:
1. Push this repo to the company's Git host
2. Send the URL + HANDOVER.md to each teammate
3. Walk at least one teammate through step 6 in person so you see where people get stuck

---

## If something breaks

- Windows PATH issues → reboot, try again
- `claude` refuses to start → `claude --help` and see the error; usually an auth issue
- Hook errors on first prompt → the hook scripts need `python` in PATH. Verify `which python`.
- Missing agent / skill → `ls ~/.claude/agents/` should show 12 symlinks. Re-run `scripts/install.sh`.

When in real trouble, open Claude and paste the error. It will diagnose.

---

## What Kenny does next

After step 6 works:
1. Review `template/.claude/CLAUDE.md` — adjust any stack rule you disagree with
2. Review `template/.claude/hooks/auto-invoke-router.py` and `trigger-rules.yml` — the keyword triggers that auto-fire agents/skills. Add/remove triggers as you learn what juniors ask for.
3. Read `ROADMAP.md` — what comes next (Enterprise license, MDM-deployed managed settings, centralized MCP gateway).
