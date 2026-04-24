# claude-team-baseline

The shared Claude Code configuration for our engineering team. Clone this once per machine, run `scripts/install.sh`, and every project you work on inherits the same agents, skills, hooks, and stack rules.

## Why this exists
Without a shared baseline, every developer ends up with a slightly different Claude setup. Code quality, security posture, and stack choices drift. This repo is the single source of truth so that when a junior asks Claude "how should I build X?", every machine gives the same answer.

## Who uses it
- **Developers**: run `scripts/install.sh` once, then follow `ONBOARDING.md`.
- **Architect / lead**: owns this repo. All changes to agents, skills, hooks, and stack rules go through PRs here.

## What it contains
- `template/` — the `.claude/` folder that gets copied into every new project via `scripts/scaffold-project.sh`. Agents, skills, hooks, rules, Streamlit app skeleton, CI pipeline.
- `dotfiles/` — minimal personal `~/.claude/` baseline. Covers settings, theme defaults, and a personal CLAUDE.md stub.
- `scripts/` — bootstrap and scaffolding tools.
- `managed-settings/` — the enterprise policy file to deploy via MDM once we have the Enterprise license (phase 2).

## Start here
- **Dead-simple install on your work PC** → `SETUP.md` (one PowerShell line)
- **Interactive wiki** → `python wiki/serve.py` opens it at `http://localhost:7777`
- **New developer** → `ONBOARDING.md`
- **Roadmap + gaps** → `ROADMAP.md` and `process/gap-register.md`

## Core stack (the one true way)
Python 3.12, Streamlit, FastAPI where Streamlit cannot reach, SQLAlchemy + MSSQL, uv + ruff + mypy + pytest. See `template/.claude/CLAUDE.md` for the full rules. There is no "React project" template. There is no "Postgres project" template. If you need one, talk to the architect.

## License
Internal use only. Do not publish.
