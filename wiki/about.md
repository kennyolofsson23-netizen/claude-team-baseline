# What this is

`claude-team-baseline` is a git repository shared by the whole engineering team. It contains:

1. **A runnable Python project template** — every new project we start is a `cp -r` of this template.
2. **Shared Claude Code configuration** — agents, skills, hooks, rules that every developer's Claude follows.
3. **Bootstrap scripts** — one PowerShell command sets up a fresh Windows work PC end to end.
4. **Governance** — the deny-lists, the allow-lists, the enforcement hooks that keep the stack coherent.
5. **This wiki** — human-readable docs that explain why everything is the way it is.

## Why we have one

Without a shared baseline, every developer's Claude Code setup drifts. One person installs React and Claude "helps" them build an off-stack feature. Another skips the ruff lint and commits broken code. Security-sensitive paths get read because nobody set a deny-list. Over months, "the stack" becomes "whatever each dev feels like today".

This repo eliminates that drift. When you ask Claude "how should I build X?", **every dev on the team gets the same answer** because every Claude is reading the same `.claude/CLAUDE.md`, following the same rules, and firing the same agents.

## The three layers of configuration

```
┌──────────────────────────────────────────────────────────┐
│ 1. MANAGED (IT-controlled, MDM-deployed — PHASE 2)      │
│    managed-settings.json at C:\Program Files\ClaudeCode │
│    overrides everything; devs cannot bypass             │
├──────────────────────────────────────────────────────────┤
│ 2. PROJECT (committed in each repo)                     │
│    .claude/ — agents, skills, hooks, rules              │
│    team-wide, editable via PR to this repo              │
├──────────────────────────────────────────────────────────┤
│ 3. PERSONAL (each dev's machine)                        │
│    ~/.claude/ — personal prefs, theme, keybindings      │
│    installed once by scripts/install.sh                 │
└──────────────────────────────────────────────────────────┘
```

You never edit layer 1 or 2 directly. Changes go through a PR to `claude-team-baseline` so the whole team adopts them at once.

## Who owns what

| Artifact | Owner | Changed how |
|---|---|---|
| `template/.claude/CLAUDE.md` | Architect | PR to this repo |
| `template/.claude/agents/*` | Architect | PR to this repo |
| `template/.claude/skills/*` | Architect | PR to this repo |
| `template/.claude/hooks/*` | Architect + IT | PR to this repo |
| `template/.claude/rules/*` | Architect | PR to this repo |
| `template/pyproject.toml`, `Dockerfile`, `ci.yml` | Architect | PR to this repo |
| `managed-settings/example.json` | IT + architect | PR + MDM redeploy |
| `scripts/bootstrap.ps1` | Architect | PR to this repo |
| This wiki | Whole team | PR to this repo |

## What goes in a personal layer

Theme, editor font size, personal shortcuts, personal memory. Nothing that affects what Claude builds. If you find yourself wanting to change a rule personally — stop, open a PR to this repo instead, discuss with the architect.

## What happens when I run `scripts/install.sh`

1. Checks prerequisites are installed
2. Creates `~/.claude/` if missing
3. Copies `dotfiles/CLAUDE.md` → `~/.claude/CLAUDE.md` (your personal layer)
4. Copies `dotfiles/settings.json` → `~/.claude/settings.json` (only if you don't already have one)
5. Appends `PYTHONUTF8=1` to your `~/.bashrc`
6. Creates `~/work/` where project clones live
7. Runs `scripts/verify.sh` to check everything is healthy

It does not copy agents / skills / hooks to `~/.claude/`. Those live in each project's `.claude/` so they move with the code, not the machine.

## What happens when I run `scripts/scaffold-project.sh <name>`

1. Copies `template/` into `~/work/<name>/`
2. Runs `uv sync` to install the stack (`streamlit`, `fastapi`, `sqlalchemy`, `pyodbc`, etc.)
3. Initializes git with an initial commit
4. Writes a project-specific README
5. Runs the smoke test to confirm the scaffold is healthy

Your new project now has the same `.claude/` config as every other project on the team.
