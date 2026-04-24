# Next-session handover prompt

> Paste the block below verbatim into a fresh Claude Code session (run `claude` in `~/work/claude-team-baseline/`). It orients the new session, gives it its mandate, and tells it what to wait for.

---

```
You are continuing work on `claude-team-baseline` — a Claude Code team setup I built
with a previous session. It's NOT yet ready to release to my team of 10 IT people.
Before release, we need to wire in real Azure infrastructure values from my
infra-manager session.

STEP 1 — orient yourself. Read these in order, then summarize in 3-5 sentences:
  1. SETUP.md          — how the install flow works
  2. README.md         — top-level overview
  3. ROADMAP.md        — phases (we are in Phase 1; do not jump ahead)
  4. process/gap-register.md
  5. template/.claude/CLAUDE.md
  6. wiki/home.md      — run `python wiki/serve.py` to confirm it serves

STEP 2 — context you need to internalise:
  - Internal-only tools, Azure-native, MSSQL + Python-first (Streamlit / FastAPI)
  - Repo is public on my personal GitHub: kennyolofsson23-netizen/claude-team-baseline
    (will migrate to Enterprise later — do not hardcode my username anywhere that
    would break the migration)
  - Ticketing: Ivanti Service Manager. Teams is the comms channel (still TBD — see
    gap-register).
  - Team: 10 IT people, mixed backgrounds, junior/mid. I'm the sole architect (ARB
    of one) — I am also junior/mid. Keep everything simple.
  - Coverage floor is 60% for 3 months. Do not raise it.
  - Any stack change, new SaaS dep, or data-classification rule is an ARB decision
    — ask me, do not proceed alone.

STEP 3 — what you will wait for:

I will paste Azure infra values from my session (tenant, subscription, region, ACR
name, app service pattern, MSSQL server, Key Vault naming, App Insights strategy,
alert channel, DNS zone, cost ceiling, compliance requirements). Your job:
hardcode those values into the baseline so the deployer agent and docs have real
targets instead of `<placeholder>` strings.

Specifically, these files have placeholders to replace:
  - template/.claude/agents/deployer.md
  - template/.claude/hooks/trigger-rules.yml
  - managed-settings/example.json            (Phase 2 only — only touch if I
                                               confirm Enterprise license exists)
  - wiki/stack/deploy.md
  - process/gap-register.md                  (move resolved gaps to Resolved
                                               section with a one-line note)

Process for each change:
  - Update the file
  - Commit with a conventional commit message
     (max 72 chars subject — the commit-guard hook enforces this)
  - Push to origin/main after each logical group of changes
  - Tell me what you changed in one line

STEP 4 — what NOT to do:

  - Do not release the repo URL to my team yet
  - Do not build a real product yet — wait until infra is wired and I confirm
  - Do not over-engineer — match existing patterns, no new abstractions
  - Do not add agents, skills, hooks, or rules without explicit ARB approval
    (= ask me)
  - Do not jump to Phase 2 items (MDM, Enterprise license, MCP gateway)

STEP 5 — your first action, right now:

  1. Run `ls` in the repo root and confirm the expected top-level structure
  2. Run `python wiki/serve.py --no-open --port 7778` in the background, curl
     `http://localhost:7778/home.md` to confirm the wiki serves
  3. Read the 6 files above
  4. Summarise what you found in 3-5 sentences
  5. Ask me: "Paste the Azure values from the infra session and I'll wire them in."

Go.
```

---

## How to use this

1. On your work PC, after the bootstrap completed and you are in `~/work/claude-team-baseline/`:
   ```powershell
   claude
   ```
2. Copy everything between the triple-backticks above and paste it into the new Claude session.
3. The new session orients itself, confirms the environment, and waits for your infra values.
4. Paste the values. It wires them in, commits, pushes.
5. Once everything is green, you can scaffold a first real product and test the full baseline end-to-end.
6. After that — we do the 3-slide summary and plan the team rollout.

If the new Claude drifts from the mandate, remind it: "Read NEXT-SESSION.md again — stay within scope, Phase 1 only."
