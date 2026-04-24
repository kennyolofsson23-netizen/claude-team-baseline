# Rules — the quick-reference file

Rules are short, focused reference files that load automatically when Claude touches a matching file type. Think of them as "the thing on the wall above your monitor" rather than a full textbook.

## Our 7 rules

| File | Loads for | What it enforces |
|---|---|---|
| `git-safety.md` | always | Feature branches, never push to main, never commit secrets, confirm destructive ops |
| `environment.md` | always | Windows + Git Bash conventions, Python UTF-8 defaults, PowerShell quirks |
| `coding-style.md` | `.py`, `.ts`, `.go`, etc. | File size max 300 lines, function max 40 lines, max 3 params, no nested ternaries |
| `error-handling.md` | `.py`, `.ts`, etc. | No empty catches, no swallowed errors, no exceptions-for-control-flow, no user-facing stack traces |
| `python.md` | `*.py`, `pyproject.toml` | Full Python rules — approved libs, typing, imports, error handling, tests |
| `mssql.md` | `*.sql`, `models/`, `db/`, `alembic/` | T-SQL style, ORM-first, indexing, migrations, security, data types |
| `typescript.md` | `*.ts`, `*.tsx`, `*.js`, `*.jsx` | Typescript basics — only relevant if we ever open the React escape hatch |

## How rules load (path-scoped)

Every rule file has a YAML frontmatter listing which paths trigger it:

```yaml
---
paths:
  - "**/*.py"
  - "pyproject.toml"
---
# Python — Team Rules
...
```

Claude Code automatically loads the rule when you touch a matching file. You don't need to opt in.

This is why rules exist as separate files and not all in `CLAUDE.md` — loading on-demand keeps Claude's context lean and focused on the task at hand.

## Rules vs skills — when to use which

- **Rule**: short (< 2 pages), a list of dos-and-don'ts, scoped by file type. Think "style guide for X".
- **Skill**: longer (2+ pages), teaches a how-to or a pattern. Think "how to use X effectively".

When in doubt, start with a rule. Promote to a skill only if the content grows too big.

## Modifying a rule

1. Open a PR to `claude-team-baseline`
2. Edit `template/.claude/rules/<name>.md`
3. Architect reviews — rule changes affect every project on the team
4. Merge → every dev's Claude picks up the change on next pull

Most rule changes are just adding or removing a bullet. They should be easy to review.

## Creating a new rule

If you notice Claude making the same mistake across 2+ projects, that's a candidate rule. Examples that COULD become new rules:

- **api-versioning.md** — if we settle on a URL versioning scheme (`/v1/...`)
- **logging.md** — if we standardize structlog field names (`event`, `user_id`, `request_id`)
- **auth.md** — if we pick a specific auth library and want everyone to use it the same way

Draft a rule, open a PR.

## Rules are NOT

- Not a place for one-off preferences (use personal `~/.claude/CLAUDE.md`)
- Not a place for domain knowledge about a specific product (that goes in the product's own SPEC.md or ARCHITECTURE.md)
- Not a place for implementation details (those go in the code)

Rules are the guard rails that keep code consistent across projects and people. Keep them short and focused.
