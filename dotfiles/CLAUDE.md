# Personal Claude Instructions

This file is your individual layer. It is merged with the team CLAUDE.md in every project. Add your personal preferences here — never edit the team CLAUDE.md locally.

## Session Start
- Read `tasks/todo.md` in the current project if it exists

## Personal preferences
- Concise over verbose. Show the answer, not your reasoning, unless asked.
- If I paste an error, diagnose and fix — do not explain the error first.

## What NOT to do here
- Do not duplicate team rules from `.claude/CLAUDE.md` in the project — they are already loaded.
- Do not add domain-specific knowledge here. If it applies to the team, propose a PR to `claude-team-baseline`.
- Do not override the stack rules (Python, Streamlit, MSSQL, etc.) — those come from the team layer and are enforced.

## Workspace
- Projects live in `~/work/<project-name>/`
- Scaffold new ones with `bash ~/work/claude-team-baseline/scripts/scaffold-project.sh <name>`
